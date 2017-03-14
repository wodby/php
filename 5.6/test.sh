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

actionExec() {
    docker-compose -f test/docker-compose.yml exec "${1}" su-exec www-data make "${@:2}" -f /usr/local/bin/actions.mk
}

docker-compose -f test/docker-compose.yml up -d

actionExec nginx check-ready

# PHP tools
dockerExec php tests

# SSH
dockerExec php touch /home/www-data/.ssh/known_hosts
dockerExec php bash -c 'ssh-keyscan sshd >> /home/www-data/.ssh/known_hosts'
dockerExec php ssh www-data@sshd cat /home/www-data/.ssh/authorized_keys | grep -q admin@wodby.com

# Git actions
dockerExec php bash -c 'ssh-keyscan bitbucket.org >> /home/www-data/.ssh/known_hosts'
actionExec php git-clone url="${GIT_URL}" branch=master
actionExec php git-checkout target=develop

# PHP-FPM
dockerExec php curl nginx | grep -q "Hello World!"

# Walter CD
actionExec php walter
dockerExec php cat ./walter-shell-stage
dockerExec php cat ./walter-command-stage

# Crond
waitForCron

docker-compose -f test/docker-compose.yml down
