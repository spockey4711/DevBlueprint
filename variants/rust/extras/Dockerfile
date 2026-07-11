# syntax=docker/dockerfile:1
#
# Multi-stage build for the Rust service. A build stage with the full toolchain
# compiles a release binary, then a distroless runtime stage ships only that
# binary and runs as a non-root user - no compiler, no shell, and no package
# manager in the final image. See docs/ops/deployment.md ("Target: Docker").
#
# Adjust the binary name if your crate is not named `app`, and pin both base
# images to a digest (name@sha256:...) once you settle on versions - a digest
# beats a floating tag for reproducible, rollback-safe builds.

# --- Build stage -------------------------------------------------------------
# Match the Rust version to rust-toolchain.toml and .tool-versions.
FROM rust:1-slim AS build
WORKDIR /src

# Download and compile dependencies first so this layer caches across
# source-only edits: copy just the manifests, build a stub, then drop it.
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo 'fn main() {}' > src/main.rs \
    && cargo build --release \
    && rm -rf src

# Then the real sources, and build the release binary. Touching main.rs forces
# a rebuild of the crate itself while keeping the cached dependency layer above.
COPY . .
RUN cargo build --release && mkdir -p /out && cp target/release/app /out/app

# For an even smaller image, target musl for a fully static binary and ship it
# in `scratch`: add the `x86_64-unknown-linux-musl` target, build with
# `--target x86_64-unknown-linux-musl`, and copy from that target dir into a
# `FROM scratch` runtime. distroless/cc below keeps a glibc + libgcc runtime,
# which is the boring default for a dynamically linked cargo build.

# --- Runtime stage -----------------------------------------------------------
# distroless/cc has no shell or package manager, carries the glibc/libgcc a
# standard cargo build links against, and runs as an unprivileged user
# (uid 65532) via `nonroot`. Pin it to a digest in production.
FROM gcr.io/distroless/cc-debian12:nonroot AS runtime
WORKDIR /

# Copy only the built binary from the build stage.
COPY --from=build /out/app /app

# Configuration comes from the environment at run time - never COPY a .env or a
# secret into an image layer (.dockerignore keeps .env* out of the build context).
ENV APP_ENV=production
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/app"]
