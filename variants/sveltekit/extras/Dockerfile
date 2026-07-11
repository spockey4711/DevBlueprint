# syntax=docker/dockerfile:1
#
# Multi-stage build for a SvelteKit app built with @sveltejs/adapter-node. A
# build stage with the full pnpm toolchain installs dependencies and runs
# `pnpm build`, producing the adapter-node server under ./build. A slim runtime
# stage then ships only the built server plus production dependencies and runs
# `node build` as a non-root user - no dev dependencies, no build toolchain.
# See docs/ops/deployment.md ("Target: Docker").
#
# This Dockerfile assumes self-hosting with adapter-node. If you deploy to a
# managed platform (Vercel/Netlify) their adapter replaces this entirely - see
# deploy/README.md. Pin both base images to a digest (name@sha256:...) once you
# settle on versions - a digest beats a floating tag for reproducible builds.

# --- Build stage -------------------------------------------------------------
# Match the Node version to .nvmrc / .tool-versions and the pnpm version to the
# "packageManager" field in package.json.
FROM node:22-slim AS build
WORKDIR /app

# Corepack ships with Node and activates the pnpm version pinned in package.json.
RUN corepack enable

# Install dependencies first so this layer caches across source-only edits.
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Then the sources, and build the adapter-node server into ./build.
COPY . .
RUN pnpm build

# Prune to production dependencies only - the runtime does not need dev deps.
RUN pnpm prune --prod

# --- Runtime stage -----------------------------------------------------------
# A slim runtime with no build toolchain. `node` is the unprivileged built-in
# user (uid 1000) shipped by the official Node images. Pin to a digest in prod.
FROM node:22-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production

# Copy only what `node build` needs: the built server, its production
# dependencies, and package.json for the module resolution metadata.
COPY --from=build /app/build ./build
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json

# Configuration comes from the environment at run time - never COPY a .env or a
# secret into an image layer (.dockerignore keeps .env* out of the build context).
ENV PORT=3000
EXPOSE 3000
USER node
CMD ["node", "build"]
