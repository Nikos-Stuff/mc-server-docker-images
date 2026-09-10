FROM alpine:latest AS download

RUN apk add --no-cache bash curl jq ca-certificates

ARG MC_VERSION
COPY scripts/mcjars.sh /usr/local/bin/mcjars.sh
RUN chmod +x /usr/local/bin/mcjars.sh \
    && mkdir -p /server \
    && mcjars.sh purpur "${MC_VERSION}" /server/server.jar

FROM ghcr.io/pelican-eggs/yolks:alpine

ARG MC_VERSION
ARG JAVA_PACKAGE=openjdk21-jre-headless

ENV MC_VERSION=${MC_VERSION}

USER root

RUN apk add --no-cache "${JAVA_PACKAGE}"

COPY --from=download /server/server.jar /opt/server/server.jar
RUN chown -R container:container /opt/server

USER container
WORKDIR /home/container
