-include env_make

PHP_VER ?= 5.6.32

REPO = wodby/php
NAME = php-$(PHP_VER)
FROM_TAG = $(PHP_VER)

ifeq ($(TAG),)
    PHP_VER_MINOR ?= $(shell echo "${PHP_VER}" | cut -c 1-3)

    ifeq ($(PHP_DEV),)
        TAG ?= $(PHP_VER_MINOR)
    else
        TAG ?= $(PHP_VER_MINOR)-dev
    endif
endif

ifneq ($(PHP_DEV),)
    NAME := $(NAME)-dev
    FROM_TAG := $(FROM_TAG)-debug
endif

ifneq ($(STABILITY_TAG),)
ifneq ($(TAG),latest)
    override TAG := $(TAG)-$(STABILITY_TAG)
endif
endif

.PHONY: build test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) --build-arg FROM_TAG=$(FROM_TAG) --build-arg PHP_DEV=$(PHP_DEV) ./

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
