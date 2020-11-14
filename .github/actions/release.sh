#!/usr/bin/env bash

set -e

if [[ "${GITHUB_REF}" == refs/heads/master || "${GITHUB_REF}" == refs/tags/* ]]; then
    docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"

    if [[ "${GITHUB_REF}" == refs/tags/* ]]; then
      export STABILITY_TAG="${GITHUB_REF##*/}"
    fi

    IFS=',' read -ra tags <<< "${TAGS}"

    for tag in "${tags[@]}"; do
        make release TAG="${tag}";
    done
fi
