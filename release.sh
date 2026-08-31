#!/usr/bin/env bash

set -eo pipefail

if [[ "${TRAVIS_PULL_REQUEST}" == "false" && ("${TRAVIS_BRANCH}" == "master"  || -n "${TRAVIS_TAG}") ]]; then
    printf '%s' "${DOCKER_PASSWORD}" | docker login --username "${DOCKER_USERNAME}" --password-stdin

    if [[ -n "${TRAVIS_TAG}" ]]; then
        export STABILITY_TAG="${TRAVIS_TAG}"
    fi

    IFS=',' read -ra tags <<< "${TAGS}"

    for tag in "${tags[@]}"; do
        make release TAG="${tag}";
    done
fi
