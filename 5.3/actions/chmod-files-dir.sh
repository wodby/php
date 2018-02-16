#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

dir=$1

if [[ "${dir}" =~ ^/mnt/files ]]; then
    chmod -R 775 "${dir}"
else
    echo "Only dir/files under /mnt/files allowed"
    exit 1
fi
