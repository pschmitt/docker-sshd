# Docker service for SSHD

[![Build](https://github.com/pschmitt/docker-sshd/workflows/Build/badge.svg)](https://github.com/pschmitt/docker-sshd/actions?query=workflow%3ABuild)
[![Docker](https://img.shields.io/docker/pulls/pschmitt/sshd)](https://hub.docker.com/u/pschmitt/sshd)

## Thanks

This is loosely based on, or rather inspired by [linuxserver/ssh-server](https://github.com/linuxserver/docker-openssh-server).

## What's the point?

The main difference is that running as root is allowed, for SSHFS among others.

Also you can set the port the SSH daemon listens on **inside the container**, 
which may come in handy if you use this container as a way to debug a pod 
running on the host network namespace (if you blindly listen on `22/tcp` you 
may end up competing with the host's SSH service - which you probably don't 
want to, ever.).

## Usage

```shell
docker run -ti --rm \
  -v $PWD/config:/config \
  -p 22222:22222/tcp \
  -e SSHD_PORT=22222 \
  -e AUTHORIZED_KEYS="ssh-ed25519 XXX" \
  -e GITHUB_USERNAME="pschmitt" \
  -e USERNAME="user01" \
  -e PASSWORD="somethingImpossibleToRemember" \
  -e PERMIT_ROOT_LOGIN="no" \
  -e PUID="1000" \
  -e PGID="1000" \
  pschmitt/sshd
```
