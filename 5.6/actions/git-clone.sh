#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

URL=$1
BRANCH=$2

git clone -b "${BRANCH}" "${URL}" "${APP_ROOT}"