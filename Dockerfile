FROM alpine:latest

RUN apk add --no-cache openssh-server openssh-sftp-server

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
