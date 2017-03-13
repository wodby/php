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

docker-compose -f test/docker-compose.yml up -d

dockerExec nginx make check-ready -f /usr/local/bin/actions.mk

# PHP tools
dockerExec php tests

# SSH
dockerExec php touch /home/www-data/.ssh/known_hosts
dockerExec php bash -c 'ssh-keyscan sshd >> /home/www-data/.ssh/known_hosts'
dockerExec php ssh www-data@sshd cat /home/www-data/.ssh/authorized_keys | grep -q admin@wodby.com

# Git actions
dockerExec php bash -c 'ssh-keyscan bitbucket.org >> /home/www-data/.ssh/known_hosts'
dockerExec php make update-keys -f /usr/local/bin/actions.mk
dockerExec php make git-clone url="${GIT_URL}" branch=master -f /usr/local/bin/actions.mk
dockerExec php make git-checkout target=develop -f /usr/local/bin/actions.mk

# PHP-FPM
dockerExec php curl nginx | grep -q "Hello World!"

# Walter CD
dockerExec php make walter -f /usr/local/bin/actions.mk
dockerExec php walter -build -config ./wodby.yml
dockerExec php cat ./walter-shell-stage
dockerExec php cat ./walter-command-stage

# Crond
waitForCron

docker-compose -f test/docker-compose.yml down
