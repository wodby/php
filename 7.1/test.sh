#!/usr/bin/env bash

[[ ! -z ${DEBUG} ]] && set -x

docker-compose -f test/docker-compose.yml up -d
docker-compose -f test/docker-compose.yml exec nginx make check-ready -f /usr/local/bin/actions.mk
docker-compose -f test/docker-compose.yml exec --user=82 php tests
docker-compose -f test/docker-compose.yml down
