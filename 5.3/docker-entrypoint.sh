#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

SSH_DIR=/home/www-data/.ssh

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
    chown www-data:www-data "${APP_ROOT}"
}

addPrivateKey() {
    if [[ -n "${SSH_PRIVATE_KEY}" ]]; then
        mkdir -p "${SSH_DIR}"
        execTpl "id_rsa.tpl" "${SSH_DIR}/id_rsa"
        chmod -f 600 "${SSH_DIR}/id_rsa"
        chown -R www-data:www-data "${SSH_DIR}"
    fi
}

addAuthorizedKeys() {
    if [[ -n "${SSH_PUBLIC_KEYS}" ]]; then
        mkdir -p "${SSH_DIR}"
        execTpl "authorized_keys.tpl" "${SSH_DIR}/authorized_keys"
        chown -R www-data:www-data "${SSH_DIR}"
    fi
}

processConfigs() {
    execTpl "php.ini.tpl" "${PHP_INI_DIR}/php.ini"
    execTpl "opcache.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-opcache.ini"
    execTpl "xdebug.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini"
    execTpl "zz-www.conf.tpl" "/usr/local/etc/php-fpm.d/zz-www.conf"
    execTpl "env.tpl" "/usr/local/etc/php-fpm.d/env"
}

addPrivateKey
fixPermissions
execInitScripts

if [[ $1 == "make" ]]; then
    su-exec www-data "${@}" -f /usr/local/bin/actions.mk
else
    if [[ $1 == "/usr/sbin/sshd" ]]; then
        addAuthorizedKeys
        ssh-keygen -b 2048 -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key -q
    elif [[ $1 == "crond" ]]; then
        execTpl "crontab.tpl" "/etc/crontabs/www-data"
    fi

    processConfigs

    exec /usr/local/bin/docker-php-entrypoint "${@}"
fi
