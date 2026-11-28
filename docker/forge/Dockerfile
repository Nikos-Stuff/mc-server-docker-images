FROM alpine:latest AS download

RUN apk add --no-cache bash curl jq unzip ca-certificates

ARG MC_VERSION
COPY scripts/mcjars.sh /usr/local/bin/mcjars.sh
RUN chmod +x /usr/local/bin/mcjars.sh \
    && mkdir -p /server \
    && mcjars.sh forge "${MC_VERSION}" /server/server.jar

FROM ghcr.io/pelican-eggs/yolks:ubuntu

ARG MC_VERSION
ARG JAVA_PACKAGE=openjdk21-jre-headless

ENV MC_VERSION=${MC_VERSION}

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends "${JAVA_PACKAGE}" \
    && rm -rf /var/lib/apt/lists/*

COPY --from=download /server/server.jar /opt/server/server.jar
RUN chown -R container:container /opt/server

USER container
WORKDIR /home/container
