#!/usr/bin/env bash

set -e

[[ ! -z ${DEBUG} ]] && set -x

GIT_URL=git@bitbucket.org:wodby/php-git-test.git

docker-compose -f test/docker-compose.yml up -d
docker-compose -f test/docker-compose.yml exec nginx make check-ready -f /usr/local/bin/actions.mk
docker-compose -f test/docker-compose.yml exec --user=82 php tests
docker-compose -f test/docker-compose.yml exec --user=82 php make update-keys -f /usr/local/bin/actions.mk
docker-compose -f test/docker-compose.yml exec --user=82 php make git-clone url=${GIT_URL} branch=master -f /usr/local/bin/actions.mk
docker-compose -f test/docker-compose.yml exec --user=82 php make git-pull -f /usr/local/bin/actions.mk
#docker-compose -f test/docker-compose.yml exec --user=82 sshd make update-keys -f /usr/local/bin/actions.mk
docker-compose -f test/docker-compose.yml down
