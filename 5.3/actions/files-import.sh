#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

source=$1
tmp_dir="/tmp/source"

get-archive.sh "${source}" "${tmp_dir}" "zip tgz tar.gz tar"

if [[ -d "${tmp_dir}/.wodby" ]]; then
    echo "Wodby backup archive detected. Importing to top directory"
    rsync -rlt --force "${tmp_dir}/" "${FILES_DIR}"
else
    echo "Importing files to public directory"
    rsync -rlt --force "${tmp_dir}/" "${FILES_DIR}/public/"
fi

rm -rf "${tmp_dir}"