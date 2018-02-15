#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

from="${1:-}"
to="${2:-}"

# Default user changed from www-data (82) to wodby (1000), change recursively codebase permissions on volume.
if [[ "${to:0:1}" == 5 && "${from:0:1}" < 5 ]]; then
    echo "1. Migrating to a new major 5.x version. Fixing permissions for:"
    echo "- Codebase volume except symlinks (public files dir)"
    find "${APP_ROOT}" -uid 82 ! -type l -exec chown wodby:wodby {} +
    echo "- Files volume (only top level dirs and files)"
    find "${FILES_DIR}" ! -path "${FILES_DIR}" -uid 82 -maxdepth 1 -exec chown wodby:wodby {} \; -exec chmod 775 {} \;

    if [[ -n "${PHP_XDEBUG_TRACE_OUTPUT_DIR}" ]]; then
        echo "Repeating actions for xdebug trace output dir"
        chown wodby:wodby "${PHP_XDEBUG_TRACE_OUTPUT_DIR}"
        chmod 775 "${PHP_XDEBUG_TRACE_OUTPUT_DIR}"
    fi

    if [[ -n "${PHP_XDEBUG_PROFILER_OUTPUT_DIR}" ]]; then
        echo "Repeating actions for xdebug profiler output dir"
        chown wodby:wodby "${PHP_XDEBUG_PROFILER_OUTPUT_DIR}"
        chmod 775 "${PHP_XDEBUG_PROFILER_OUTPUT_DIR}"
    fi
fi
