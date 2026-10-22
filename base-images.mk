# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := php
BASE_IMAGE_VERSION_SUFFIX := -fpm-alpine

BASE_IMAGE_DIGEST_8.2.35-fpm-alpine := sha256:74d21049efdbf57d7ecb245ef872d2b45b8e331d5ef6a081ea9f73a62aafa496
BASE_IMAGE_DIGEST_8.3.36-fpm-alpine := sha256:81cb692948e6de4275f7e107c50a34e963a440660f2c5b8502d11071f7d30338
BASE_IMAGE_DIGEST_8.4.27-fpm-alpine := sha256:8ce34c869fae0f8da2c82d8aeda222f0782e8e5ae2b370fb43cbad84e9e2ea55
BASE_IMAGE_DIGEST_8.5.12-fpm-alpine := sha256:4943e6c8a08008605b470f6171d611a89384bac97188e4b0a7aefd3f793cd040

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
