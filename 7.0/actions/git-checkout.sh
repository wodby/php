#!/usr/bin/env bash

set -e

if [[ -n $DEBUG ]]; then
  set -x
fi

cd /var/www/html
git checkout "${1}"