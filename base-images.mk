# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := php
BASE_IMAGE_VERSION_SUFFIX := -fpm-alpine

BASE_IMAGE_DIGEST_8.2.35-fpm-alpine := sha256:17ec44afb589c6f2472ab6e2b8e970088163c82bb5a191b6c3d39cce19d959e4
BASE_IMAGE_DIGEST_8.3.36-fpm-alpine := sha256:ff9183eaaa1a75abfe50f554108b95a6970bd9ff73d7ba750f69813d28c6a6ce
BASE_IMAGE_DIGEST_8.4.27-fpm-alpine := sha256:2e1912ff280c8f2b76f1eb5dc487035b8b3920d34d58c606ad9777913e952795
BASE_IMAGE_DIGEST_8.5.12-fpm-alpine := sha256:984a7ff73e861ee5d6a32e8af82c4f3ae4cf6c38a28cc918b5ee99f6f61833bd

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
