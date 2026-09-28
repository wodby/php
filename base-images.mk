# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := php
BASE_IMAGE_VERSION_SUFFIX := -fpm-alpine

BASE_IMAGE_DIGEST_8.2.34-fpm-alpine := sha256:3d3deaf018e06ba22b38048da5ba4ebb7a9b557181ec44ae0d55d36fed9a799b
BASE_IMAGE_DIGEST_8.3.35-fpm-alpine := sha256:408879e88f5cece32ca6401a1fc2d42aa4a0d7341ea8bc0bc39630022fd4e407
BASE_IMAGE_DIGEST_8.4.26-fpm-alpine := sha256:78cd8de9970a9cd6ff4d98860a94eb5bf37dd2d5776b4785562dbfad01c29d5a
BASE_IMAGE_DIGEST_8.5.11-fpm-alpine := sha256:fa01fb1645cd0fc566a5f146b099adace33b906571f972f71f2182a7c12d1cd7

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
