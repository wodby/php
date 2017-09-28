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

    if [[ -n "${PHP_XDEBUG_TRACE_OUTPUT_DIR}" ]]; then
        mkdir -p "${PHP_XDEBUG_TRACE_OUTPUT_DIR}"
        chown www-data:www-data "${PHP_XDEBUG_TRACE_OUTPUT_DIR}"
    fi

    if [[ -n "${PHP_XDEBUG_PROFILER_OUTPUT_DIR}" ]]; then
        mkdir -p "${PHP_XDEBUG_PROFILER_OUTPUT_DIR}"
        chown www-data:www-data "${PHP_XDEBUG_PROFILER_OUTPUT_DIR}"
    fi
}

addPrivateKey() {
    if [[ -n "${SSH_PRIVATE_KEY}" ]]; then
        execTpl "id_rsa.tpl" "${SSH_DIR}/id_rsa"
        chmod -f 600 "${SSH_DIR}/id_rsa"
        unset SSH_PRIVATE_KEY
    fi
}

initSSHd() {
    if [[ -n "${SSH_PUBLIC_KEYS}" ]]; then
        execTpl "authorized_keys.tpl" "${SSH_DIR}/authorized_keys"
        unset SSH_PUBLIC_KEYS
    fi

    sshd-init-env.sh
    sudo sshd-generate-keys.sh
}

processConfigs() {
    execTpl "docker-php.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php.ini"
    execTpl "docker-php-ext-geoip.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-geoip.ini"
    execTpl "docker-php-ext-opcache.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-opcache.ini"
    execTpl "docker-php-ext-xdebug.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini"
    execTpl "zz-www.conf.tpl" "/usr/local/etc/php-fpm.d/zz-www.conf"

    if [[ "${PHP_DEBUG}" == 0 ]]; then
        execTpl "docker-php-ext-blackfire.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-blackfire.ini"
    fi

    sed -i '/^$/d' "${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini"
}

initGitConfig() {
    git config --global user.email "www-data@example.com"
    git config --global user.name "www-data"
}

sudo fix-permissions.sh www-data www-data "${APP_ROOT}"

addPrivateKey
fixPermissions
execInitScripts
initGitConfig
processConfigs

if [[ $1 == "make" ]]; then
    exec "${@}" -f /usr/local/bin/actions.mk
else
    if [[ "${1} ${2}" == "sudo /usr/sbin/sshd" ]]; then
        initSSHd
    elif [[ "${1} ${2}" == "sudo crond" ]]; then
        execTpl "crontab.tpl" "/etc/crontabs/www-data"
    fi

    exec /usr/local/bin/docker-php-entrypoint "${@}"
fi
