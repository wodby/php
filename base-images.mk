# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := php
BASE_IMAGE_VERSION_SUFFIX := -fpm-alpine

BASE_IMAGE_DIGEST_8.2.35-fpm-alpine := sha256:f7d0ea0acdaa28bef474b3741ef0ee00423f05078e216d31f1aa5c4a681ae6d4
BASE_IMAGE_DIGEST_8.3.36-fpm-alpine := sha256:25e15cf35ed0f5b75d8cf14fc2c4ed7e0e6bee00d359e681b7fa3e91a7bee49f
BASE_IMAGE_DIGEST_8.4.27-fpm-alpine := sha256:93aa3f61216b73cc6f878235c9772849449f4efc18dfe3d6678eed645076c00d
BASE_IMAGE_DIGEST_8.5.12-fpm-alpine := sha256:4c2818074ec49f6abe46620f3965e0cb75bc3a5f2b417edd1aacaba6f091c40e

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
