# Deployment runbook (Laravel)

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
store. Never commit a real `.env*` file (only `.env.example` is tracked). Read config through
`config()` (12-factor) - never call `env()` outside config files, and never hard-code a secret in
code, logs or committed files. `.env.schema` is the contract these variables must satisfy, and
`make check` fails if `.env.example` drifts from it (or if a real `.env` is missing a required key) -
so the environment stays validated, not just documented.

- [ ] `APP_KEY` is generated once (`php artisan key:generate --show`) and stored in the target's
      secret store - never committed and never shared across environments.
- [ ] Every key in `.env.example` has a value in the target's secret store.
- [ ] Secrets (`APP_KEY`, DB credentials, API keys) are read from the environment, never committed
      or logged.
- [ ] `APP_ENV=production` and `APP_DEBUG=false` in the deployed environment (debug output leaks
      internals).
- [ ] Values differ per environment (staging/production) - no shared production secrets.
- [ ] Required keys and value formats are declared in `.env.schema` so the gate catches a missing
      or malformed one before deploy.
- [ ] Rotate any secret that has ever been committed or pasted into a log/PR.

## Database

Skip this section if the app has no database.

- [ ] Provision the database and put its connection string / credentials in the secret store (see
      above).
- [ ] Run migrations as a deliberate release step, not on app boot: `php artisan migrate --force`
      (`--force` because production is non-interactive) in a release step or one-off job.
- [ ] Front many short-lived connections with a pooler (PgBouncer, or the provider's pooled URL);
      keep long-running queue workers on their own connections.
- [ ] Backups are enabled and you have restored one at least once.
- [ ] Migrations are backward-compatible with the currently-running version (expand-then-contract),
      so a rollback does not strand the schema.

## Caching and optimization

Laravel serves faster when its config, routes and views are compiled once per release rather than
resolved per request. Run these as a release step, after the code is in place and the environment is
set, and clear them if you change config at runtime.

- [ ] `php artisan config:cache` - compile all config into one file (this reads `.env`, so the
      environment must be fully set first; `env()` returns null once config is cached).
- [ ] `php artisan route:cache` - compile the route table (skip only if you use closure routes).
- [ ] `php artisan view:cache` - precompile Blade templates.
- [ ] `php artisan event:cache` if you use event discovery.
- [ ] On rollback or a config change, run `php artisan optimize:clear` to drop stale caches.

## Storage permissions

php-fpm (or the web-server user) must own the writable trees, or the app 500s on the first cache or
log write.

- [ ] `storage/` and `bootstrap/cache/` are writable by the runtime user (the Dockerfile chowns them
      to `www-data`; on a VPS set the owner to your php-fpm user).
- [ ] `php artisan storage:link` has been run so `public/storage` points at `storage/app/public`.
- [ ] Do not bake secrets or generated caches into the image - they belong to the runtime, kept out
      of the build context by `.dockerignore`.

## Target: managed platform (Render / Fly.io / Railway)

A PaaS that builds and hosts from your repo - the path of least resistance.

Starter configs ship under `deploy/` - `deploy/fly.toml` (Fly.io), `deploy/render.yaml` (Render),
and `deploy/terraform/` for declarative provisioning; keep the one you use and fill in its `<...>`
placeholders (see `deploy/README.md`).

1. Connect the Git repository; set the production branch to your default branch.
2. Build from the shipped `Dockerfile` (php-fpm with the production dependencies baked in). Point
   the platform's web server at `public/index.php`; most PaaS handle the nginx/php-fpm wiring for
   you, or run their PHP buildpack.
3. Add every key from `.env.example` to the platform's secret/config store, scoped per environment -
   including `APP_KEY`.
4. Wire migrations and cache warming into a release/pre-deploy hook
   (`php artisan migrate --force && php artisan config:cache && php artisan route:cache`), so they
   run once per deploy rather than on boot.
5. Add a health check pointing at Laravel's `/up` route. Deploy from the production branch; roll back
   by re-promoting the previous release.

## Target: Docker

The shipped `Dockerfile` builds a php-fpm image; a web server proxies HTTP to it.

1. Fill in the shipped multi-stage `Dockerfile`: a `php:8.3-fpm` build stage that runs
   `composer install --no-dev --optimize-autoloader`, then a runtime stage that copies the app in,
   chowns `storage/` and `bootstrap/cache/`, and runs php-fpm as the non-root `www-data` user.
   `.dockerignore` already keeps VCS history and `.env*` out of the build context.
2. Build and run - or use `docker compose up --build`, which reads the shipped
   `docker-compose.yml` (uncomment its `web` nginx service to serve HTTP):

   ```bash
   docker build -t my-app .
   docker run --env-file .env.production my-app
   ```

3. php-fpm listens on port 9000; put nginx or Caddy in front (proxying to `app:9000`, document root
   `public/`) for HTTP and TLS. Run migrations and cache warming as a one-off before shifting
   traffic: `docker run --env-file .env.production my-app php artisan migrate --force`.
4. Tag images with the commit SHA, never rely on `latest`; roll back by redeploying the previous
   tag.

## Target: plain VPS

Full control, most manual. You own PHP, php-fpm, the web server and TLS.

1. Install the pinned PHP from `.tool-versions` (via asdf/mise) and the extensions the app needs, so
   the runtime matches CI. Install Composer.
2. Deploy the code (git pull or a release artifact) and run
   `composer install --no-dev --optimize-autoloader`.
3. Set the environment (`.env` on the host, gitignored), then warm caches:
   `php artisan migrate --force && php artisan config:cache && php artisan route:cache`. Ensure
   `storage/` and `bootstrap/cache/` are owned by the php-fpm user.
4. Run php-fpm under a process manager (systemd is the boring default, auto-restart on crash/reboot)
   and front it with nginx or Caddy (document root `public/`, fastcgi to php-fpm) for TLS and static
   files. Run the queue worker and scheduler as their own supervised processes if the app uses them.
5. Roll back by checking out the previous release, re-running the release step, and reloading php-fpm
   - keep the last known-good release around.

## After first deploy

- [ ] The app responds over HTTPS on the real domain.
- [ ] A trivial change deploys end-to-end (proves the pipeline, not just the first push).
- [ ] Logs and an uptime/health check (`/up`) are visible somewhere you will actually look.
- [ ] A rollback has been tested once, before you need it.
