# Flavor: Container (Docker)

Layered on with `--flavor docker`. This add-on brings a `.dockerignore` tuned to
keep the build context small and secret-free; the `Dockerfile` itself is
stack-specific, so you write it (a skeleton is below).

## What landed

- `.dockerignore` - excludes VCS metadata, dependency/build output, local `.env`
  files and editor cruft from the build context.

## Add a Dockerfile

The right base image and build steps depend on your stack, so this flavor stays
documentation-first rather than shipping a Dockerfile that cannot build your app.
Start from this skeleton and fill in the stack-specific lines:

```dockerfile
# Pin a specific, minimal base image (a digest is even better than a tag).
FROM <language>:<version>-slim AS build
WORKDIR /app

# Install dependencies first so the layer caches across source-only changes.
COPY <lockfiles> ./
RUN <install dependencies>

# Then the source, and build.
COPY . .
RUN <build>

# Runtime stage: copy only what production needs.
FROM <language>:<version>-slim
WORKDIR /app
COPY --from=build /app/<artifacts> ./

# Never run as root.
RUN useradd --create-home app
USER app

EXPOSE 8080
CMD ["<start command>"]
```

## Guidelines

- Multi-stage build: compile in a build stage, copy only the artifacts into a slim
  runtime stage, so the final image carries no build toolchain.
- Run as a non-root user (`USER app`), and pin the base image to a digest so builds
  are reproducible.
- Pass configuration and secrets in at runtime (env vars, mounted files); never
  `COPY` a `.env` or a credential into an image layer.
- Add a `.github/workflows/` step to build the image on CI if you publish it.

## Verify

```bash
docker build -t myapp .
docker run --rm -p 8080:8080 myapp
```
