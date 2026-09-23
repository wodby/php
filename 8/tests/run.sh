#!/bin/bash

set -eo pipefail

# Validate the development tool contract before application integration tests.
docker run --rm --network none --entrypoint /bin/sh -v "$PWD/development-tools.sh:/tmp/development-tools.sh:ro" "${IMAGE}" /tmp/development-tools.sh
docker run --rm --network none --entrypoint /bin/bash -v "$PWD/runtime-configuration.sh:/tmp/runtime-configuration.sh:ro" "${IMAGE}" /tmp/runtime-configuration.sh

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

git_url=https://github.com/wodby/php.git

wait_for_cron() {
    executed=0

    for _ in $(seq 1 13); do
        if docker_exec crond cat /mnt/files/cron | grep -q "composer/vendor"; then
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
    docker compose exec -T "${@}"
}

run_action() {
    docker_exec "${1}" make "${@:2}" -f /usr/local/bin/actions.mk
}

# Exercise both template-managed and ordinary INI files through the entrypoint.
docker run --rm --network none "${IMAGE}" php -r '
    foreach (["xdebug", "xhprof", "spx"] as $extension) {
        if (extension_loaded($extension)) {
            throw new RuntimeException("Unexpected enabled extension: " . $extension);
        }
    }
    if (!extension_loaded("event") || !extension_loaded("redis")) {
        throw new RuntimeException("Default extensions are missing");
    }
'
docker run --rm --network none -e PHP_EXTENSIONS_DISABLE=xdebug,xhprof,spx,event,redis,apcu \
    "${IMAGE}" php -r '
    foreach (explode(",", getenv("PHP_EXTENSIONS_DISABLE")) as $extension) {
        if (extension_loaded($extension)) {
            throw new RuntimeException("Could not disable extension: " . $extension);
        }
    }
'

# Always remove this test project's containers and anonymous service data, even on failure.
cleanup() {
    local status=$?
    if [[ "$status" -ne 0 ]]; then
        docker compose --profile sqlserver ps --all || true
        local sqlserver_id
        sqlserver_id=$(docker compose --profile sqlserver ps --all --quiet sqlserver) || true
        if [[ -n "$sqlserver_id" ]]; then
            docker inspect --format '{{json .State}}' "$sqlserver_id" || true
        fi
        docker compose --profile sqlserver logs --tail=100 || true
    fi
    docker compose --profile sqlserver down -v --remove-orphans || true
    exit "$status"
}
trap cleanup EXIT

if [[ $(docker run --rm --entrypoint uname "${IMAGE}" -m) == x86_64 ]]; then
    docker compose --profile sqlserver up -d --wait --wait-timeout 180
else
    docker compose up -d --wait --wait-timeout 180
fi

run_action php check-ready max_try=10
run_action php migrate from=4.4.0 to=5.0.0

# PHP tools
docker_exec php tests.sh
docker_exec php bash /usr/local/bin/functional/run.sh

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
echo -n "Checking vendor New Relic daemon... "
docker_exec php /usr/bin/newrelic-daemon --version | grep -E '^New Relic daemon version [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
echo "OK"

echo -n "Running walter scripts... "
run_action php walter
docker_exec php cat ./walter-shell-stage
docker_exec php cat ./walter-command-stage
echo "OK"

# Crond
wait_for_cron
