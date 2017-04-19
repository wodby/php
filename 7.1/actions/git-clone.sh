#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

URL=$1
BRANCH=$2
USER_EMAIL=$3
USER_NAME=$4

git config --global user.email "${USER_EMAIL}"
git config --global user.name "${USER_NAME}"

git clone -b "${BRANCH}" "${URL}" "${APP_ROOT}"