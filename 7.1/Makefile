-include env_make

VERSION ?= 7.1

REPO = wodby-php
NAME = php-7.1

.PHONY: build test push shell run start stop logs rm release

build:
	docker build -t $(REPO):$(VERSION) ./

test:
	./test.sh

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

rm:
	docker rm $(NAME)

release: build
	make push -e VERSION=$(VERSION)

default: build
