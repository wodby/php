#!/usr/bin/env bash

set -e

if [[ -n $DEBUG ]]; then
  set -x
fi

GIT_URL="${1}"
GIT_BRANCH="${2}"

git clone -b "${GIT_BRANCH}" "${GIT_URL}" /var/www/html