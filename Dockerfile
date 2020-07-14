FROM golang:alpine AS builder
EXPOSE 8080

RUN apk update && apk add --no-cache git
WORKDIR $GOPATH/src/github.com/sgryczan

#RUN go get go.universe.tf/netboot/cmd/pixiecore

#RUN cd go.universe.tf/netboot/cmd/pixiecore && \
#    GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o /go/bin/pixiecore

RUN git clone https://github.com/sgryczan/netboot

RUN cd $GOPATH/src/github.com/sgryczan/netboot && \
    git checkout inventory_callback && \
    GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o /go/bin/pixiecore ./cmd/pixiecore

ADD utils/get-ip.go .
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o /go/bin/get-ip

FROM ubuntu:16.04

WORKDIR /ipxe

COPY --from=builder /go/bin/pixiecore /ipxe/pixiecore
COPY --from=builder /go/bin/get-ip /ipxe/utils/get-ip

RUN apt-get update && \
    apt-get install -y \
    gcc \
    git \
    make \
    perl \
    liblzma-dev \
    mtools \
    isolinux \
    genisoimage

WORKDIR /ipxe

# Copy stuff needed to compile iPXE
RUN git clone https://github.com/ipxe/ipxe.git && \
    mv ipxe/src/ . && \
    rm -rf ipxe/

COPY utils/make.sh utils/
COPY boot/boot.ipxe boot/

# Make this a couple times to speed up runtime builds
RUN /ipxe/utils/make.sh
RUN /ipxe/utils/make.sh

ADD entrypoint.sh .

ENTRYPOINT ["/ipxe/entrypoint.sh"]