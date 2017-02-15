#!/usr/bin/env bash

set -ex

function checkPhpModules {
    printf "asdf\nzxcv" > travis.tmp
    cat travis.tmp
    tail -n +2 travis.tmp > travis2.tmp
    cat travis2.tmp

    printf "123\456" > ./test/travis.tmp
    cat ./test/travis.tmp
    tail -n +2 ./test/travis.tmp > ./test/travis2.tmp
    cat ./test/travis2.tmp

    exit 1
    # Export PHP modules.
#    make run -e CMD="php -m" ENV="-e PHP_XDEBUG=1" > ./test/php_modules.tmp
#    tail -n +2 ./test/php_modules.tmp > ./test/tmp
#    cat ./test/tmp
#    mv ./test/tmp ./test/php_modules.tmp
#    # Compare PHP modules.
#    if ! cmp ./test/php_modules.tmp ./test/php_modules; then
#        echo 'Error. PHP modules are not identical.'
#        diff ./test/php_modules.tmp ./test/php_modules
#        exit 1
#    fi
}

function checkPhpFpm {
    make start
    make stop rm
}

function checkTools {
    make run -e CMD='pwd' | grep '/var/www/html'
    make run -e CMD='composer --version' ENV="-e COMPOSER_ALLOW_SUPERUSER=1"
    make run -e CMD='ssh -V'
}

function checkSshKeys {
    mkdir -p ./test/ssh.tmp
    ssh-keygen -t dsa -N '' -f ./test/ssh.tmp/id_rsa
    chmod 700 ./test/ssh.tmp
    make run -e CMD='[ -f /home/www-data/.ssh/id_rsa ]' VOLUMES="-v ${PWD}/test/ssh.tmp:/mnt/ssh"
    make run -e CMD='[ -f /home/www-data/.ssh/id_rsa.pub ]' VOLUMES="-v ${PWD}/test/ssh.tmp:/mnt/ssh"
}

function cleanup {
    rm -rf ./test/*.tmp
}

cleanup
checkPhpModules
checkPhpFpm
checkTools
checkSshKeys
cleanup
