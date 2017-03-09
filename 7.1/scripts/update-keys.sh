#!/usr/bin/env bash

set -e

[[ ! -z ${DEBUG} ]] && set -x

USER=www-data
GROUP=www-data

mkdir -p /home/${USER}/.ssh

if [ ! -f /mnt/ssh/id_rsa ]; then
    cp /mnt/ssh/id_rsa /home/${USER}/.ssh/id_rsa
    fixPermission
fi

if [ ! -f /mnt/ssh/authorized_keys ]; then
    cp /mnt/ssh/authorized_keys /home/${USER}/.ssh/authorized_keys
    fixPermission
fi

fixPermission() {
    chown -R ${USER}:${GROUP} ~/.ssh
    chmod -R 600 ~/.ssh
}