#!/usr/bin/env bash

set -e

[[ ! -z ${DEBUG} ]] && set -x

GIT_URL="${1}"
GIT_BRANCH="${2}"

git -c http.sslVerify=false clone -b "${GIT_BRANCH}" "${GIT_URL}" /var/www/html