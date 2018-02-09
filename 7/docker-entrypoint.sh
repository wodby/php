#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

PHP_VER_MINOR="${PHP_VERSION:0:3}"
SSH_DIR=/home/wodby/.ssh

# Backwards compatibility for old env vars names.
_backwards_compatibility() {
    declare -A vars
    # vars[DEPRECATED]="ACTUAL"
    vars[PHP_APCU_ENABLE]="PHP_APCU_ENABLED"
    vars[PHP_FPM_SLOWLOG_TIMEOUT]="PHP_FPM_REQUEST_SLOWLOG_TIMEOUT"
    vars[PHP_FPM_MAX_CHILDREN]="PHP_FPM_PM_MAX_CHILDREN"
    vars[PHP_FPM_START_SERVERS]="PHP_FPM_PM_START_SERVERS"
    vars[PHP_FPM_MIN_SPARE_SERVERS]="PHP_FPM_PM_MIN_SPARE_SERVERS"
    vars[PHP_FPM_MAX_SPARE_SERVERS]="PHP_FPM_PM_MAX_SPARE_SERVERS"
    vars[PHP_FPM_MAX_REQUESTS]="PHP_FPM_PM_MAX_REQUESTS"
    vars[PHP_FPM_STATUS_PATH]="PHP_FPM_PM_STATUS_PATH"

    for i in "${!vars[@]}"; do
        # Use value from old var if it's not empty and the new is.
        if [[ -n "${!i}" && -z "${!vars[$i]}" ]]; then
            export "${vars[$i]}"="${!i}"
        fi
    done
}

exec_tpl() {
    if [[ -f "/etc/gotpl/$1" ]]; then
        gotpl "/etc/gotpl/$1" > "$2"
    fi
}

validate_dirs() {
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

    sudo gen-ssh-keys.sh "rsa" "${SSHD_HOST_KEYS_DIR}"
}

init_crond() {
    exec_tpl "crontab.tpl" "/etc/crontabs/wodby"
}

process_templates() {
    _backwards_compatibility

    if [[ -n "${PHP_DEV}" ]]; then
        export PHP_FPM_CLEAR_ENV="${PHP_FPM_CLEAR_ENV:-no}"
    fi

    if [[ -n "${PHP_DEBUG}" ]]; then
        export PHP_FPM_LOG_LEVEL="${PHP_FPM_LOG_LEVEL:-debug}"
    else
        # Extensions that don't work with --enabled-debug
        exec_tpl "docker-php-ext-blackfire.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-blackfire.ini"
        exec_tpl "docker-php-ext-newrelic.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-newrelic.ini"
    fi

    exec_tpl "docker-php-${PHP_VER_MINOR}.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php.ini"
    exec_tpl "docker-php-ext-apcu.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-apcu.ini"
    exec_tpl "docker-php-ext-geoip.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-geoip.ini"
    exec_tpl "docker-php-ext-opcache.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-opcache.ini"
    exec_tpl "docker-php-ext-xdebug.ini.tpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini"
    exec_tpl "zz-www.conf.tpl" "/usr/local/etc/php-fpm.d/zz-www.conf"
    exec_tpl "wodby.settings.php.tpl" "${CONF_DIR}/wodby.settings.php"
}

init_git() {
    git config --global user.email "${GIT_USER_EMAIL}"
    git config --global user.name "${GIT_USER_NAME}"
}

sudo fix-volumes-permissions.sh
mkdir -p "${FILES_DIR}/private" "${FILES_DIR}/public"
chmod 775 "${FILES_DIR}/private" "${FILES_DIR}/public"

validate_dirs
init_ssh_client
init_git
process_templates

if [[ "${@:1:2}" == "sudo /usr/sbin/sshd" ]]; then
    init_sshd
elif [[ "${@:1:3}" == "sudo -E crond" ]]; then
    init_crond
fi

exec-init-scripts.sh

if [[ $1 == "make" ]]; then
    exec "${@}" -f /usr/local/bin/actions.mk
else
    exec /usr/local/bin/docker-php-entrypoint "${@}"
fi
