VERSION=0.1.0
IMAGE_NAME=sgryczan/titania-boot

build-all: build-image build-api
push-all: push push-api

build-image:
	docker build --no-cache -t $(IMAGE_NAME):${VERSION} .

build-api:
	make -C api build

push:
	docker push $(IMAGE_NAME):${VERSION}

push-api:
	make -C api push

test: test-api

test-api:
	make -C api test

.ONESHELL:

.PHONY: build-image
