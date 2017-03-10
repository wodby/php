#!/usr/bin/env bash

#set -e

if [[ -n ${DEBUG} ]]; then
  set -x
fi

GIT_URL=git@bitbucket.org:wodby/php-git-test.git

dockerExec() {
    docker-compose -f test/docker-compose.yml exec --user=82 "${@}"
}

docker-compose -f test/docker-compose.yml up -d
dockerExec nginx make check-ready -f /usr/local/bin/actions.mk
dockerExec php tests
dockerExec php make update-keys -f /usr/local/bin/actions.mk
dockerExec php make git-clone url=${GIT_URL} branch=master -f /usr/local/bin/actions.mk
dockerExec php make git-pull -f /usr/local/bin/actions.mk
dockerExec php make git-checkout target=develop -f /usr/local/bin/actions.mk
dockerExec php ssh sshd cat ~/.ssh/authorized_keys | grep -q admin@wodby.com
dockerExec php curl nginx | grep -q "Hello World!"
docker-compose -f test/docker-compose.yml down
