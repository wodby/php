-include env_make

PHP_VER ?= 5.3.29

REPO = wodby/php
NAME = php-$(PHP_VER)
FROM_TAG = $(PHP_VER)

ifeq ($(TAG),)
    PHP_VER_MINOR ?= $(shell echo "${PHP_VER}" | cut -c 1-3)

    ifneq ($(PHP_DEBUG),)
        TAG ?= $(PHP_VER_MINOR)-debug
    else ifneq ($(PHP_DEV),)
    	TAG ?= $(PHP_VER_MINOR)-dev
    else
        TAG ?= $(PHP_VER_MINOR)
    endif
endif

ifneq ($(PHP_DEV),)
    NAME := $(NAME)-dev
endif

ifneq ($(PHP_DEBUG),)
    NAME := $(NAME)-debug
    FROM_TAG := $(FROM_TAG)-debug
    PHP_DEV := 1
endif

ifneq ($(STABILITY_TAG),)
    ifneq ($(TAG),latest)
        override TAG := $(TAG)-$(STABILITY_TAG)
    endif
endif

.PHONY: build test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) \
		--build-arg FROM_TAG=$(FROM_TAG) \
		--build-arg PHP_DEV=$(PHP_DEV) \
		--build-arg PHP_DEBUG=$(PHP_DEBUG) \
		./

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
