# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := php
BASE_IMAGE_VERSION_SUFFIX := -fpm-alpine

BASE_IMAGE_DIGEST_8.2.33-fpm-alpine := sha256:79b4e79ebb2e7a4281ed27369a66322e5f1faf0b79a741446dcc02994791f28e
BASE_IMAGE_DIGEST_8.3.33-fpm-alpine := sha256:62f4c401dc970c352223dd018e4f2c9d1c480e07f67351cd31bec2d1f8a8fb42
BASE_IMAGE_DIGEST_8.4.25-fpm-alpine := sha256:c68b19eac3042f36ed7dc7b1240712ad83d421f59e79c73357a645b520f7f68d
BASE_IMAGE_DIGEST_8.5.11-fpm-alpine := sha256:94ca6b9ecaf5e80e45759694502e55278f0b8e3652455275f4e12dd6f13ecf64

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
