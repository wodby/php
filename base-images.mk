# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := php
BASE_IMAGE_VERSION_SUFFIX := -fpm-alpine

BASE_IMAGE_DIGEST_8.2.36-fpm-alpine := sha256:5f3fa013fe5e100924783ccb412f431ff8b0b4d78c9faa951161b7f769d60240
BASE_IMAGE_DIGEST_8.3.37-fpm-alpine := sha256:8e8db93687494e48607b70cc7f7e9414d1cda0a393dfac5dae2580dff66a9fa4
BASE_IMAGE_DIGEST_8.4.28-fpm-alpine := sha256:1c3d5f8dd7f56ae38dfaf33934c7d5f326d5291b611df1e3ea18a332d8ef9407
BASE_IMAGE_DIGEST_8.5.13-fpm-alpine := sha256:1712c76e2d29b8a3e966642fb120b02fa0c72616f8dc667b54ccd26e582d7856

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
