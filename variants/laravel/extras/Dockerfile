# syntax=docker/dockerfile:1
#
# Multi-stage build for the Laravel app. A build stage with Composer and the PHP
# toolchain installs the production dependencies and warms the autoloader, then a
# slim php-fpm runtime stage copies the app in and runs as a non-root user - no
# Composer and no dev dependencies in the final image. See docs/ops/deployment.md
# ("Target: Docker").
#
# PHP serves best as php-fpm behind a web server: this image runs php-fpm on port
# 9000, and a separate nginx (or Caddy) container proxies HTTP to it - see the
# commented `web` service in docker-compose.yml. Pin both base images to a digest
# (name@sha256:...) once you settle on versions for reproducible, rollback-safe
# builds.

# --- Build stage -------------------------------------------------------------
# Match the PHP version to composer.json and .tool-versions. Composer ships in
# its own image; copy the binary in rather than installing it by hand.
FROM php:8.3-fpm AS build
WORKDIR /app

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# System libraries the PHP extensions below build against, then the extensions
# themselves. Trim this list to what your app actually uses (pdo_pgsql for
# Postgres, pdo_mysql for MySQL/MariaDB, ...).
RUN apt-get update && apt-get install -y --no-install-recommends \
      git unzip libicu-dev libzip-dev libpq-dev \
  && docker-php-ext-install -j"$(nproc)" intl zip pdo pdo_pgsql bcmath \
  && rm -rf /var/lib/apt/lists/*

# Install dependencies first so this layer caches across source-only edits.
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist --no-interaction

# Then the sources, and finish the autoloader against the full tree.
COPY . .
RUN composer dump-autoload --no-dev --optimize

# --- Runtime stage -----------------------------------------------------------
# A clean php-fpm image with only the runtime extensions and the built app.
FROM php:8.3-fpm AS runtime
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
      libicu-dev libzip-dev libpq-dev \
  && docker-php-ext-install -j"$(nproc)" intl zip pdo pdo_pgsql bcmath \
  && rm -rf /var/lib/apt/lists/*

# Copy the built app (vendor/ included) from the build stage.
COPY --from=build /app /app

# Laravel writes caches, sessions and logs under storage/ and bootstrap/cache/ -
# the runtime user must own them. php-fpm's built-in `www-data` user is unprivileged.
RUN chown -R www-data:www-data storage bootstrap/cache

# Configuration comes from the environment at run time - never COPY a .env or a
# secret into an image layer (.dockerignore keeps .env* out of the build context).
# Generate APP_KEY once and set it in the platform's secret store, never here.
ENV APP_ENV=production
EXPOSE 9000
USER www-data
CMD ["php-fpm"]
