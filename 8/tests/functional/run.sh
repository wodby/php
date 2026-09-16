#!/usr/bin/env bash
set -euo pipefail
cd /usr/local/bin/functional
# Keep the coverage engines isolated; Xdebug and PCOV both hook the executor.
export XDEBUG_MODE=off
php_args=(-d newrelic.enabled=0 -d xdebug.log= -d opcache.enable_cli=0)
php "${php_args[@]}" -d apc.enable_cli=1 local.php
timeout 15 php "${php_args[@]}" grpc.php
php "${php_args[@]}" services.php
php "${php_args[@]}" upload.php
php "${php_args[@]}" -d pcov.enabled=1 -d pcov.directory="$PWD" coverage.php pcov
XDEBUG_MODE=coverage php "${php_args[@]}" -d pcov.enabled=0 coverage.php xdebug
