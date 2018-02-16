#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

source=$1
tmp_dir="/tmp/source"

get-archive.sh "${source}" "${tmp_dir}" "zip tgz tar.gz tar"

# TODO: allow top level dir import only for wodby archives.
if [[ -f "${tmp_dir}/.wodby" || (-d "${tmp_dir}/private" && -d "${tmp_dir}/public") ]]; then
    echo "Wodby backup archive detected. Importing to top directory"
    sudo sync-files.sh "${tmp_dir}/" "${FILES_DIR}"
else
    echo "Importing files to public directory"
    sudo sync-files.sh "${tmp_dir}/" "${FILES_DIR}/public/"
fi

rm -rf "${tmp_dir}"