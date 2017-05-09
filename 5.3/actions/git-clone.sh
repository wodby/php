#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

url=$1
branch=$2

git clone -b "${branch}" "${url}" "${APP_ROOT}"