ARG base_image

FROM golang:1.24 AS builder
ADD . /go/src/github.com/cloud-gov/github-pr-resource
WORKDIR /go/src/github.com/cloud-gov/github-pr-resource
RUN curl -sL https://taskfile.dev/install.sh | sh
RUN ./bin/task build

FROM ${base_image} AS resource
COPY --from=builder /go/src/github.com/cloud-gov/github-pr-resource/build /opt/resource
RUN apt update && apt upgrade -y -o Dpkg::Options::="--force-confdef"
RUN apt install -y --no-install-recommends \
    curl
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
RUN apt update && apt upgrade -y -o Dpkg::Options::="--force-confdef"
RUN apt install -y --no-install-recommends \
    git \
    git-lfs \
    openssh-client \
    git-crypt \
    && chmod +x /opt/resource/*
COPY scripts/askpass.sh /usr/local/bin/askpass.sh

FROM resource
LABEL MAINTAINER=cloud-gov
