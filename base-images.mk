# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := php
BASE_IMAGE_VERSION_SUFFIX := -fpm-alpine

BASE_IMAGE_DIGEST_8.2.33-fpm-alpine := sha256:3340732c4feb6cd9d1a9725df00ffe0228a56d61846836a87fe3550999c297d2
BASE_IMAGE_DIGEST_8.3.33-fpm-alpine := sha256:4574194a55e413b8eb799f4ac79233e5b7c3be30d49a7df62cf37187186fe659
BASE_IMAGE_DIGEST_8.4.25-fpm-alpine := sha256:c68b19eac3042f36ed7dc7b1240712ad83d421f59e79c73357a645b520f7f68d
BASE_IMAGE_DIGEST_8.5.10-fpm-alpine := sha256:ce1dcc234879feab0f309100e55e89e7cf21b9085e76de2a03a8240cec02751e

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
