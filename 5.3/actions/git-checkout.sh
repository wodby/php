#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

target=$1
is_hash=$2

cd "${APP_ROOT}"
git stash
git fetch --all
git checkout "${target}"

if [[ "${is_hash}" -eq '0' ]]; then
    git pull origin "${target}"
fi
