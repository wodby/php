#!/usr/bin/env bash

set -e

[[ ! -z ${DEBUG} ]] && set -x

mkdir -p ~/.ssh

if [ -f /mnt/ssh/id_rsa ]; then
    cp -f /mnt/ssh/id_rsa ~/.ssh/id_rsa
    chmod -f 600 ~/.ssh/id_rsa
fi

if [ -f /mnt/ssh/authorized_keys ]; then
    cp -f /mnt/ssh/authorized_keys ~/.ssh/authorized_keys
fi
