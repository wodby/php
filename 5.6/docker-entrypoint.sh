#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

ssh_dir=/home/wodby/.ssh

_gotpl() {
    if [[ -f "/etc/gotpl/$1" ]]; then
        gotpl "/etc/gotpl/$1" > "$2"
    fi
}

init_ssh_client() {
    _gotpl "ssh_config.tpl" "${ssh_dir}/config"

    if [[ -n "${SSH_PRIVATE_KEY}" ]]; then
        _gotpl "id_rsa.tpl" "${ssh_dir}/id_rsa"
        chmod -f 600 "${ssh_dir}/id_rsa"
        unset SSH_PRIVATE_KEY
    fi
}

init_sshd() {
    _gotpl "sshd_config.tpl" "/etc/ssh/sshd_config"

    if [[ -n "${SSH_PUBLIC_KEYS}" ]]; then
        _gotpl "authorized_keys.tpl" "${ssh_dir}/authorized_keys"
        unset SSH_PUBLIC_KEYS
    fi

    printenv | xargs -I{} echo {} | awk ' \
        BEGIN { FS = "=" }; { \
            if ($1 != "HOME" \
                && $1 != "PWD" \
                && $1 != "PATH" \
                && $1 != "SHLVL") { \
                \
                print ""$1"="$2"" \
            } \
        }' > "${ssh_dir}/environment"

    sudo gen_ssh_keys "rsa" "${SSHD_HOST_KEYS_DIR}"
}

init_crond() {
    _gotpl "crontab.tpl" "/etc/crontabs/www-data"
}

process_templates() {
    if [[ -n "${PHP_DEV}" ]]; then
        export PHP_FPM_CLEAR_ENV="${PHP_FPM_CLEAR_ENV:-no}"
    fi

    if [[ -n "${PHP_DEBUG}" ]]; then
        export PHP_FPM_LOG_LEVEL="${PHP_FPM_LOG_LEVEL:-debug}"
    else
        # Extensions that don't work with --enabled-debug
        _gotpl "docker-php-ext-blackfire.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-blackfire.ini"
        _gotpl "docker-php-ext-newrelic.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-newrelic.ini"
    fi

    _gotpl "docker-php.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php.ini"
    _gotpl "docker-php-ext-apcu.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-apcu.ini"
    _gotpl "docker-php-ext-geoip.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-geoip.ini"
    _gotpl "docker-php-ext-opcache.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-opcache.ini"
    _gotpl "docker-php-ext-xdebug.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini"
    _gotpl "zz-www.conf.tpl" "/usr/local/etc/php-fpm.d/zz-www.conf"
    _gotpl "wodby.settings.php.tpl" "${CONF_DIR}/wodby.settings.php"
}

init_git() {
    git config --global user.email "${GIT_USER_EMAIL}"
    git config --global user.name "${GIT_USER_NAME}"
}

sudo init_volumes

init_ssh_client
init_git
process_templates

if [[ "${@:1:2}" == "sudo /usr/sbin/sshd" ]]; then
    init_sshd
elif [[ "${@:1:3}" == "sudo -E crond" ]]; then
    init_crond
fi

exec_init_scripts

if [[ $1 == "make" ]]; then
    exec "${@}" -f /usr/local/bin/actions.mk
else
    exec /usr/local/bin/docker-php-entrypoint "${@}"
fi
