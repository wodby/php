#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

TARGET=$1
IS_HASH=$2

cd "${APP_ROOT}"
git stash
git fetch --all
git checkout "${TARGET}"

if [[ "${IS_HASH}" -eq '0' ]]; then
    git rebase "${TARGET}"
fi
