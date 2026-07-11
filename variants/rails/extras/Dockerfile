# syntax=docker/dockerfile:1
#
# Multi-stage build for the Rails app. A build stage with the full Ruby toolchain
# installs gems and precompiles assets, then a slim runtime stage ships only what
# production needs and runs as a non-root user - no build tools and no ambient
# root in the final image. See docs/ops/deployment.md ("Target: Docker").
#
# Pin both base images to a digest (name@sha256:...) once you settle on versions -
# a digest beats a floating tag for reproducible, rollback-safe builds. Match the
# Ruby version to .ruby-version / .tool-versions.

# --- Build stage -------------------------------------------------------------
FROM ruby:3.3-slim AS build
WORKDIR /app

# Build-time toolchain for native gem extensions (pg, nokogiri, ...). None of it
# ships in the runtime image.
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends build-essential libpq-dev git \
    && rm -rf /var/lib/apt/lists/*

# Install gems first so this layer caches across source-only edits.
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without "development test" \
    && bundle config set --local deployment true \
    && bundle install --jobs 4 --retry 3

# Then the sources, and precompile assets. A dummy SECRET_KEY_BASE lets
# assets:precompile boot the app without exposing the real secret at build time.
COPY . .
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# --- Runtime stage -----------------------------------------------------------
FROM ruby:3.3-slim AS runtime
WORKDIR /app

# Only the runtime libraries the app links against - no compiler, no headers.
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends libpq5 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 10001 rails

# Copy the installed gems and the built app from the build stage.
COPY --from=build --chown=rails:rails /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=rails:rails /app /app

USER rails

# Configuration comes from the environment at run time - never COPY a .env or a
# secret into an image layer (.dockerignore keeps .env* out of the build context).
# SECRET_KEY_BASE, DATABASE_URL and friends are injected by the platform. Run
# `rails db:migrate` as a deliberate release step, not from this entrypoint.
ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true
EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
