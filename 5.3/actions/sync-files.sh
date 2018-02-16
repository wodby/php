#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

rsync -rltpog --chown=www-data:www-data $1 $2