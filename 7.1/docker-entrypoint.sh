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
        mkdir -p "${SSH_DIR}"
        execTpl "id_rsa.tpl" "${SSH_DIR}/id_rsa"
        chmod -f 600 "${SSH_DIR}/id_rsa"
        chown -R www-data:www-data "${SSH_DIR}"
        unset SSH_PRIVATE_KEY
    fi
}

initSSH() {
    mkdir -p "${SSH_DIR}"

    if [[ -n "${SSH_PUBLIC_KEYS}" ]]; then
        execTpl "authorized_keys.tpl" "${SSH_DIR}/authorized_keys"
        unset SSH_PUBLIC_KEYS
    fi

    su-exec www-data printenv | xargs -I{} echo {} | awk ' \
        BEGIN { FS = "=" }; { \
            if ($1 != "HOME" \
                && $1 != "PWD" \
                && $1 != "PATH" \
                && $1 != "SHLVL") { \
                \
                print ""$1"="$2"" \
            } \
        }' > /home/www-data/.ssh/environment

    chown -R www-data:www-data "${SSH_DIR}"
}

processConfigs() {
    execTpl "docker-php.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php.ini"
    execTpl "docker-php-ext-apcu.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-apcu.ini"
    execTpl "docker-php-ext-geoip.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-geoip.ini"
    execTpl "docker-php-ext-opcache.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-opcache.ini"
    execTpl "docker-php-ext-xdebug.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini"
    execTpl "zz-www.conf.tpl" "/usr/local/etc/php-fpm.d/zz-www.conf"

    if [[ "${PHP_ENABLED_DEBUG}" == 0 ]]; then
        execTpl "docker-php-ext-blackfire.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-blackfire.ini"
    fi

    sed -i '/^$/d' "${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini"
}

initGitConfig() {
    su-exec www-data git config --global user.email "www-data@example.com"
    su-exec www-data git config --global user.name "www-data"
}

addPrivateKey
fixPermissions
execInitScripts
initGitConfig
processConfigs

if [[ $1 == "make" ]]; then
    su-exec www-data "${@}" -f /usr/local/bin/actions.mk
else
    if [[ $1 == "/usr/sbin/sshd" ]]; then
        initSSH
        ssh-keygen -b 2048 -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key -q
    elif [[ $1 == "crond" ]]; then
        execTpl "crontab.tpl" "/etc/crontabs/www-data"
    fi

    exec /usr/local/bin/docker-php-entrypoint "${@}"
fi
