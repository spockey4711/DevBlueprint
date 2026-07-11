# syntax=docker/dockerfile:1
#
# Multi-stage build for the Express service. A build stage with the full
# toolchain installs dev dependencies and compiles TypeScript to dist/, then a
# slim runtime stage ships only the production node_modules and the built server
# and runs as a non-root user - no compiler, no dev tooling, no source. See
# docs/ops/deployment.md ("Target: Docker").
#
# Adjust the start file if your entrypoint is not dist/server.js, and pin both
# base images to a digest (name@sha256:...) once you settle on versions - a
# digest beats a floating tag for reproducible, rollback-safe builds. For an even
# smaller, shell-free runtime, swap the runtime base for
# gcr.io/distroless/nodejs22 and drop the `USER node` line (it runs as nonroot).

# --- Build stage -------------------------------------------------------------
# Match the Node version to .tool-versions, .nvmrc and package.json "engines".
FROM node:22-slim AS build
WORKDIR /app

# Install dependencies first so this layer caches across source-only edits.
# The full dev toolchain is needed to compile TypeScript (tsc).
COPY package.json package-lock.json* ./
RUN npm ci

# Then the sources, and build the compiled server into dist/.
COPY . .
RUN npm run build

# Drop dev dependencies so only the runtime deps are carried into the image.
RUN npm ci --omit=dev

# --- Runtime stage -----------------------------------------------------------
# node:22-slim is a small Debian-based image with the built-in unprivileged
# `node` user. Pin it to a digest in production.
FROM node:22-slim AS runtime
WORKDIR /app

# Copy only what the server needs at run time: production deps and the build.
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/package.json ./package.json

# Configuration comes from the environment at run time - never COPY a .env or a
# secret into an image layer (.dockerignore keeps .env* out of the build context).
ENV NODE_ENV=production
EXPOSE 3000
USER node
CMD ["node", "dist/server.js"]
