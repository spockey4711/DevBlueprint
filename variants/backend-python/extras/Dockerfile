# syntax=docker/dockerfile:1
#
# Multi-stage build for the Python (FastAPI) service. A build stage with uv
# resolves the locked dependencies into a self-contained virtualenv, then a slim
# runtime stage copies that venv plus the app and runs uvicorn as a non-root user
# - no build tools and no dependency resolver in the final image. See
# docs/ops/deployment.md ("Target: Docker").
#
# Adjust the app import path (app.main:app) if your ASGI entrypoint differs, and
# pin both base images to a digest (name@sha256:...) once you settle on versions -
# a digest beats a floating tag for reproducible, rollback-safe builds.

# --- Build stage -------------------------------------------------------------
# Match the Python version to .python-version and .tool-versions. The uv binary
# comes from its official image so the resolver version is pinned too.
FROM python:3.12-slim AS build
COPY --from=ghcr.io/astral-sh/uv:0.4.20 /uv /usr/local/bin/uv
WORKDIR /src

# Build a project-local virtualenv and keep uv from downloading its own Python -
# the base image already provides the interpreter we want.
ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
    UV_PYTHON_DOWNLOADS=never \
    UV_COMPILE_BYTECODE=1

# Install dependencies first, from the lockfile only, so this layer caches across
# source-only edits. --no-install-project skips the app itself at this point.
COPY pyproject.toml uv.lock* ./
RUN uv sync --frozen --no-dev --no-install-project

# Then the sources, and install the project into the same venv.
COPY . .
RUN uv sync --frozen --no-dev

# --- Runtime stage -----------------------------------------------------------
# A slim runtime with no build tools. Create an unprivileged user and run under
# it; the venv from the build stage is copied in wholesale. Pin to a digest in
# production.
FROM python:3.12-slim AS runtime
WORKDIR /app

# Run as a non-root user - never as root. The uid is arbitrary but fixed so file
# ownership is predictable.
RUN groupadd --system --gid 1001 app \
    && useradd --system --uid 1001 --gid app app

# Copy the built virtualenv and the application code from the build stage.
COPY --from=build /opt/venv /opt/venv
COPY --from=build /src /app

# Put the venv on PATH so `uvicorn`/`gunicorn` resolve without activation.
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Configuration comes from the environment at run time - never COPY a .env or a
# secret into an image layer (.dockerignore keeps .env* out of the build context).
ENV APP_ENV=production
EXPOSE 8000
USER app

# Bind to 0.0.0.0 so the container is reachable; swap uvicorn for
# `gunicorn -k uvicorn.workers.UvicornWorker` when you need multiple workers.
ENTRYPOINT ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
