# syntax=docker/dockerfile:1
#
# Multi-stage build for the Nuxt app. A build stage with the full toolchain
# installs deps and runs `pnpm build`, then a slim runtime stage ships only the
# Nitro output (`.output`) and runs `node .output/server/index.mjs` as a non-root
# user - no pnpm, no dev dependencies, and no ambient root in the final image.
# See docs/ops/deployment.md ("Target: Docker").
#
# `nuxt build` defaults to the Nitro node-server preset, which traces the runtime
# deps into `.output` - nothing extra to configure. Pin both base images to a
# digest (name@sha256:...) once you settle on versions - a digest beats a floating
# tag for reproducible, rollback-safe builds.

# --- Build stage -------------------------------------------------------------
# Match the Node version to .tool-versions / .nvmrc. corepack activates the
# pnpm pinned in package.json's "packageManager" field.
FROM node:22-slim AS build
WORKDIR /app
RUN corepack enable

# Install deps first so this layer caches across source-only edits.
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Then the sources, and build the Nitro output. runtimeConfig is read at server
# start, not baked in here, so the same image runs in every environment.
COPY . .
ENV NUXT_TELEMETRY_DISABLED=1
RUN pnpm build

# --- Runtime stage -----------------------------------------------------------
# A slim runtime with just the traced Nitro server - no pnpm, no toolchain.
FROM node:22-slim AS runtime
WORKDIR /app

ENV NODE_ENV=production
ENV NUXT_TELEMETRY_DISABLED=1
ENV HOST=0.0.0.0
ENV PORT=3000

# Create an unprivileged user and never run as root.
RUN useradd --create-home --uid 10001 app

# Copy only the self-contained Nitro output: server entrypoint, a minimal
# node_modules, and the public/ + client assets, all under .output.
COPY --from=build --chown=app:app /app/.output ./.output

# Configuration comes from the environment at run time - never COPY a .env or a
# secret into an image layer (.dockerignore keeps .env* out of the build context).
USER app
EXPOSE 3000
CMD ["node", ".output/server/index.mjs"]
