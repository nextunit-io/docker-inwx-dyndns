FROM alpine:latest

LABEL zero <zero@nextunit.io>

RUN \
    apk update && \
    apk add --update curl bash

ENV API_ENDPOINT="https://api.domrobot.com/xmlrpc/"
ENV DYNDNS_DOMAIN=""
ENV INWX_USER=""
ENV INWX_PASSWORD=""
ENV INWX_DOMAIN_ID=""
ENV SLACK_DEBUG=""

RUN adduser -S dyndns

RUN mkdir -p /home/dyndns
WORKDIR /home/dyndns

COPY run.sh .
RUN chown dyndns run.sh

USER dyndns
RUN chmod +x run.sh

ENTRYPOINT /bin/bash run.sh