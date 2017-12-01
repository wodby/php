-include env_make

PHP_VER ?= 7.2.0
# Remove minor version from tag
TAG ?= $(shell echo "${PHP_VER}" | cut -c 1-3)

REPO = wodby/php
NAME = php-$(PHP_VER)
FROM_TAG = $(PHP_VER)

ifneq ($(PHP_DEBUG),)
    override TAG := $(TAG)-debug
    FROM_TAG := $(FROM_TAG)-debug
    NAME := $(NAME)-debug
endif

ifneq ($(STABILITY_TAG),)
ifneq ($(TAG),latest)
    override TAG := $(TAG)-$(STABILITY_TAG)
endif
endif

.PHONY: build test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) --build-arg FROM_TAG=$(FROM_TAG) --build-arg PHP_DEBUG=$(PHP_DEBUG) ./

test:
	IMAGE=$(REPO):$(TAG) ./test.sh

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

release: build push
