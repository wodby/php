#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

dir="${1:-/etc/ssh}"

mkdir -p "${dir}"
ssh-keygen -qb 2048 -t rsa -N "" -f "${dir}/ssh_host_rsa_key"
chmod 0600 "${dir}/ssh_host_rsa_key"
chmod 0644 "${dir}/ssh_host_rsa_key.pub"
