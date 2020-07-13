VERSION=0.1.0
IMAGE_NAME=sgryczan/titania-boot

build-all: build-image build-sidecar
push-all: push push-sidecar

build-image:
	docker build --no-cache -t $(IMAGE_NAME):${VERSION} .

build-sidecar:
	make -C sidecar build

push:
	docker push $(IMAGE_NAME):${VERSION}

push-sidecar:
	make -C sidecar push

test: test-sidecar

test-sidecar:
	make -C sidecar test

.ONESHELL:

.PHONY: build-image
