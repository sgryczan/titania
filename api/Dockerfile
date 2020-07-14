FROM golang:alpine AS builder

ARG VERSION

RUN apk update && apk add --no-cache \
    git \
    curl \
    jq  \
    gcc \
    libc-dev

WORKDIR $GOPATH/src/pkg/app/
COPY . .

RUN go get -d -v

RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags "-X github.com/sgryczan/titania/api/handlers.Version=${VERSION}" -o /go/bin/api

RUN dir=$(mktemp -d) && \
git clone https://github.com/go-swagger/go-swagger "$dir" && \
cd "$dir" && \
go install ./cmd/swagger

RUN swagger generate spec --scan-models -o ./swaggerui/swagger.json

FROM alpine

RUN apk update && apk add --no-cache ca-certificates
EXPOSE 8080

COPY --from=builder /go/bin/api /go/bin/api
COPY --from=builder /go/src/pkg/app/swaggerui /go/bin/swaggerui
COPY --from=builder /go/src/pkg/app/inv /go/bin/inv
WORKDIR /go/bin

ENTRYPOINT ["./api"]