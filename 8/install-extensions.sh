#!/usr/bin/env bash

set -euo pipefail

jobs=$(getconf _NPROCESSORS_ONLN)
php_minor=$(php -r 'echo PHP_MAJOR_VERSION, ".", PHP_MINOR_VERSION;')

# Remove the inherited installer before building anything: neither PIE nor the
# source builds below may depend on PEAR/PECL. Keep PHP's build tools and modules.
rm -rf /usr/local/bin/pear /usr/local/bin/peardev /usr/local/bin/pecl \
    /usr/local/etc/pear.conf /root/.pearrc /tmp/pear \
    /usr/local/lib/php/.channels /usr/local/lib/php/.registry \
    /usr/local/lib/php/.depdb /usr/local/lib/php/.depdblock \
    /usr/local/lib/php/.filemap /usr/local/lib/php/.lock \
    /usr/local/lib/php/Archive /usr/local/lib/php/Console /usr/local/lib/php/OS \
    /usr/local/lib/php/PEAR /usr/local/lib/php/PEAR.php \
    /usr/local/lib/php/Structures /usr/local/lib/php/System.php \
    /usr/local/lib/php/XML /usr/local/lib/php/pearcmd.php /usr/local/lib/php/peclcmd.php \
    /usr/local/lib/php/data /usr/local/lib/php/doc /usr/local/lib/php/test

# Use an isolated home so PIE's downloaded sources and registry do not remain in
# the image. Enabling modules stays with the Dockerfile and entrypoint templates.
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT

install_pie() {
    local attempt status
    for attempt in 1 2 3; do
        if HOME="${build_dir}/home" pie install --no-interaction --no-cache \
            --skip-enable-extension -j "${jobs}" "$@" 2>&1 | tee "${build_dir}/pie.log"; then
            return 0
        else
            status=$?
        fi
        # Retry transport failures, but report dependency and compiler errors immediately.
        if [[ "${attempt}" == 3 ]] || ! grep -Eq \
            'curl error (5|6|7|18|28|35|52|55|56) |HTTP/[0-9.]+ (429|50[0234])' "${build_dir}/pie.log"; then
            return "${status}"
        fi
        echo "Retrying PIE after a transient download failure (${attempt}/3)" >&2
        sleep "$((attempt * 2))"
    done
}

# Build exact release archives without the PECL client. Checksums deliberately
# fail closed if an archive changes; update the version and checksum together.
install_source() {
    local package=$1 checksum=$2 subdir=$3
    shift 3
    local archive="${build_dir}/${package}.tgz"
    local source_dir="${build_dir}/${package}"
    curl --fail --show-error --location --retry 3 --retry-connrefused \
        "https://pecl.php.net/get/${package}.tgz" --output "${archive}"
    echo "${checksum}  ${archive}" | sha256sum -c -
    mkdir -p "${source_dir}"
    tar -xzf "${archive}" --strip-components=1 -C "${source_dir}" "${package}"
    (
        cd "${source_dir}/${subdir}"
        phpize
        ./configure --with-php-config=/usr/local/bin/php-config "$@"
        make -j "${jobs}"
        make install
    )
    # PECL also installed these PHP libraries and the bundled profiler UI.
    if [[ "${package}" == xhprof-* ]]; then
        cp -a "${source_dir}/xhprof_lib" "${source_dir}/xhprof_html" /usr/local/lib/php/
    fi
    rm -rf "${source_dir}" "${archive}"
}

install_pie apcu/apcu:5.1.28
install_pie php-amqp/php-amqp:2.2.0
install_pie nikic/php-ast:1.1.3
install_pie php-ds/ext-ds:2.0.0
# Match PECL's configure defaults, especially sockets and TLS support.
install_pie osmanov/pecl-event:3.1.6 --enable-event-sockets \
    --with-event-libevent-dir=/usr --with-event-extra=yes --with-event-openssl \
    --with-openssl-dir=yes
install_pie grpc/grpc-php-ext
install_pie igbinary/igbinary:3.2.17RC1
install_pie php-memcached/php-memcached:3.4.0 --enable-memcached-sasl --enable-memcached-session
install_pie mongodb/mongodb-extension:2.5.2
install_pie open-telemetry/ext-opentelemetry:1.4.1
install_pie pecl/pcov:1.0.12
install_pie rdkafka/rdkafka:6.0.5
install_pie phpredis/phpredis:6.3.0
install_pie pecl/uuid:1.3.0
install_pie xdebug/xdebug:3.5.3
install_pie pecl/yaml:2.3.0

if [[ "${php_minor}" == 8.2 ]]; then
    # Microsoft's PIE packages require PHP >= 8.3; preserve the 8.2 driver pins.
    install_source pdo_sqlsrv-5.12.0 22f0cb17b45f0deccd0bba072ee0085ff4094cd6ee2acc26f7f924975ef652c6 .
    install_source sqlsrv-5.12.0 a9ebb880b2a558d3d6684f6e6802c53c5bffa49e1ee60d1473a7124fc9cb72ad .
else
    # Use the exact release archives without GitHub API discovery. Anonymous PIE
    # lookups can fail authentication while resolving these packaged sources.
    install_source pdo_sqlsrv-5.13.3 198a7b37da0658d36a93d158a0ec179b137b3a4d241c90a6650ae9ee8f91ec4a .
    install_source sqlsrv-5.13.3 1c3092ca793bb67002ca022c412aacabb79a3297ee7005e3b7cc91b1e7166d22 .
fi

if [[ "${php_minor}" == 8.4 || "${php_minor}" == 8.5 ]]; then
    # PHP 8.2/8.3 still build IMAP from the bundled PHP sources.
    PHP_OPENSSL=yes install_source imap-1.0.3 0c2c0b1f94f299004be996b85a424e3d11ff65ac0a3c980db3213289a4a3faaf . \
        --with-kerberos --with-imap-ssl
fi
install_source oauth-2.0.10 1fd5e074dacf5149603493c454b476d69850bec0a71d7ea69a36a00db728a0fb .
# The PIE tag leaves @PACKAGE_VERSION@ in Imagick's headers; the release archive
# contains PECL's version substitution and preserves phpversion('imagick').
install_source imagick-3.8.1 3a3587c0a524c17d0dad9673a160b90cd776e836838474e173b549ed864352ee . --with-imagick=autodetect
install_source protobuf-5.36.1 5bba769656bdddc9ee275f5d08b0faf18e527088230ab52058aa56e363f2fa41 .
install_source smbclient-1.1.2 1e6a744563aac700815e571ad98b1135a84e840d44e6ac67997494c780a9cde7 .
install_source uploadprogress-2.0.2 2c63ce727340121044365f0fd83babd60dfa785fa5979fae2520b25dad814226 .
install_source xhprof-2.3.10 251aee99c2726ebc6126e1ff0bb2db6e2d5fd22056aa335e84db9f1055d59d95 extension
