#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

from="${1:-}"
to="${2:-}"

# Default user changed from www-data (82) to wodby (1000), change recursively codebase permissions on volume.
if [[ "${to:0:1}" == 5 && "${from:0:1}" < 5 ]]; then
    echo "Migrating to a new major 5.x version"
    echo "Recursively update codebase files owner from www-data to wodby:wodby except symlinks (public files dir)"
    find "${APP_ROOT}" -uid 82 ! -type l -exec chown wodby:wodby {} +
    chown wodby:wodby "${FILES_DIR}/private" "${FILES_DIR}/public"
    chmod 775 "${FILES_DIR}/private" "${FILES_DIR}/public"
fi
