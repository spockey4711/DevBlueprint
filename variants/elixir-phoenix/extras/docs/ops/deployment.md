# Deployment runbook (Elixir / Phoenix)

A runbook, not a hosted deploy. It covers the three common targets - a **managed platform**
(Fly.io/Render/Gigalixir), a **Docker** image, and a **plain VPS** - plus the database and
environment-variable checklists that apply to all of them. Keep the section for the target you chose
and delete the rest; if you ran the setup interview, the deploy-target answer already tells you which
one. Fly.io is a common Phoenix target and the one the shipped `deploy/fly.toml` is tuned for.

Before any deploy, the quality gate must be green:

```bash
make check
```

CI runs the same gate on every PR - never deploy a commit that has not passed it.

## Environment variables

Copy `.env.example` to `.env` for local work and set the same keys in your deploy target's secret
store. Never commit a real `.env*` file (only `.env.example` is tracked). Read config from the
environment in `config/runtime.exs` (12-factor) - never hard-code a secret in code, logs or
committed files. `.env.schema` is the contract these variables must satisfy, and `make check` fails
if `.env.example` drifts from it (or if a real `.env` is missing a required key) - so the
environment stays validated, not just documented.

- [ ] Every key in `.env.example` has a value in the target's secret store.
- [ ] `SECRET_KEY_BASE` is set (generate with `mix phx.gen.secret`) and unique per environment.
- [ ] `DATABASE_URL` points at the target's database (if the app uses Ecto).
- [ ] `PHX_HOST` is the public host and `PORT` matches the platform's expected port.
- [ ] Secrets (`SECRET_KEY_BASE`, `DATABASE_URL`, API keys) are read from the environment, never
      committed or logged.
- [ ] `MIX_ENV=prod` in the deployed environment.
- [ ] Values differ per environment (staging/production) - no shared production secrets.
- [ ] Required keys and value formats are declared in `.env.schema` so the gate catches a missing
      or malformed one before deploy.
- [ ] Rotate any secret that has ever been committed or pasted into a log/PR.

## Database

Skip this section if the app has no Ecto database.

- [ ] Provision the database and put its `DATABASE_URL` in the secret store (see above).
- [ ] Run migrations as a deliberate release step, **not on app boot**. A `mix release` has no
      `mix` in the runtime image, so define a release module and invoke it with `eval`:

      ```bash
      bin/app eval "App.Release.migrate"
      ```

      The `App.Release` module (`lib/app/release.ex`) loads the app and calls
      `Ecto.Migrator.run/4` for each repo. Wire the `eval` call into the platform's release/pre-deploy
      hook (`release_command` in `fly.toml`, `preDeployCommand` in `render.yaml`, or a one-off job).
- [ ] Set `POOL_SIZE` for the runtime and front many short-lived connections with a pooler
      (PgBouncer, or the provider's pooled URL).
- [ ] Backups are enabled and you have restored one at least once.
- [ ] Migrations are backward-compatible with the currently-running version (expand-then-contract),
      so a rollback does not strand the schema.

## Target: managed platform (Fly.io / Render / Gigalixir)

A PaaS that builds and hosts from your repo - the path of least resistance, and Fly.io is the
best-trodden Phoenix path.

Starter configs ship under `deploy/` - `deploy/fly.toml` (Fly.io), `deploy/render.yaml` (Render),
and `deploy/terraform/` for declarative provisioning; keep the one you use and fill in its `<...>`
placeholders (see `deploy/README.md`).

1. Connect the Git repository; set the production branch to your default branch.
2. Build an OTP release (`MIX_ENV=prod mix release`) - the shipped `Dockerfile` does this and gives
   you full control; Fly's `fly launch` also generates a working Dockerfile for a Phoenix app.
3. Add every key from `.env.example` to the platform's secret/config store, scoped per environment
   (`fly secrets set SECRET_KEY_BASE=... DATABASE_URL=...`).
4. Wire migrations to the platform's release command (`release_command` / `preDeployCommand`) so
   they run once per deploy, before the new release takes traffic.
5. Add a health check pointing at the app's health route. Deploy from the production branch; roll
   back by re-promoting the previous release.

## Target: Docker

A `mix release` bundles the app and its ERTS into a self-contained tree, so the runtime image needs
no Elixir/Erlang install.

1. Fill in the shipped multi-stage `Dockerfile`: a `hexpm/elixir` build stage that fetches prod
   deps, runs `mix assets.deploy` and `MIX_ENV=prod mix release`, then a `debian:bookworm-slim`
   runtime stage that copies the release and runs as a non-root user. Set the `APP_NAME` build arg
   to your OTP release name. `.dockerignore` already keeps VCS history and `.env*` out of the build
   context.
2. Build and run - or use `docker compose up --build`, which reads the shipped
   `docker-compose.yml`:

   ```bash
   docker build -t my-app .
   docker run -p 4000:4000 --env-file .env.production my-app
   ```

3. Run migrations as a one-off before cutting traffic over:

   ```bash
   docker run --env-file .env.production my-app eval "App.Release.migrate"
   ```

4. The release listens on the configured port; put a reverse proxy (nginx/Caddy or the platform's
   load balancer) in front for TLS.
5. Tag images with the commit SHA, never rely on `latest`; roll back by redeploying the previous
   tag.

## Target: plain VPS

Full control, most manual. You own the runtime, the process manager, and TLS. Ship the release
tarball - there is no Elixir/Erlang to install on the host since the release bundles its own ERTS.

1. Build the release in CI or locally (`MIX_ENV=prod mix release`); the pinned Erlang/Elixir from
   `.tool-versions` (via asdf/mise) keeps the build reproducible. Build on the same OS/arch as the
   host, because the release bundles native artifacts.
2. Ship the release tarball to the host (scp/rsync or fetch a release artifact) and unpack it - no
   runtime install needed.
3. Run migrations once with `bin/app eval "App.Release.migrate"` before starting the new release.
4. Run it under a process manager - a systemd unit is the boring default - with the env file loaded
   and auto-restart on crash/reboot (`bin/app start`).
5. Front it with nginx or Caddy for TLS termination and reverse-proxy to the app's local port.
6. Roll back by swapping in the previous release and restarting the service - keep the last known-
   good build around.

## After first deploy

- [ ] The app responds over HTTPS on the real domain.
- [ ] A trivial change deploys end-to-end (proves the pipeline, not just the first push).
- [ ] Logs and an uptime/health check are visible somewhere you will actually look.
- [ ] A rollback has been tested once, before you need it.
