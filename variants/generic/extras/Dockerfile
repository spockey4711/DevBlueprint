# syntax=docker/dockerfile:1
#
# Multi-stage Dockerfile skeleton for the language-agnostic variant. Fill in the
# <...> placeholders for your stack; the shape is the part worth keeping. See
# docs/ops/deployment.md ("Target: Docker") for the surrounding runbook.
#
# The design on purpose: a build stage carries the full toolchain, then a slim
# runtime stage ships only the built artifact and runs as a non-root user, so the
# final image has no compiler, no dev dependencies, and no ambient root.

# --- Build stage -------------------------------------------------------------
# Pin a specific, minimal base - a digest (name@sha256:...) beats a floating tag.
FROM <language>:<version>-slim AS build
WORKDIR /app

# Copy dependency manifests first so this layer caches across source-only edits.
COPY <lockfiles> ./
RUN <install dependencies>

# Then the sources, and build.
COPY . .
RUN <build command>

# --- Runtime stage -----------------------------------------------------------
FROM <language>:<version>-slim AS runtime
WORKDIR /app

# Create an unprivileged user and never run as root.
RUN useradd --create-home --uid 10001 app
USER app

# Copy only what production needs from the build stage.
COPY --from=build /app/<built-artifact> ./

# Configuration comes from the environment at run time - never COPY a .env or a
# secret into an image layer (.dockerignore keeps .env* out of the build context).
ENV APP_ENV=production
EXPOSE 8080
CMD ["<start command>"]
