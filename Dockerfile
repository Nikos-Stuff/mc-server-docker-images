FROM alpine:latest AS download

RUN apk add --no-cache bash curl jq ca-certificates

ARG MC_VERSION
COPY scripts/download-paper.sh /usr/local/bin/download-paper.sh
RUN chmod +x /usr/local/bin/download-paper.sh \
    && mkdir -p /paper \
    && download-paper.sh "${MC_VERSION}" /paper/server.jar

FROM ghcr.io/pelican-eggs/yolks:alpine

ARG MC_VERSION
ARG JAVA_PACKAGE=openjdk21-jre-headless

USER root

ENV MC_VERSION=${MC_VERSION}

RUN apk add --no-cache "${JAVA_PACKAGE}"

# NOTE: the jar is stored at /opt/paper/server.jar NOT /home/container
# each server's data directory is being mounted over /home/container
# at runtime which would otherwise hide anything baked in there. The egg's
# startup command copies /opt/paper/server.jar into /home/container on start
COPY --from=download /paper/server.jar /opt/paper/server.jar
RUN chown -R container:container /opt/paper

USER container
WORKDIR /home/container
