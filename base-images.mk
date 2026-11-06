# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := php
BASE_IMAGE_VERSION_SUFFIX := -fpm-alpine

BASE_IMAGE_DIGEST_8.2.35-fpm-alpine := sha256:bac1671323a3d8073da3fbd45c313e153ec033431489737c20367152abeafb41
BASE_IMAGE_DIGEST_8.3.36-fpm-alpine := sha256:472b872f5460b04ef75fdbe7e237bed3e0f0f0c6e3ede67254ddd009a6c520fa
BASE_IMAGE_DIGEST_8.4.27-fpm-alpine := sha256:15462d03828e68ae806c552403360edc5269a830d358646a9564dbebe632b787
BASE_IMAGE_DIGEST_8.5.12-fpm-alpine := sha256:64535609509e0fd5c8529359e6b599a68ce42089defd565f7881efdae7687cea

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
