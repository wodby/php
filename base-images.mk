# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := php
BASE_IMAGE_VERSION_SUFFIX := -fpm-alpine

BASE_IMAGE_DIGEST_8.2.35-fpm-alpine := sha256:62acd0827698068d9605bf236fb2fc3c0b10052fd98974d7e9b3ab05ae7291ca
BASE_IMAGE_DIGEST_8.3.36-fpm-alpine := sha256:aaf1ad25fc6484613be770743d1038e98e3e7e07409d78b97410eccdf3628f75
BASE_IMAGE_DIGEST_8.4.27-fpm-alpine := sha256:6b83fd767e1902ae4c89fe11f929f02e78bf769215c703060ac8a7c4be672c8c
BASE_IMAGE_DIGEST_8.5.12-fpm-alpine := sha256:f09d9172dd28b8696aef729ca2c2081a132c1f8d581218c99497d552c82a92df

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
