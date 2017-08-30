#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

started=0
host=$1
max_try=$2
wait_seconds=$3
delay_seconds=$4

sleep "${delay_seconds}"

for i in $(seq 1 "${max_try}"); do
    # Some symbols in env vars break cgi-fcgi
    if env -i SCRIPT_NAME="/ping" SCRIPT_FILENAME="/ping" REQUEST_METHOD=GET \
       cgi-fcgi -bind -connect "${host}":9001 | grep -q "pong"; then
        started=1
        break
    fi
    echo 'PHP-FPM is starting...'
    sleep "${wait_seconds}"
done

if [[ "${started}" -eq '0' ]]; then
    echo >&2 'Error. PHP-FPM is unreachable.'
    exit 1
fi

echo 'PHP-FPM has started!'
