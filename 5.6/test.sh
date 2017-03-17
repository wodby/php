#!/bin/bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

GIT_URL=git@bitbucket.org:wodby/php-git-test.git

waitForCron() {
    executed=0

    for i in $(seq 1 13); do
        if dockerExec crond cat /home/www-data/cron &> /dev/null; then
            executed=1
            break
        fi
        echo 'Waiting for cron execution...'
        sleep 5
    done

    if [[ "${executed}" -eq '0' ]]; then
        echo >&2 'Cron failed.'
        exit 1
    fi

    echo 'Cron has been executed!'
}

dockerExec() {
    docker-compose -f test/docker-compose.yml exec --user=82 "${@}"
}

phpAction() {
    docker-compose -f test/docker-compose.yml exec php su-exec www-data make "${@}" -f /usr/local/bin/actions.mk
}

docker-compose -f test/docker-compose.yml up -d
docker-compose -f test/docker-compose.yml exec nginx make check-ready -f /usr/local/bin/actions.mk

# PHP tools
dockerExec php tests

# SSH
echo -n "Testing ssh... "
dockerExec php touch /home/www-data/.ssh/known_hosts
dockerExec php bash -c 'ssh-keyscan sshd >> /home/www-data/.ssh/known_hosts'
dockerExec php ssh www-data@sshd cat /home/www-data/.ssh/authorized_keys | grep -q admin@wodby.com
echo "OK"

# Git actions
echo -n "Running git actions... "
dockerExec php bash -c 'echo -e "Host bitbucket.org\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config'
phpAction git-clone url="${GIT_URL}" branch=master
phpAction git-checkout target=develop
echo "OK"

# PHP-FPM
echo -n "Checking PHP-FPM... "
dockerExec php curl nginx | grep -q "Hello World!"
echo "OK"

# Walter CD
echo -n "Running walter scripts... "
phpAction walter
dockerExec php cat ./walter-shell-stage
dockerExec php cat ./walter-command-stage
echo "OK"

# Crond
waitForCron

docker-compose -f test/docker-compose.yml down
