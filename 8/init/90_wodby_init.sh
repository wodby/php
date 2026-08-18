#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

# Applies the service init action on container start.
#
# The init action prepares the application codebase for this image, for example
# by wiring the generated Wodby config into the application's own settings file
# and symlinking public files to the persistent volume. Its steps are guarded
# and idempotent, so when the image was built with the init action already
# applied this is a no-op.
#
# WODBY_INIT_ACTION names a target in /usr/local/bin/actions.mk and is provided
# as an environment variable rather than baked into the image, so the init
# action is applied no matter which Dockerfile produced the image.
#
# This file is sourced by exec_init_scripts, not executed in a subshell. Do not
# use "exit" here, it would terminate the entrypoint and stop the container.
if [[ -n "${WODBY_INIT_ACTION}" ]]; then
    echo "Applying init action: ${WODBY_INIT_ACTION}"
    make "${WODBY_INIT_ACTION}" -f /usr/local/bin/actions.mk
fi
