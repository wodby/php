-include env_make

VERSION ?= 5.6

REPO = wodby/php
NAME = php-5.6

.PHONY: build test push shell run start stop logs clean release

build:
	docker build -t $(REPO):$(VERSION) --build-arg BASE_IMAGE_EXTRA_TAGS=$(BASE_IMAGE_EXTRA_TAGS) ./

test:
	IMAGE=$(REPO):$(VERSION) ./test.sh

push:
	docker push $(REPO):$(VERSION)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(VERSION) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(VERSION) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(VERSION)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)
	-docker rm -f $(NAME)-test

release: build
	make push -e VERSION=$(VERSION)

default: build
