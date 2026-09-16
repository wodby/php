#!/usr/bin/env bash

set -eo pipefail

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

source /home/wodby/.shrc
expected_prompt='\u@'"$(hostname)"':\w $ '
if [[ "${PS1}" != "${expected_prompt}" ]]; then
    echo "Unexpected shell prompt: ${PS1}"
    exit 1
fi

php -m > ~/php_modules.tmp 2> ~/php_startup_errors.tmp
if [[ -s ~/php_startup_errors.tmp ]]; then
    cat ~/php_startup_errors.tmp >&2
    exit 1
fi
echo -n "Checking PHP modules... "

# Modify copy, keep the mounted version untouched.
cp ~/php_modules/"${PHP_VERSION:0:3}" ~/expected_modules

if ! cmp -s ~/php_modules.tmp ~/expected_modules; then
    echo "Error. PHP modules are not identical."
    diff ~/php_modules.tmp ~/expected_modules
    exit 1
fi

echo "OK"

php /usr/local/bin/extensions.php

echo -n "Checking extension installer... "
pie --version | grep -q '1.4.10'
for tool in pecl pear peardev; do
    if command -v "${tool}" >/dev/null; then
        echo "Unexpected legacy installer: ${tool}" >&2
        exit 1
    fi
done
if [[ -e /usr/local/lib/php/PEAR.php || -e /usr/local/etc/pear.conf ]]; then
    echo 'Unexpected PEAR installation' >&2
    exit 1
fi
echo "OK"

echo -n "Checking composer... "
composer --version | grep -q 'Composer version'
echo "OK"

if [[ $(uname -m) == "x86_64" ]]; then
  echo -n "Checking walter... "
  walter -v | grep -q 'Walter version'
  echo "OK"
fi
