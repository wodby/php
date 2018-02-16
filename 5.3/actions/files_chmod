#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

dir=$1

if [[ "${dir}" =~ "^${FILES_DIR}" ]]; then
    chmod -R 775 "${dir}"
else
    echo "Only dir/files under ${FILES_DIR} allowed"
    exit 1
fi
