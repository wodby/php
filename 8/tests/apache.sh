#!/usr/bin/env bash

# Tests of the Apache variant: Apache serves static files and .htaccess rules
# and passes PHP scripts to the PHP-FPM of the same container. The PHP layer is
# the same as in the PHP-FPM image, which run.sh tests.

set -eo pipefail

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

name="php-apache-test-$$"
docroot=/var/www/html/docroot

cleanup() {
    local status=$?
    if [[ "${status}" -ne 0 ]]; then
        docker logs "${name}" 2>&1 | tail -50 || true
    fi
    docker rm -f "${name}" "${name}-crash" >/dev/null 2>&1 || true
    exit "${status}"
}
trap cleanup EXIT

start() {
    docker run -d --name "$1" \
        -e APACHE_DOCUMENT_ROOT="${docroot}" \
        -v "${PWD}/apache/docroot:${docroot}:ro" \
        "${IMAGE}" >/dev/null
    docker exec "$1" make check-ready max_try=30 -f /usr/local/bin/actions.mk
}

# Requests are made from inside the container, to its own Apache.
request() {
    docker exec "${name}" curl -sS "$@"
}

status() {
    request -o /dev/null -w '%{http_code}' "http://localhost$1"
}

expect() {
    local description=$1 actual=$2 expected=$3
    echo -n "${description}... "
    if [[ "${actual}" != *"${expected}"* ]]; then
        echo "Error: expected ${expected}, got: ${actual}"
        exit 1
    fi
    echo "OK"
}

echo -n "Running a command instead of the servers... "
docker run --rm --network none "${IMAGE}" php -r 'echo "cli\n";' | grep -qx cli
echo "OK"

start "${name}"

expect "Checking the Apache configuration" "$(docker exec "${name}" sudo httpd -t 2>&1)" "Syntax OK"
expect "Checking Apache's user" "$(docker exec "${name}" ps -o user,args | grep 'httpd -DFOREGROUND' | grep -v '^root')" "www-data"
expect "Running PHP through PHP-FPM" "$(request http://localhost/)" "\"script\":\"${docroot}/index.php\""
expect "Serving a static file" "$(request -D - http://localhost/static.txt)" "Static file served by Apache."
expect "Serving a static file without PHP" "$(request -D - http://localhost/static.txt | grep -ci 'X-Powered-By' || true)" "0"
expect "Applying .htaccess rewrites" "$(request http://localhost/pretty/abc)" '"route":"abc"'
expect "Detecting HTTPS behind a proxy" "$(request -H 'X-Forwarded-Proto: https' http://localhost/)" '"https":"on"'
expect "Keeping plain HTTP" "$(request http://localhost/)" '"https":""'
expect "Passing the Authorization header" "$(request -H 'Authorization: Bearer token' http://localhost/)" '"authorization":"Bearer token"'
expect "Denying hidden files" "$(status /.env)" "403"
expect "Answering for a missing script" "$(status /missing.php)" "404"
expect "Answering the health check" "$(status /.healthz)" "204"

echo -n "Stopping gracefully... "
# A request that is still running when the stop arrives must finish.
slow_response=$(mktemp)
request -w ' %{http_code}' http://localhost/slow.php > "${slow_response}" 2>&1 &
slow=$!
sleep 1
started=$(date +%s)
docker stop -t 30 "${name}" >/dev/null
elapsed=$(($(date +%s) - started))
wait "${slow}" || true
exit_code=$(docker inspect -f '{{.State.ExitCode}}' "${name}")
if [[ "${exit_code}" -ne 0 || "${elapsed}" -gt 20 ]]; then
    echo "Error: exit code ${exit_code} after ${elapsed}s"
    exit 1
fi
if [[ "$(cat "${slow_response}")" != "finished"*" 200" ]]; then
    echo "Error: the running request did not finish: $(cat "${slow_response}")"
    exit 1
fi
rm -f "${slow_response}"
echo "OK"

echo -n "Stopping the container when PHP-FPM exits... "
start "${name}-crash" >/dev/null
docker exec -u 0 "${name}-crash" pkill -KILL -f 'php-fpm: master'
for _ in $(seq 1 20); do
    if [[ "$(docker inspect -f '{{.State.Running}}' "${name}-crash")" == "false" ]]; then
        break
    fi
    sleep 1
done
if [[ "$(docker inspect -f '{{.State.Running}}' "${name}-crash")" != "false" ]]; then
    echo "Error: the container kept running"
    exit 1
fi
echo "OK"
