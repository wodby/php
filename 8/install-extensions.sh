#!/usr/bin/env bash

set -euo pipefail

jobs=$(getconf _NPROCESSORS_ONLN)
php_minor=$(php -r 'echo PHP_MAJOR_VERSION, ".", PHP_MINOR_VERSION;')

# Extensions without a release that builds on a PHP version. The images for that
# version ship without them until upstream catches up: https://github.com/wodby/php/issues/274
# Keep this in step with the Dockerfile (New Relic, SPX) and tests/php_modules.
declare -A unavailable=(
    [8.6]="amqp apcu ds grpc igbinary imagick imap memcached oauth pcov protobuf rdkafka redis smbclient uploadprogress xdebug yaml"
)

# Succeed when module $1 has a release for this PHP version.
supported() {
    [[ " ${unavailable[${php_minor}]:-} " != *" $1 "* ]]
}

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

. "$(dirname "${BASH_SOURCE[0]}")/pie-install.sh"

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

# Build an exact release archive published outside PECL, with its sources at the archive root.
install_release() {
    local name=$1 url=$2 checksum=$3
    shift 3
    local archive="${build_dir}/${name}.tgz"
    local source_dir="${build_dir}/${name}"
    curl --fail --show-error --location --retry 3 --retry-connrefused "${url}" --output "${archive}"
    echo "${checksum}  ${archive}" | sha256sum -c -
    mkdir -p "${source_dir}"
    tar -xzf "${archive}" -C "${source_dir}"
    (
        cd "${source_dir}"
        phpize
        ./configure --with-php-config=/usr/local/bin/php-config "$@"
        make -j "${jobs}"
        make install
    )
    rm -rf "${source_dir}" "${archive}"
}

# Install module $1 through PIE or a release archive, unless it is unavailable here.
pie_for() {
    local module=$1
    shift
    if supported "${module}"; then
        install_pie "$@"
    else
        echo "Skipping ${module}: no release for PHP ${php_minor}"
        # The entrypoint reads this to accept the module in PHP_EXTENSIONS_DISABLE.
        echo "${module}" >> "${PHP_INI_DIR}/unavailable-extensions"
    fi
}
source_for() {
    local module=$1
    shift
    if supported "${module}"; then
        install_source "$@"
    else
        echo "Skipping ${module}: no release for PHP ${php_minor}"
        # The entrypoint reads this to accept the module in PHP_EXTENSIONS_DISABLE.
        echo "${module}" >> "${PHP_INI_DIR}/unavailable-extensions"
    fi
}
release_for() {
    local module=$1
    shift
    if supported "${module}"; then
        install_release "${module}" "$@"
    else
        echo "Skipping ${module}: no release for PHP ${php_minor}"
        # The entrypoint reads this to accept the module in PHP_EXTENSIONS_DISABLE.
        echo "${module}" >> "${PHP_INI_DIR}/unavailable-extensions"
    fi
}

pie_for apcu apcu/apcu:5.1.28
pie_for amqp php-amqp/php-amqp:2.2.0
pie_for ast nikic/php-ast:1.1.4
pie_for ds php-ds/ext-ds:2.0.0
pie_for grpc grpc/grpc-php-ext
pie_for igbinary igbinary/igbinary:3.2.17RC1
pie_for memcached php-memcached/php-memcached:3.4.0 --enable-memcached-sasl --enable-memcached-session
pie_for mongodb mongodb/mongodb-extension:2.5.7
pie_for opentelemetry open-telemetry/ext-opentelemetry:1.5.0
pie_for pcov pecl/pcov:1.0.12
pie_for rdkafka rdkafka/rdkafka:6.0.5
pie_for redis phpredis/phpredis:6.3.0
pie_for uuid pecl/uuid:1.3.0
pie_for xdebug xdebug/xdebug:3.5.3
pie_for yaml pecl/yaml:2.3.0

if [[ "${php_minor}" == 8.2 ]]; then
    # Microsoft's PIE packages require PHP >= 8.3; preserve the 8.2 driver pins.
    source_for pdo_sqlsrv pdo_sqlsrv-5.12.0 22f0cb17b45f0deccd0bba072ee0085ff4094cd6ee2acc26f7f924975ef652c6 .
    source_for sqlsrv sqlsrv-5.12.0 a9ebb880b2a558d3d6684f6e6802c53c5bffa49e1ee60d1473a7124fc9cb72ad .
elif [[ "${php_minor}" == 8.3 ]]; then
    # 5.14.0 supports PHP 8.4 and newer only; 5.13.3 is the last release for PHP 8.3.
    source_for pdo_sqlsrv pdo_sqlsrv-5.13.3 198a7b37da0658d36a93d158a0ec179b137b3a4d241c90a6650ae9ee8f91ec4a .
    source_for sqlsrv sqlsrv-5.13.3 1c3092ca793bb67002ca022c412aacabb79a3297ee7005e3b7cc91b1e7166d22 .
else
    # Since 5.14.0 the drivers are published through PIE and GitHub releases, not PECL.
    # Use the exact release archives without GitHub API discovery: anonymous PIE
    # lookups can fail authentication while resolving these packaged sources.
    release_for pdo_sqlsrv https://github.com/microsoft/msphpsql/releases/download/v5.14.0/pdo_sqlsrv-v5.14.0.tgz \
        e6493a697bdc9da8e375c6f7b97903b72c3916093636016db8ddbf9761332566
    release_for sqlsrv https://github.com/microsoft/msphpsql/releases/download/v5.14.0/sqlsrv-v5.14.0.tgz \
        7397647a443e0f6b36ca26cee21bd55d690318641939f8b32c6f51dae0d60d20
fi

if [[ "${php_minor}" != 8.2 && "${php_minor}" != 8.3 ]]; then
    # PHP 8.2/8.3 still build IMAP from the bundled PHP sources.
    PHP_OPENSSL=yes source_for imap imap-1.0.3 0c2c0b1f94f299004be996b85a424e3d11ff65ac0a3c980db3213289a4a3faaf . \
        --with-kerberos --with-imap-ssl
fi
# The PIE package downloads its source from Bitbucket; the PECL archive avoids
# that dependency. Match PECL's configure defaults, especially sockets and TLS.
source_for event event-3.2.0 fb3d4e3c9fdc79125274f2b46461492923edec6b489ed7077973f7e65f41dc1c . \
    --enable-event-sockets --with-event-libevent-dir=/usr --with-event-extra=yes \
    --with-event-openssl --with-openssl-dir=yes
source_for oauth oauth-2.0.10 1fd5e074dacf5149603493c454b476d69850bec0a71d7ea69a36a00db728a0fb .
# The PIE tag leaves @PACKAGE_VERSION@ in Imagick's headers; the release archive
# contains PECL's version substitution and preserves phpversion('imagick').
source_for imagick imagick-3.8.1 3a3587c0a524c17d0dad9673a160b90cd776e836838474e173b549ed864352ee . --with-imagick=autodetect
source_for protobuf protobuf-5.36.2 f0a17c67de29df0fb0e5215a381df9b155125e1ace6252dd617bf16b4194dd5b .
source_for smbclient smbclient-1.1.2 1e6a744563aac700815e571ad98b1135a84e840d44e6ac67997494c780a9cde7 .
source_for uploadprogress uploadprogress-2.0.2 2c63ce727340121044365f0fd83babd60dfa785fa5979fae2520b25dad814226 .
source_for xhprof xhprof-2.3.10 251aee99c2726ebc6126e1ff0bb2db6e2d5fd22056aa335e84db9f1055d59d95 extension
