-include env_make

VERSION ?= 7.0

REPO = wodby/php
NAME = php-7.0
DEBUG = 0
IMAGE = $(REPO):$(VERSION)
BASE_IMAGE = wodby/base-php:7.0.23

ifeq ($(DEBUG), 1)
	IMAGE := $(IMAGE)-debug
	BASE_IMAGE := $(BASE_IMAGE)-debug
	NAME := $(NAME)-debug
endif

.PHONY: build test push shell run start stop logs clean

default: build

build:
	docker build -t $(IMAGE) --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg PHP_ENABLED_DEBUG=$(DEBUG) ./

test:
	IMAGE=$(IMAGE) ./test.sh

push:
	docker push $(IMAGE)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(IMAGE) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(IMAGE) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(IMAGE)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build
	make push -e VERSION=$(VERSION)
