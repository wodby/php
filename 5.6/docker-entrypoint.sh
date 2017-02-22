#!/usr/bin/env bash

set -e

if [[ -n $DEBUG ]]; then
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

execTpl 'php.ini.tpl' "$PHP_INI_DIR/php.ini"
execTpl 'opcache.ini.tpl' "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini"
execTpl 'xdebug.ini.tpl' "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini"
execTpl 'php-fpm.conf.tpl' '/usr/local/etc/php-fpm.conf'

fixPermissions
execInitScripts

exec /usr/local/bin/docker-php-entrypoint.sh "$@"
