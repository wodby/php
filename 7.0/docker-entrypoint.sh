#!/usr/bin/env bash

set -e

if [[ -n ${DEBUG} ]]; then
  set -x
fi

execTpl() {
    if [[ -f "/etc/gotpl/$1" ]]; then
        gotpl "/etc/gotpl/$1" > "$2"
    fi
}

execInitScripts() {
    shopt -s nullglob
    for f in /docker-entrypoint-init.d/*.sh; do
        echo "$0: running $f"
        . "$f"
    done
    shopt -u nullglob
}

fixPermissions() {
    chown www-data:www-data /var/www/html
}

execTpl 'php.ini.tpl' "${PHP_INI_DIR}/php.ini"
execTpl 'opcache.ini.tpl' "${PHP_INI_DIR}/conf.d/docker-php-ext-opcache.ini"
execTpl 'xdebug.ini.tpl' "${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini"
execTpl 'php-fpm.conf.tpl' '/usr/local/etc/php-fpm.conf'

fixPermissions
execInitScripts

if [[ "${1}" == 'make' ]]; then
    exec "$@" -f /usr/local/bin/actions.mk
else
    if [[ "${1}" == '/usr/sbin/sshd' ]]; then
        ssh-keygen -b 2048 -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key -q
    elif [[ "${1}" == 'crond' ]]; then
        chown -R root:root /etc/crontabs
    fi

    exec /usr/local/bin/docker-php-entrypoint "$@"
fi
