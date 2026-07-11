# syntax=docker/dockerfile:1
#
# Multi-stage build for the Phoenix app. A build stage with the full Elixir/OTP
# toolchain fetches deps, compiles assets and cuts a `mix release`, then a slim
# Debian runtime stage ships only that self-contained release and runs as a
# non-root user - no compiler, no mix, and no build tooling in the final image.
# See docs/ops/deployment.md ("Target: Docker").
#
# Adjust APP_NAME to your OTP release name (the `app` in mix.exs / config), and
# pin both base images to a digest (name@sha256:...) once you settle on versions -
# a digest beats a floating tag for reproducible, rollback-safe builds.

ARG APP_NAME=app

# --- Build stage -------------------------------------------------------------
# Match the Elixir/OTP versions to mix.exs and .tool-versions. The hexpm image
# bundles a known-good Elixir + Erlang/OTP + Debian triple.
FROM hexpm/elixir:1.18.3-erlang-27.2.1-debian-bookworm-20250113-slim AS build

# Build deps for compiling native extensions and assets (esbuild/tailwind fetch
# their own binaries at build time). git is needed for git-sourced hex deps.
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends build-essential git \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Build the release for prod. Config is read from the environment at runtime via
# config/runtime.exs, so no secrets are baked into the image.
ENV MIX_ENV=prod

# Install the hex/rebar build tooling.
RUN mix local.hex --force && mix local.rebar --force

# Fetch deps first so this layer caches across source-only edits.
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
COPY config config
RUN mix deps.compile

# Then the app sources and assets, and compile + digest the static assets.
COPY priv priv
COPY lib lib
COPY assets assets
RUN mix assets.deploy
RUN mix compile

# Runtime release config, then cut the self-contained release.
COPY config/runtime.exs config/
COPY rel rel
RUN mix release

# --- Runtime stage -----------------------------------------------------------
# A slim Debian carrying only the OpenSSL/libncurses the BEAM needs at run time.
# The release bundles its own ERTS, so no Elixir/Erlang install is required here.
# Pin this to a digest in production.
FROM debian:bookworm-slim AS runtime
ARG APP_NAME

RUN apt-get update -y \
  && apt-get install -y --no-install-recommends libstdc++6 openssl libncurses6 ca-certificates \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Run as an unprivileged user - never as root.
RUN useradd --create-home --uid 10001 app
WORKDIR /app
USER app

# Configuration comes from the environment at run time - never COPY a .env or a
# secret into an image layer (.dockerignore keeps .env* out of the build context).
ENV MIX_ENV=prod
ENV PHX_SERVER=true
EXPOSE 4000

# Copy only the built release from the build stage.
COPY --from=build --chown=app:app /src/_build/prod/rel/${APP_NAME} ./

# The release exposes a launcher named after the app. Migrations run as a
# deliberate release command (see docs/ops/deployment.md), never on boot.
ENTRYPOINT ["bin/app"]
CMD ["start"]
