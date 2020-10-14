FROM alpine:latest

RUN apk add --no-cache openssh-server openssh-sftp-server curl

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

VOLUME /config

EXPOSE 22/tcp

ENV SSHD_PORT=22 \
    HOST_KEYS_DIR=/config/host-keys \
    USER_NAME=root \
    PASSWORD= \
    AUTHORIZED_KEYS= \
    GITHUB_USERNAME= \
    PERMIT_ROOT_LOGIN=no

# WORKDIR /mnt
