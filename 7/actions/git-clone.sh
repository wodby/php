#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

url=$1
branch=$2

if [[ -n "${branch}" ]]; then
    git clone -b "${branch}" "${url}" "${APP_ROOT}"
else
    git clone "${url}" "${APP_ROOT}"
fi
