#!/usr/bin/env bash

set -eo pipefail

if [[ "${GITHUB_REF}" == refs/heads/master || "${GITHUB_REF}" == refs/tags/* ]]; then
    docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"

    if [[ "${GITHUB_REF}" == refs/tags/* ]]; then
      export STABILITY_TAG="${GITHUB_REF##*/}"
    fi

    IFS=',' read -ra tags <<< "${TAGS}"

    for tag in "${tags[@]}"; do
        make buildx-push TAG="${tag}";
    done
fi
