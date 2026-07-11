# syntax=docker/dockerfile:1
#
# Multi-stage build for the .NET service. A build stage with the full SDK
# restores and publishes a Release build, then a slim ASP.NET runtime stage
# ships only the published output and runs as a non-root user - no SDK, no
# compiler, and no build tooling in the final image. See docs/ops/deployment.md
# ("Target: Docker").
#
# Adjust the project path if your entrypoint is not src/App/App.csproj, set
# APP_DLL to your published entry assembly, and pin both base images to a digest
# (name@sha256:...) once you settle on versions - a digest beats a floating tag
# for reproducible, rollback-safe builds. For an even smaller, shell-free image,
# swap the runtime base for a chiseled/distroless one
# (mcr.microsoft.com/dotnet/aspnet:8.0-jammy-chiseled).

# --- Build stage -------------------------------------------------------------
# Match the SDK version to global.json and .tool-versions.
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Restore first so this layer caches across source-only edits. Copy the project
# and solution files, restore, then bring in the rest of the sources.
COPY *.sln ./
COPY src/App/App.csproj src/App/
RUN dotnet restore src/App/App.csproj

# Then the sources, and publish a self-contained-free framework-dependent build.
COPY . .
RUN dotnet publish src/App/App.csproj -c Release -o /app --no-restore

# --- Runtime stage -----------------------------------------------------------
# The aspnet image carries only the ASP.NET runtime - no SDK, no compiler. Pin it
# to a digest in production; swap to a chiseled tag for a shell-free image.
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Create an unprivileged user and never run as root.
RUN useradd --create-home --uid 10001 app
USER app

# Copy only the published output from the build stage.
COPY --from=build /app ./

# Configuration comes from the environment at run time - never COPY a .env or a
# secret into an image layer (.dockerignore keeps .env* out of the build context).
# Kestrel binds to ASPNETCORE_URLS; bind to all interfaces inside the container.
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "App.dll"]
