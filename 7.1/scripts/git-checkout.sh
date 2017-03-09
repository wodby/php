#!/usr/bin/env bash

set -e

[[ ! -z ${DEBUG} ]] && set -x

cd /var/www/html
git -c http.sslVerify=false checkout "${1}"