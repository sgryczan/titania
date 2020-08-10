FROM alpine:3.12.0

ENV KUBECTL_VERSION=v1.18.3
ENV TERRAFORM_VERSION=0.13.0-rc1
ENV TRIDENTCTL_VERSION=20.07.0

RUN apk add --no-cache \
    bash \
    jq \
    git

RUN apk add --no-cache --virtual .build-deps curl \
  && curl -Lo /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  && chmod +x /bin/kubectl

RUN apk add --no-cache --virtual .build-deps curl \
  && curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && mv terraform /bin/terraform

RUN apk add --no-cache --virtual .build-deps curl \
  && curl -LO https://github.com/NetApp/trident/releases/download/v${TRIDENTCTL_VERSION}/trident-installer-${TRIDENTCTL_VERSION}.tar.gz \
  && tar xzf trident-installer-${TRIDENTCTL_VERSION}.tar.gz \
  && mv trident-installer/tridentctl /bin/tridentctl \
  && chmod +x /bin/tridentctl

WORKDIR /terraform

ENTRYPOINT ["/bin/bash"]