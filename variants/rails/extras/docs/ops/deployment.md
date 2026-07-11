# Deployment runbook (Rails)

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
store. Never commit a real `.env*` file (only `.env.example` is tracked), and never commit
`config/master.key` - Rails reads `RAILS_MASTER_KEY` from the environment. Read config from the
environment (12-factor) - never hard-code a secret in code, logs or committed files. `.env.schema`
is the contract these variables must satisfy, and `make check` fails if `.env.example` drifts from
it (or if a real `.env` is missing a required key) - so the environment stays validated, not just
documented.

- [ ] Every key in `.env.example` has a value in the target's secret store.
- [ ] `SECRET_KEY_BASE` is set in production (generate one with `bin/rails secret`) and kept in the
      secret store, never committed.
- [ ] `RAILS_MASTER_KEY` (or the per-environment credentials key) is in the secret store, not in git.
- [ ] Secrets (DB URLs, API keys) are read from the environment, never committed or logged.
- [ ] `RAILS_ENV=production` and `RAILS_LOG_TO_STDOUT=true` in the deployed environment.
- [ ] Values differ per environment (staging/production) - no shared production secrets.
- [ ] Required keys and value formats are declared in `.env.schema` so the gate catches a missing
      or malformed one before deploy.
- [ ] Rotate any secret that has ever been committed or pasted into a log/PR.

## Assets

Rails serves precompiled assets in production. The shipped `Dockerfile` runs
`rails assets:precompile` in its build stage (with a dummy `SECRET_KEY_BASE`, so the build never
needs the real one), and native/PaaS builds usually run it as part of the build step.

- [ ] `bundle exec rails assets:precompile` runs in the build (image build stage, or the platform's
      build command), not on boot.
- [ ] `RAILS_SERVE_STATIC_FILES=true` when no separate web server/CDN fronts `public/` - otherwise
      let the reverse proxy or CDN serve `public/assets`.

## Database

Skip this section if the app has no database.

- [ ] Provision the database and put its connection string in the secret store as `DATABASE_URL`
      (see above).
- [ ] Run migrations as a deliberate release step, not on app boot: `bin/rails db:migrate` in a
      release command / one-off job (Fly's `release_command`, Render's `preDeployCommand`, a VPS
      deploy hook) - never from the container entrypoint.
- [ ] Tune the connection pool (`RAILS_MAX_THREADS` / `config/database.yml` `pool`) to match Puma's
      thread count; front many short-lived connections with a pooler (PgBouncer, or the provider's
      pooled URL) on serverless/managed platforms.
- [ ] Backups are enabled and you have restored one at least once.
- [ ] Migrations are backward-compatible with the currently-running version (expand-then-contract),
      so a rollback does not strand the schema.

## Target: managed platform (Render / Fly.io / Railway)

A PaaS that builds and hosts from your repo - the path of least resistance.

Starter configs ship under `deploy/` - `deploy/fly.toml` (Fly.io), `deploy/render.yaml` (Render),
and `deploy/terraform/` for declarative provisioning; keep the one you use and fill in its `<...>`
placeholders (see `deploy/README.md`).

1. Connect the Git repository; set the production branch to your default branch.
2. Many platforms detect Ruby/Rails automatically and run `bundle install` + `assets:precompile`;
   the shipped `Dockerfile` (below) gives you full control. Set the start command to
   `bundle exec puma -C config/puma.rb`.
3. Add every key from `.env.example` to the platform's secret/config store, scoped per environment
   (`SECRET_KEY_BASE`, `RAILS_MASTER_KEY`, `DATABASE_URL`).
4. Wire migrations as a release step (`fly.toml` `release_command`, Render `preDeployCommand`), not
   on boot.
5. Add a health check pointing at the app's health route (`/up` on Rails 7.1+). Deploy from the
   production branch; roll back by re-promoting the previous release.

## Target: Docker

The shipped multi-stage `Dockerfile` builds a self-contained image.

1. The shipped `Dockerfile` uses a `ruby:3.3-slim` build stage that runs `bundle install` and
   `rails assets:precompile`, then a slim non-root runtime stage running Puma. `.dockerignore`
   already keeps VCS history, `.env*` and `config/master.key` out of the build context.
2. Build and run - or use `docker compose up --build`, which reads the shipped
   `docker-compose.yml`:

   ```bash
   docker build -t my-app .
   docker run -p 3000:3000 --env-file .env.production my-app
   ```

3. Run migrations as a separate one-off before promoting the new image:

   ```bash
   docker run --rm --env-file .env.production my-app bin/rails db:migrate
   ```

4. Puma listens on the configured port; put a reverse proxy (nginx/Caddy or the platform's load
   balancer) in front for TLS.
5. Tag images with the commit SHA, never rely on `latest`; roll back by redeploying the previous
   tag.

## Target: plain VPS

Full control, most manual. You own the Ruby runtime, the process manager, and TLS.

1. Install the pinned Ruby from `.tool-versions` (via asdf/mise) on the host, then
   `bundle install --deployment --without development test`.
2. Ship the code to the host (git pull, or a release artifact), then
   `RAILS_ENV=production bin/rails assets:precompile` and `RAILS_ENV=production bin/rails db:migrate`
   as explicit release steps.
3. Run Puma under a process manager - a systemd unit is the boring default - with the env file
   loaded and auto-restart on crash/reboot.
4. Front it with nginx or Caddy for TLS termination and reverse-proxy to Puma's local port.
5. Roll back by checking out the previous release and restarting the service - keep the last known-
   good release around, and remember migrations are expand-then-contract so the old code still runs.

## After first deploy

- [ ] The app responds over HTTPS on the real domain.
- [ ] A trivial change deploys end-to-end (proves the pipeline, not just the first push).
- [ ] Logs and an uptime/health check are visible somewhere you will actually look.
- [ ] A rollback has been tested once, before you need it.
