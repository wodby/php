#!/bin/sh
# Execute inside the image, bypassing application startup.
set -eu
[ -n "${PHP_DEV:-}" ] || exit 0
for tool in sh bash git curl rg jq nano ssh ssh-keygen; do
    command -v "$tool" >/dev/null
done
test -x /usr/sbin/sshd
test "$(id -u)" -ne 0
test -w "$HOME"
identity=$(mktemp -d)
trap 'rm -rf "$identity"' EXIT
ssh-keygen -q -t ed25519 -N '' -f "$identity/host"
sudo -n /usr/sbin/sshd -t -f /dev/null -h "$identity/host"
mkdir -p "$HOME/.local/bin"
printf '#!/bin/sh\nprintf login-tools-ok\n' > "$HOME/.local/bin/workspace-path-test"
chmod +x "$HOME/.local/bin/workspace-path-test"
bash -lc workspace-path-test | grep -q login-tools-ok
