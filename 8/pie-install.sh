#!/usr/bin/env bash

# Keep authentication scoped to PIE. BuildKit mounts this file only during RUN;
# no auth.json is written and the token is never passed as a command argument.
_pie_command() (
    set +x
    if [[ -f "${PIE_COMPOSER_AUTH_FILE:-/run/secrets/composer_auth}" ]]; then
        COMPOSER_AUTH=$(cat "${PIE_COMPOSER_AUTH_FILE:-/run/secrets/composer_auth}") || return 1
        export COMPOSER_AUTH
    fi
    HOME="${build_dir}/home" pie "$@"
)

# Limit retries to transport/rate-limit failures; bad credentials, dependency
# resolution and compiler errors must still stop the build immediately.
install_pie() {
    local attempt status
    for attempt in 1 2 3; do
        if _pie_command install --no-interaction --no-cache \
            --skip-enable-extension -j "${jobs}" "$@" 2>&1 | tee "${build_dir}/pie.log"; then
            return 0
        else
            status=$?
        fi
        # Retry transport failures, but report dependency and compiler errors immediately.
        if [[ "${attempt}" == 3 ]] || ! grep -Eq \
            'curl error (5|6|7|18|28|35|52|55|56) |HTTP/[0-9.]+ (408|429|50[0-9])|API rate limit exceeded|[Rr]ate limit exceeded|[Tt]oo many requests|[Cc]onnection (reset|timed out)' "${build_dir}/pie.log"; then
            return "${status}"
        fi
        echo "Retrying PIE after a transient download failure (${attempt}/3)" >&2
        sleep "$((attempt * 2))"
    done
}

