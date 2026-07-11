# syntax=docker/dockerfile:1
#
# Multi-stage build for the Spring Boot service. A JDK build stage runs
# `./gradlew bootJar` and extracts the layered jar, then a JRE runtime stage
# ships only the exploded application and runs as a non-root user - no build
# toolchain, no Gradle, and no ambient root in the final image. See
# docs/ops/deployment.md ("Target: Docker").
#
# Adjust the entrypoint class if Spring's layered jar tooling is not enabled,
# and pin both base images to a digest (name@sha256:...) once you settle on
# versions - a digest beats a floating tag for reproducible, rollback-safe builds.

# --- Build stage -------------------------------------------------------------
# Match the JDK to build.gradle's Java toolchain and .tool-versions.
FROM eclipse-temurin:21-jdk AS build
WORKDIR /src

# Copy the Gradle wrapper and build scripts first so dependency resolution caches
# across source-only edits. The wrapper pins the same Gradle local, CI and here.
COPY gradlew ./
COPY gradle ./gradle
COPY build.gradle* settings.gradle* ./
RUN ./gradlew --no-daemon dependencies > /dev/null 2>&1 || true

# Then the sources, and build the executable jar.
COPY . .
RUN ./gradlew --no-daemon clean bootJar

# Extract the layered jar so the runtime stage can copy each layer separately -
# dependencies (change rarely) land in their own cacheable image layers, the
# application code (changes often) in another. Requires Spring Boot's layered
# jar, which is enabled by default.
RUN mkdir -p /out && cp build/libs/*.jar /out/app.jar \
  && cd /out && java -Djarmode=layertools -jar app.jar extract

# --- Runtime stage -----------------------------------------------------------
# A JRE base has no compiler or build tooling; consider a distroless Java image
# (gcr.io/distroless/java21-debian12:nonroot) for an even smaller attack surface.
# Pin this to a digest in production.
FROM eclipse-temurin:21-jre AS runtime
WORKDIR /app

# Create an unprivileged user and never run as root.
RUN useradd --create-home --uid 10001 app
USER app

# Copy the extracted layers in cache-friendly order (least to most volatile).
COPY --from=build --chown=app:app /out/dependencies/ ./
COPY --from=build --chown=app:app /out/spring-boot-loader/ ./
COPY --from=build --chown=app:app /out/snapshot-dependencies/ ./
COPY --from=build --chown=app:app /out/application/ ./

# Configuration comes from the environment at run time - never COPY a .env or a
# secret into an image layer (.dockerignore keeps .env* out of the build context).
ENV SPRING_PROFILES_ACTIVE=production
EXPOSE 8080
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
