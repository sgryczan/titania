VERSION=0.1.0
IMAGE_NAME=sgryczan/titania-api
IMAGE_TAG=${VERSION}

build:
	docker build --build-arg VERSION=${VERSION} -t ${IMAGE_NAME}:${IMAGE_TAG} .

push:
	docker push ${IMAGE_NAME}:${IMAGE_TAG}

run:
	docker run -p 8080:8080 ${IMAGE_NAME}:${IMAGE_TAG}

swagger:
	~/go/bin/swagger generate spec --scan-models -o ./swaggerui/swagger.json

test: test-utils test-handlers

test-utils:
	cd utils && go test -v ./... -cover && cd ..

test-handlers:
	cd handlers && go test -v ./... -cover && cd ..

.PHONY: swagger test push build run