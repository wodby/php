-include env_make

PHP_VER ?= 7.4.13
PHP_VER_MINOR ?= $(shell echo "${PHP_VER}" | grep -oE '^[0-9]+\.[0-9]+')

REPO = wodby/php
NAME = php-$(PHP_VER_MINOR)

PECL_HTTP_PROXY ?= ""

ifeq ($(WODBY_USER_ID),)
    WODBY_USER_ID := 1000
endif

ifeq ($(WODBY_GROUP_ID),)
    WODBY_GROUP_ID := 1000
endif

ifeq ($(TAG),)
    ifneq ($(PHP_DEV),)
    	TAG ?= $(PHP_VER_MINOR)-dev
    else
        TAG ?= $(PHP_VER_MINOR)
    endif
endif

ifneq ($(PHP_DEV),)
    NAME := $(NAME)-dev
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
		--build-arg PHP_VER=$(PHP_VER) \
		--build-arg PHP_DEV=$(PHP_DEV) \
		--build-arg WODBY_USER_ID=$(WODBY_USER_ID) \
		--build-arg WODBY_GROUP_ID=$(WODBY_GROUP_ID) \
		--build-arg PECL_HTTP_PROXY=$(PECL_HTTP_PROXY) \
		./

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

check-configs:
	./check-configs.sh $(PHP_VER) $(PHP_VER_MINOR)

release: build push
