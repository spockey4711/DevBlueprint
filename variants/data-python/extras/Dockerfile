# syntax=docker/dockerfile:1
#
# Batch-job image for the data pipeline. This runs a pipeline/CLI to completion
# and exits - it is NOT a long-running web server, so there is no port to expose.
# A scheduler (cron, Airflow, a managed Batch service) or a one-off `docker run`
# starts a container, it does the work, and it stops. See docs/ops/deployment.md.
#
# Adjust the ENTRYPOINT if your pipeline entrypoint is not `python -m pipeline`,
# and pin the base image to a digest (name@sha256:...) once you settle on a
# version - a digest beats a floating tag for reproducible, rollback-safe builds.

# Match the Python version to .tool-versions and pyproject.toml.
FROM python:3.12-slim AS runtime

# uv gives fast, reproducible installs from the committed lockfile. Copy the
# static binary from the published uv image rather than piping a curl installer.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Run as an unprivileged user - never as root. Create it before installing so the
# app directory and virtualenv are owned by it.
RUN useradd --create-home --uid 10001 pipeline
WORKDIR /app

# Install dependencies first so this layer caches across source-only edits.
# --frozen fails if the lockfile is stale, so the image matches the committed pin.
COPY pyproject.toml uv.lock* ./
RUN uv sync --frozen --no-install-project --no-dev

# Then the sources, and install the project itself into the same environment.
COPY . .
RUN uv sync --frozen --no-dev

# Configuration and secrets come from the environment at run time - never COPY a
# .env or a credential into an image layer (.dockerignore keeps .env* out of the
# build context).
ENV APP_ENV=production \
    PATH="/app/.venv/bin:$PATH"
USER pipeline:pipeline

# The image runs the pipeline to completion and exits. Point this at your real
# entrypoint (a module, a console script, or `uv run ...`).
ENTRYPOINT ["python", "-m", "pipeline"]
