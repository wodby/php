#!/usr/bin/env bash

# Run as root in a disposable image container, without application bind mounts.
set -euo pipefail

assert_mode() {
    local expected=$1 path=$2 actual
    actual=$(stat -c '%a' "${path}")
    if [[ "${actual}" != "${expected}" ]]; then
        echo >&2 "Expected mode ${expected}, got ${actual}: ${path}"
        exit 1
    fi
}

shared="${FILES_DIR}/public"
scratch=$(mktemp -d)
trap 'rm -rf "${scratch}"' EXIT
before=$(stat -c '%u:%g:%a' "${APP_ROOT}" /home/wodby /home/wodby/.ssh)

echo 'Checking shared creation with the default restrictive umask...'
su-exec wodby sh -ec '
    umask 0022
    mkdir -p "$FILES_DIR/public/by-wodby/nested"
    printf fixture > "$FILES_DIR/public/by-wodby/nested/asset.css"
'
assert_mode 2775 "${shared}/by-wodby/nested"
assert_mode 664 "${shared}/by-wodby/nested/asset.css"
[[ $(stat -c '%G' "${shared}/by-wodby/nested") == www-data ]]
su-exec www-data sh -ec '
    printf updated >> "$FILES_DIR/public/by-wodby/nested/asset.css"
    rm "$FILES_DIR/public/by-wodby/nested/asset.css"
'

# Exercise PHP-created directories, including Drupal's explicit 0775 chmod.
su-exec www-data php -r '
    umask(0022);
    $dir = getenv("FILES_DIR") . "/public/by-php";
    if (!mkdir($dir) || !chmod($dir, 0775) || !mkdir($dir . "/nested")) {
        exit(1);
    }
    if (file_put_contents($dir . "/nested/asset.css", "fixture") === false) {
        exit(1);
    }
'
su-exec wodby sh -ec '
    printf updated >> "$FILES_DIR/public/by-php/nested/asset.css"
    rm "$FILES_DIR/public/by-php/nested/asset.css"
'

# An explicit private mode must still be honored, even inside the shared tree.
su-exec wodby php -r '
    $file = getenv("FILES_DIR") . "/public/private-mode";
    touch($file);
    chmod($file, 0600);
'
assert_mode 600 "${shared}/private-mode"
su-exec www-data test ! -w "${shared}/private-mode"

echo 'Checking imported permissions, executable bits, and symlinks...'
mkdir -p "${scratch}/archive/css/nested" "${scratch}/archive/restricted"
printf fixture > "${scratch}/archive/css/nested/asset.css"
printf '#!/bin/sh\nexit 0\n' > "${scratch}/archive/tool"
printf fixture > "${scratch}/archive/restricted/data"
chmod 755 "${scratch}/archive/css" "${scratch}/archive/css/nested" "${scratch}/archive/tool"
chmod 644 "${scratch}/archive/css/nested/asset.css"
chmod 700 "${scratch}/archive/restricted"
chmod 600 "${scratch}/archive/restricted/data"
mkdir "${scratch}/outside"
chmod 700 "${scratch}/outside"
ln -s "${scratch}/outside" "${scratch}/archive/outside-link"
files_sync "${scratch}/archive/" "${shared}/"
assert_mode 2775 "${shared}/css/nested"
assert_mode 664 "${shared}/css/nested/asset.css"
assert_mode 775 "${shared}/tool"
assert_mode 2770 "${shared}/restricted"
assert_mode 660 "${shared}/restricted/data"
assert_mode 700 "${scratch}/outside"
[[ -L "${shared}/outside-link" ]]
su-exec wodby sh -ec '
    printf updated >> "$FILES_DIR/public/css/nested/asset.css"
    rm "$FILES_DIR/public/css/nested/asset.css"
    umask 0022
    mkdir "$FILES_DIR/public/css/nested/new"
    touch "$FILES_DIR/public/css/nested/new/asset.css"
'
su-exec www-data sh -ec 'rm "$FILES_DIR/public/css/nested/new/asset.css"'

echo 'Checking repair of an existing tree and repeated initialization...'
mkdir -p "${shared}/legacy/nested"
touch "${shared}/legacy/nested/asset.css"
setfacl -Rb "${shared}/legacy"
setfacl -Rk "${shared}/legacy"
chown -R wodby:wodby "${shared}/legacy"
chmod 00755 "${shared}/legacy" "${shared}/legacy/nested"
chmod 644 "${shared}/legacy/nested/asset.css"
init_container
assert_mode 755 "${shared}/legacy/nested"
[[ $(stat -c '%G' "${shared}/legacy/nested") == wodby ]]
su-exec wodby sudo files_chmod "${shared}/legacy"
su-exec www-data sh -ec '
    printf updated >> "$FILES_DIR/public/legacy/nested/asset.css"
    rm "$FILES_DIR/public/legacy/nested/asset.css"
    umask 0022
    mkdir "$FILES_DIR/public/legacy/nested/new"
    touch "$FILES_DIR/public/legacy/nested/new/asset.css"
'
su-exec wodby sh -ec 'rm "$FILES_DIR/public/legacy/nested/new/asset.css"'
init_container
init_container
assert_mode 2775 "${shared}"
[[ "${before}" == "$(stat -c '%u:%g:%a' "${APP_ROOT}" /home/wodby /home/wodby/.ssh)" ]]

echo 'Checking unsupported ACL mounts and unexpected ACL failures...'
mkdir "${scratch}/bin" "${scratch}/no-acl"
cat > "${scratch}/bin/setfacl" <<'SH'
#!/bin/sh
echo 'setfacl: Operation not supported' >&2
exit 1
SH
chmod +x "${scratch}/bin/setfacl"
PATH="${scratch}/bin:${PATH}" files_prepare_dirs "${scratch}/no-acl" 2> "${scratch}/warning"
grep -q 'WARNING: default ACLs are not supported' "${scratch}/warning"
assert_mode 2775 "${scratch}/no-acl"
cat > "${scratch}/bin/setfacl" <<'SH'
#!/bin/sh
echo 'setfacl: Operation not permitted' >&2
exit 1
SH
if PATH="${scratch}/bin:${PATH}" files_prepare_dirs "${scratch}/no-acl" 2> "${scratch}/error"; then
    echo >&2 'Unexpected ACL failures must not be ignored'
    exit 1
fi
grep -q 'Operation not permitted' "${scratch}/error"

echo 'Shared files permission tests passed.'
