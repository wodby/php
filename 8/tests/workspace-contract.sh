#!/usr/bin/env bash
# Ensure ordinary images do not advertise the development-only contract.
set -euo pipefail
label=$(docker image inspect --format '{{index .Config.Labels "com.wodby.workspace.contract"}}' "$IMAGE")
if docker image inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "$IMAGE" | grep -Eq '^PHP_DEV=.+$'; then
    test "$label" = 1
else
    test -z "$label"
fi
