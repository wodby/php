#!/usr/bin/env bash

set -e

[[ ! -z ${DEBUG} ]] && set -x

cd /var/www/html
git reset --hard HEAD
git clean -df
git pull