ARG JAVA_PACKAGE=21-jre

FROM alpine:latest AS download

RUN apk add --no-cache bash curl jq ca-certificates

ARG MC_VERSION
COPY scripts/mcjars.sh /usr/local/bin/mcjars.sh
RUN chmod +x /usr/local/bin/mcjars.sh \
    && mkdir -p /paper \
    && mcjars.sh paper "${MC_VERSION}" /paper/server.jar

FROM eclipse-temurin:${JAVA_PACKAGE}

ARG MC_VERSION
ENV MC_VERSION=${MC_VERSION} \
    USER=container \
    HOME=/home/container

RUN useradd -m -d /home/container -s /bin/bash container

COPY --from=download --chown=container:container /paper/server.jar /opt/paper/server.jar

USER container
WORKDIR /home/container
