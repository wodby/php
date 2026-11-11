# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := php
BASE_IMAGE_VERSION_SUFFIX := -fpm-alpine

BASE_IMAGE_DIGEST_8.2.35-fpm-alpine := sha256:bac1671323a3d8073da3fbd45c313e153ec033431489737c20367152abeafb41
BASE_IMAGE_DIGEST_8.3.36-fpm-alpine := sha256:f9804e0c991b5b339d6fa4fab9edf3c9c9ae68048fb1017cb6dea6265ccef054
BASE_IMAGE_DIGEST_8.4.27-fpm-alpine := sha256:511af6fa3ef55c4ea0c68bb47096ba4b81771ab4949bde7813807bf177efda11
BASE_IMAGE_DIGEST_8.5.12-fpm-alpine := sha256:951fb5b1780219b81d5daffa4cebef8e0077c537f3893d9790a5dfcd66ca334d

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
