#!/bin/bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

git_url=https://github.com/wodby/php.git

wait_for_cron() {
    executed=0

    for i in $(seq 1 13); do
        if docker_exec crond cat /mnt/files/cron | grep -q "test"; then
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
    docker-compose exec "${@}"
}

run_action() {
    docker_exec "${1}" make "${@:2}" -f /usr/local/bin/actions.mk
}

docker-compose up -d

run_action php check-ready max_try=10
run_action php migrate from=4.4.0 to=5.0.0

# PHP tools
docker_exec php tests.sh

# SSH
echo -n "Testing ssh... "
docker_exec php touch /home/wodby/.ssh/known_hosts
docker_exec php ssh wodby@sshd cat /home/wodby/.ssh/authorized_keys | grep -q admin@example.com
echo "OK"

# Git actions
echo -n "Running git actions... "
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

docker-compose down
