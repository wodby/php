#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

if [[ -f "${APP_ROOT}/wodby.yml" ]]; then
    walter -c "${APP_ROOT}/wodby.yml"
fi