#!/usr/bin/env bash

set -e

if [[ "${TRAVIS_PULL_REQUEST}" == "false" && ("${TRAVIS_BRANCH}" == "master"  || -n "${TRAVIS_TAG}") ]]; then
  docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"

  if [[ -n "${TRAVIS_TAG}" ]]; then
    export STABILITY_TAG="${TRAVIS_TAG}"
  fi

  make release

  if [[ -n "${EXTRA_TAG}" ]]; then
    make release TAG="${EXTRA_TAG}"
  fi

  if [[ "${TAG}" == "${LATEST_TAG}" ]]; then
    make release TAG="latest"
  fi
fi
