#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

SSH_DIR=/home/www-data/.ssh

mkdir -p "${SSH_DIR}"

if [ -f /mnt/ssh/id_rsa ]; then
    cp -f /mnt/ssh/id_rsa "${SSH_DIR}/id_rsa"
    chmod -f 600 "${SSH_DIR}/id_rsa"
fi

if [ -f /mnt/ssh/authorized_keys ]; then
    cp -f /mnt/ssh/authorized_keys "${SSH_DIR}/authorized_keys"
fi
