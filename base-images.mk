# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := php
BASE_IMAGE_VERSION_SUFFIX := -fpm-alpine

BASE_IMAGE_DIGEST_8.2.35-fpm-alpine := sha256:a7e345653610c099afe283e8b724cc8a997646be77a5caca54822a8cd1d04c98
BASE_IMAGE_DIGEST_8.3.36-fpm-alpine := sha256:3ea3c3f8ee03269b77f5c2bda5879b44ba152cb13aafead8b67c4332f829aa2d
BASE_IMAGE_DIGEST_8.4.27-fpm-alpine := sha256:945e651a303469d40790411371a20692e9d36c728bacfb3304a05ff1dd64deb0
BASE_IMAGE_DIGEST_8.5.12-fpm-alpine := sha256:c15690bd932bd6d33f43ccae6ddd8d60acb93cee50c16afc6e699265d5d86583

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
