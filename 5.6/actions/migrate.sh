#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

from="${1:-}"
to="${2:-}"

# Default user changed from www-data (82) to wodby (1000), change recursively volume codebase permissions.
if [[ "${to:0:1}" == 5 && "${from:0:1}" < 5 ]]; then
    echo "Migrating to a new major 5.x version"
    echo "Recursively updated codebase volume owner from www-data to wodby:wodby"
    find "${APP_ROOT}" -uid 82 -exec chown wodby:wodby {} +
fi
