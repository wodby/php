-include env_make

PHP_VER ?= 8.4.3
PHP_VER_MINOR ?= $(shell echo "${PHP_VER}" | grep -oE '^[0-9]+\.[0-9]+')

REPO = wodby/php
NAME = php-$(PHP_VER_MINOR)

PECL_HTTP_PROXY ?= ""

PLATFORM ?= linux/arm64
TAG ?= $(PHP_VER_MINOR)

ifeq ($(WODBY_USER_ID),)
    WODBY_USER_ID := 1000
endif

ifeq ($(WODBY_GROUP_ID),)
    WODBY_GROUP_ID := 1000
endif

ifneq ($(PHP_DEV),)
	override TAG := $(TAG)-dev
	override NAME := $(NAME)-dev
endif

.PHONY: build build-debug buildx-build buildx-push test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) \
		--build-arg PHP_VER=$(PHP_VER) \
		--build-arg PHP_DEV=$(PHP_DEV) \
		--build-arg WODBY_USER_ID=$(WODBY_USER_ID) \
		--build-arg WODBY_GROUP_ID=$(WODBY_GROUP_ID) \
		--build-arg PECL_HTTP_PROXY=$(PECL_HTTP_PROXY) \
		./

build-debug:
	docker build -t $(REPO):$(TAG) \
		--build-arg PHP_VER=$(PHP_VER) \
		--build-arg PHP_DEV=$(PHP_DEV) \
		--build-arg WODBY_USER_ID=$(WODBY_USER_ID) \
		--build-arg WODBY_GROUP_ID=$(WODBY_GROUP_ID) \
		--build-arg PECL_HTTP_PROXY=$(PECL_HTTP_PROXY) \
		--no-cache --progress=plain ./ 2>&1 | tee build.log

buildx-build:
	docker buildx build --platform $(PLATFORM) -t $(REPO):$(TAG) \
		--build-arg PHP_VER=$(PHP_VER) \
		--build-arg PHP_DEV=$(PHP_DEV) \
		--build-arg WODBY_USER_ID=$(WODBY_USER_ID) \
		--build-arg WODBY_GROUP_ID=$(WODBY_GROUP_ID) \
		--build-arg PECL_HTTP_PROXY=$(PECL_HTTP_PROXY) \
		./

buildx-push:
	docker buildx build --platform $(PLATFORM) --push -t $(REPO):$(TAG) \
		--build-arg PHP_VER=$(PHP_VER) \
		--build-arg PHP_DEV=$(PHP_DEV) \
		--build-arg WODBY_USER_ID=$(WODBY_USER_ID) \
		--build-arg WODBY_GROUP_ID=$(WODBY_GROUP_ID) \
		--build-arg PECL_HTTP_PROXY=$(PECL_HTTP_PROXY) \
		./

bulidx-imagetools-create:
	docker buildx imagetools create -t $(REPO):$(TAG) \
				  $(REPO):$(PHP_VER_MINOR)-amd64 \
				  $(REPO):$(PHP_VER_MINOR)-arm64
.PHONY: bulidx-imagetools-create 

test:
	cd ./tests && IMAGE=$(REPO):$(TAG) ./run.sh

push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)
	-IMAGE=$(REPO):$(TAG) docker compose -f tests/compose.yml down

check-configs:
	./check-configs.sh $(PHP_VER) $(PHP_VER_MINOR)

release: build push
