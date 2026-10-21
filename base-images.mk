# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := php
BASE_IMAGE_VERSION_SUFFIX := -fpm-alpine

BASE_IMAGE_DIGEST_8.2.35-fpm-alpine := sha256:a7e345653610c099afe283e8b724cc8a997646be77a5caca54822a8cd1d04c98
BASE_IMAGE_DIGEST_8.3.36-fpm-alpine := sha256:3ea3c3f8ee03269b77f5c2bda5879b44ba152cb13aafead8b67c4332f829aa2d
BASE_IMAGE_DIGEST_8.4.27-fpm-alpine := sha256:8193f7c711715c88452ebe51d4ee7769172a3fa917446a8820cf84192da2c555
BASE_IMAGE_DIGEST_8.5.12-fpm-alpine := sha256:4c9541a4506014672d074652a1cc9754d3c5f97cad6c6027bae35be0e4a4dea9

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
