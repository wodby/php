#!/usr/bin/env bash

set -e

if [[ -n $DEBUG ]]; then
  set -x
fi

cd /var/www/html
git stash
git fetch --all
