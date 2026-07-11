# syntax=docker/dockerfile:1
#
# Multi-stage build for the Go service. A build stage with the full toolchain
# compiles a static binary, then a distroless runtime stage ships only that
# binary and runs as a non-root user - no compiler, no shell, and no package
# manager in the final image. See docs/ops/deployment.md ("Target: Docker").
#
# Adjust the build target if your entrypoint is not ./cmd/server, and pin both
# base images to a digest (name@sha256:...) once you settle on versions - a
# digest beats a floating tag for reproducible, rollback-safe builds.

# --- Build stage -------------------------------------------------------------
# Match the Go version to go.mod and .tool-versions.
FROM golang:1.23 AS build
WORKDIR /src

# Download modules first so this layer caches across source-only edits.
# (go.sum* is optional - the glob matches nothing on a project with no deps yet.)
COPY go.mod go.sum* ./
RUN go mod download

# Then the sources, and build a static binary: CGO off means no libc dependency,
# so it runs in a distroless/scratch image; -trimpath and -ldflags trim it down.
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/app ./cmd/server

# --- Runtime stage -----------------------------------------------------------
# distroless/static:nonroot has no shell or package manager and runs as an
# unprivileged user (uid 65532) by default. Pin it to a digest in production.
FROM gcr.io/distroless/static:nonroot AS runtime
WORKDIR /

# Copy only the built binary from the build stage.
COPY --from=build /out/app /app

# Configuration comes from the environment at run time - never COPY a .env or a
# secret into an image layer (.dockerignore keeps .env* out of the build context).
ENV APP_ENV=production
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/app"]
