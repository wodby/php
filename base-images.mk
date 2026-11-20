# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := php
BASE_IMAGE_VERSION_SUFFIX := -fpm-alpine

BASE_IMAGE_DIGEST_8.2.36-fpm-alpine := sha256:5457d920b2ec40f8d053438d1f721afd0d71302f707686bd2e9b5b99df3c05be
BASE_IMAGE_DIGEST_8.3.37-fpm-alpine := sha256:5dd9d8f16428908a77e3084ef77b27ab47bf63d5af2fe5b7eb8906610672de47
BASE_IMAGE_DIGEST_8.4.28-fpm-alpine := sha256:1c3d5f8dd7f56ae38dfaf33934c7d5f326d5291b611df1e3ea18a332d8ef9407
BASE_IMAGE_DIGEST_8.5.13-fpm-alpine := sha256:1712c76e2d29b8a3e966642fb120b02fa0c72616f8dc667b54ccd26e582d7856

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
