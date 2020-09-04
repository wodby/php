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

# @deprecated will be removed in favor of bind mounts (config maps).
init_ssh_client() {
    if [[ -n "${SSH_PRIVATE_KEY}" ]]; then
        _gotpl "id_rsa.tmpl" "${ssh_dir}/id_rsa"
        chmod -f 600 "${ssh_dir}/id_rsa"
        unset SSH_PRIVATE_KEY
    fi
}

init_sshd() {
    _gotpl "sshd_config.tmpl" "/etc/ssh/sshd_config"

    # @deprecated will be removed in favor of bind mounts (config maps).
    if [[ -n "${SSH_PUBLIC_KEYS}" ]]; then
        _gotpl "authorized_keys.tmpl" "${ssh_dir}/authorized_keys"
        unset SSH_PUBLIC_KEYS
    fi

    printenv | xargs -I{} echo {} | awk ' \
        BEGIN { FS = "=" }; { \
            if ($1 != "HOME" \
                && $1 != "PWD" \
                && $1 != "SHLVL") { \
                \
                print ""$1"="$2"" \
            } \
        }' > "${ssh_dir}/environment"

    sudo gen_ssh_keys "rsa" "${SSHD_HOST_KEYS_DIR}"
}

# @deprecated will be removed in favor of bind mounts (config maps).
init_crond() {
    if [[ -n "${CRONTAB}" ]]; then
        _gotpl "crontab.tmpl" "/etc/crontabs/www-data"
    fi
}

process_templates() {
    local php_ver_minor="${PHP_VERSION:0:3}"
    export PHP_VER_MINOR="${php_ver_minor}"

    if [[ -n "${PHP_DEV}" ]]; then
        export PHP_FPM_CLEAR_ENV="${PHP_FPM_CLEAR_ENV:-no}"
    fi

    # Extensions that don't work with --enabled-debug
    _gotpl "docker-php-ext-blackfire.ini.tmpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-blackfire.ini"
    _gotpl "docker-php-ext-newrelic.ini.tmpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-newrelic.ini"

    _gotpl "docker-php-${php_ver_minor}.ini.tmpl" "${PHP_INI_DIR}/conf.d/docker-php.ini"
    _gotpl "docker-php-ext-apcu.ini.tmpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-apcu.ini"
    _gotpl "docker-php-ext-igbinary.ini.tmpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-igbinary.ini"
    _gotpl "docker-php-ext-tideways_xhprof.ini.tmpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-tideways_xhprof.ini"
    _gotpl "docker-php-ext-xdebug.ini.tmpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini"
    _gotpl "docker-php-ext-opcache.ini.tmpl" "${PHP_INI_DIR}/conf.d/docker-php-ext-opcache.ini"

    _gotpl "zz-www.conf.tmpl" "/usr/local/etc/php-fpm.d/zz-www.conf"
    _gotpl "wodby.settings.php.tmpl" "${CONF_DIR}/wodby.settings.php"
    _gotpl "ssh_config.tmpl" "${ssh_dir}/config"
    _gotpl "gitconfig.tmpl" "/etc/gitconfig"
}

disable_modules() {
    local dir="${PHP_INI_DIR}/conf.d"

    if [[ -n "${PHP_EXTENSIONS_DISABLE}" ]]; then
        IFS=',' read -r -a modules <<< "${PHP_EXTENSIONS_DISABLE}"

        for module in "${modules[@]}"; do
            if [[ -f "${dir}/z-docker-php-ext-${module}.ini" ]]; then
                rm "${dir}/z-docker-php-ext-${module}.ini";
            elif [[ -f "${dir}/docker-php-ext-${module}.ini" ]]; then
                rm "${dir}/docker-php-ext-${module}.ini";
            else
                echo "WARNING: instructed to disable module ${module} but it was not found"
            fi
        done
    fi
}

sudo init_container

init_ssh_client
process_templates
disable_modules

if [[ "${@:1:2}" == "sudo /usr/sbin/sshd" ]]; then
    init_sshd
elif [[ "${@:1:3}" == "sudo -E crond" || "${@:1:4}" == "sudo -E LD_PRELOAD=/usr/lib/preloadable_libiconv.so crond" ]]; then
    init_crond
fi

exec_init_scripts

if [[ "${1}" == "make" ]]; then
    exec "${@}" -f /usr/local/bin/actions.mk
else
    exec /usr/local/bin/docker-php-entrypoint "${@}"
fi
