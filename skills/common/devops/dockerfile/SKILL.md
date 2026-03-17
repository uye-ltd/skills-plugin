---
name: dockerfile
description: Write or review a production-ready Dockerfile for an application.
language: common
used-by: standalone
---

Write or review a Dockerfile for the provided application.

For writing:
- Use an official minimal base image (prefer `alpine` or `distroless`); pin the version
- Use multi-stage builds to separate build and runtime layers
- Run as a non-root user
- Copy only what is needed; respect `.dockerignore`
- Order layers from least to most frequently changed (dependencies before source)
- Add `HEALTHCHECK` if the service has a health endpoint

For review, additionally check:
- No secrets baked into the image
- No unnecessary packages installed
- `apt-get` / `apk add` lists sorted and pinned

$ARGUMENTS
