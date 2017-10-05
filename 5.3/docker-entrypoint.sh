#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

SSH_DIR=/home/www-data/.ssh

exec_tpl() {
    gotpl "/etc/gotpl/$1" > "$2"
}

exec_init_scripts() {
    shopt -s nullglob
    for f in /docker-entrypoint-init.d/*.sh; do
        echo "$0: running $f"
        . "$f"
    done
    shopt -u nullglob
}

fix_permissions() {
    sudo fix-permissions.sh www-data www-data "${APP_ROOT}"

    if [[ -n "${PHP_XDEBUG_TRACE_OUTPUT_DIR}" ]]; then
        mkdir -p "${PHP_XDEBUG_TRACE_OUTPUT_DIR}"
    fi

    if [[ -n "${PHP_XDEBUG_PROFILER_OUTPUT_DIR}" ]]; then
        mkdir -p "${PHP_XDEBUG_PROFILER_OUTPUT_DIR}"
    fi
}

init_ssh_client() {
    exec_tpl "ssh_config.tpl" "${SSH_DIR}/config"

    if [[ -n "${SSH_PRIVATE_KEY}" ]]; then
        exec_tpl "id_rsa.tpl" "${SSH_DIR}/id_rsa"
        chmod -f 600 "${SSH_DIR}/id_rsa"
        unset SSH_PRIVATE_KEY
    fi
}

init_sshd() {
    exec_tpl "sshd_config.tpl" "/etc/ssh/sshd_config"

    if [[ -n "${SSH_PUBLIC_KEYS}" ]]; then
        exec_tpl "authorized_keys.tpl" "${SSH_DIR}/authorized_keys"
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
        }' > "${SSH_DIR}/environment"

    sudo sshd-generate-keys.sh "${SSHD_HOST_KEYS_DIR}"
}

init_crond() {
    exec_tpl "crontab.tpl" "/etc/crontabs/www-data"
}

process_templates() {
    exec_tpl "docker-php.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php.ini"
    exec_tpl "docker-php-ext-opcache.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-opcache.ini"
    exec_tpl "docker-php-ext-xdebug.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini"
    exec_tpl "zz-www.conf.tpl" "/usr/local/etc/php-fpm.d/zz-www.conf"

    sed -i '/^$/d' "${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini"
}

fix_permissions
init_ssh_client
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
