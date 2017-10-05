#!/bin/bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

git_url=git@bitbucket.org:wodby/php-git-test.git

wait_for_cron() {
    executed=0

    for i in $(seq 1 13); do
        if docker_exec crond cat /home/www-data/cron | grep -q "test"; then
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

docker_exec() {
    docker-compose -f test/docker-compose.yml exec "${@}"
}

run_action() {
    docker_exec "${1}" make "${@:2}" -f /usr/local/bin/actions.mk
}

docker-compose -f test/docker-compose.yml up -d
docker-compose -f test/docker-compose.yml logs

run_action nginx check-ready max_try=10
run_action php check-ready max_try=10

# PHP tools
docker_exec php tests.sh

# SSH
echo -n "Testing ssh... "
docker_exec php touch /home/www-data/.ssh/known_hosts
docker_exec php ssh www-data@sshd cat /home/www-data/.ssh/authorized_keys | grep -q admin@wodby.com
echo "OK"

# Git actions
echo -n "Running git actions... "
docker_exec php bash -c 'echo -e "Host bitbucket.org\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config'
run_action php git-clone url="${git_url}" branch=master
run_action php git-checkout target=develop
echo "OK"

# PHP-FPM
echo -n "Checking PHP-FPM... "
docker_exec php curl nginx | grep -q "Hello World!"
echo "OK"

# Walter CD
echo -n "Running walter scripts... "
run_action php walter
docker_exec php cat ./walter-shell-stage
docker_exec php cat ./walter-command-stage
echo "OK"

# Crond
wait_for_cron

docker-compose -f test/docker-compose.yml down
