#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

chown wodby:wodby "${APP_ROOT}"

declare -a dirs=(
    "${FILES_DIR}"
    "${FILES_DIR}/private"
    "${FILES_DIR}/public"
    "${FILES_DIR}/xdebug/profiler"
    "${FILES_DIR}/xdebug/traces"
)

for dir in "${dirs[@]}"; do
    mkdir -p "${dir}"
    chown www-data:www-data "${dir}"
    chmod 775 "${dir}"
done
