# Deployment runbook (Rust)

A runbook, not a hosted deploy. It covers the three common targets - a **managed platform**
(Render/Fly.io/Railway), a **Docker** image, and a **plain VPS** - plus the database and
environment-variable checklists that apply to all of them. Keep the section for the target you chose
and delete the rest; if you ran the setup interview, the deploy-target answer already tells you which
one.

Before any deploy, the quality gate must be green:

```bash
make check
```

CI runs the same gate on every PR - never deploy a commit that has not passed it.

## Environment variables

Copy `.env.example` to `.env` for local work and set the same keys in your deploy target's secret
store. Never commit a real `.env*` file (only `.env.example` is tracked). Read config from the
environment (12-factor) - never hard-code a secret in code, logs or committed files. `.env.schema`
is the contract these variables must satisfy, and `make check` fails if `.env.example` drifts from
it (or if a real `.env` is missing a required key) - so the environment stays validated, not just
documented.

- [ ] Every key in `.env.example` has a value in the target's secret store.
- [ ] Secrets (DB URLs, API keys) are read from the environment, never committed or logged.
- [ ] `APP_ENV=production` in the deployed environment.
- [ ] Values differ per environment (staging/production) - no shared production secrets.
- [ ] Required keys and value formats are declared in `.env.schema` so the gate catches a missing
      or malformed one before deploy.
- [ ] Rotate any secret that has ever been committed or pasted into a log/PR.

## Database

Skip this section if the service has no database.

- [ ] Provision the database and put its connection string in the secret store (see above).
- [ ] Run migrations as a deliberate release step, not on app boot: run them in a release step or
      one-off job (wire this to your migration tool, e.g. `sqlx migrate run` or `diesel migration run`).
- [ ] Size the connection pool for the runtime (`sqlx::Pool` / `deadpool` / `bb8` `max_connections`)
      and front many short-lived connections with a pooler (PgBouncer, or the provider's pooled URL).
- [ ] Backups are enabled and you have restored one at least once.
- [ ] Migrations are backward-compatible with the currently-running version (expand-then-contract),
      so a rollback does not strand the schema.

## Target: managed platform (Render / Fly.io / Railway)

A PaaS that builds and hosts from your repo - the path of least resistance.

Starter configs ship under `deploy/` - `deploy/fly.toml` (Fly.io), `deploy/render.yaml` (Render),
and `deploy/terraform/` for declarative provisioning; keep the one you use and fill in its `<...>`
placeholders (see `deploy/README.md`).

1. Connect the Git repository; set the production branch to your default branch.
2. Build a release binary (`cargo build --release`) and set the start command to run it. Many
   platforms detect Rust automatically; the shipped `Dockerfile` (below) gives you full control.
3. Add every key from `.env.example` to the platform's secret/config store, scoped per environment.
4. Add a health check pointing at the app's health route. Deploy from the production branch; roll
   back by re-promoting the previous release.

## Target: Docker

A `cargo build --release` binary makes for a small, self-contained image.

1. Fill in the shipped multi-stage `Dockerfile`: a `rust:1-slim` build stage that runs
   `cargo build --release` (dependencies compiled first for layer reuse), then a distroless runtime
   stage (`gcr.io/distroless/cc-debian12:nonroot`) that copies the single binary and runs as a
   non-root user. For an even smaller image, target `x86_64-unknown-linux-musl` for a fully static
   binary and ship it in `scratch` (see the comment in the `Dockerfile`). `.dockerignore` already
   keeps VCS history and `.env*` out of the build context.
2. Build and run - or use `docker compose up --build`, which reads the shipped
   `docker-compose.yml`:

   ```bash
   docker build -t my-app .
   docker run -p 8080:8080 --env-file .env.production my-app
   ```

3. The binary listens on the configured port; put a reverse proxy (nginx/Caddy or the platform's
   load balancer) in front for TLS.
4. Tag images with the commit SHA, never rely on `latest`; roll back by redeploying the previous
   tag.

## Target: plain VPS

Full control, most manual. You own the runtime, the process manager, and TLS. A single release
binary means there is no toolchain to install on the host.

1. Build the binary in CI or locally (`cargo build --release`); the pinned toolchain from
   `rust-toolchain.toml` / `.tool-versions` keeps the build reproducible.
2. Ship the binary to the host (scp/rsync or fetch a release artifact) - no runtime install needed.
   A dynamically linked build needs a matching glibc on the host; a musl static build needs nothing.
3. Run it under a process manager - a systemd unit is the boring default - with the env file loaded
   and auto-restart on crash/reboot.
4. Front it with nginx or Caddy for TLS termination and reverse-proxy to the app's local port.
5. Roll back by swapping in the previous binary and restarting the service - keep the last known-
   good build around.

## After first deploy

- [ ] The app responds over HTTPS on the real domain.
- [ ] A trivial change deploys end-to-end (proves the pipeline, not just the first push).
- [ ] Logs and an uptime/health check are visible somewhere you will actually look.
- [ ] A rollback has been tested once, before you need it.
