# Agent notes

This repository builds a container image for an OpenSSH server with SFTP.

- Keep authentication and account behavior aligned with `README.md` and the
  image's documented purpose. Do not bake private keys or passwords into the
  image.
- Build with `docker build` and smoke-test in an isolated container using
  throwaway credentials.
- A push triggers the image build workflow. Do not change its publication or
  access settings without an explicit request.
- Before changing CI, check for reusable workflows or actions in
  [ci-workflows](https://github.com/pschmitt/ci-workflows) and preserve the
  workflow's current behavior and checks.
