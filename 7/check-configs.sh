#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

php_ver=$1
php_ver_minor=$2

url="https://raw.githubusercontent.com/php/php-src/php-${php_ver}"

array=(
    "./orig/php-${php_ver_minor}.ini-development::${url}/php.ini-development"
    "./orig/php-${php_ver_minor}.ini-production::${url}/php.ini-production"
)

outdated=0

for index in "${array[@]}" ; do
    local="${index%%::*}"
    url="${index##*::}"

    orig="/tmp/${RANDOM}"
    wget -qO "${orig}" "${url}"

    echo "Checking ${local}"

    if diff --strip-trailing-cr "${local}" "${orig}"; then
        echo "OK"
    else
        echo "!!! OUTDATED"
        echo "${url}"
        outdated=1
    fi

    rm -f "${orig}"
done

# we don't want travis builds to fail.
#[[ "${outdated}" == 0 ]] || exit 1