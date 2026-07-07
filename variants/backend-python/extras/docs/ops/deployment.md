# Deployment runbook (Python / FastAPI)

A runbook, not a hosted deploy. It covers the three common targets - a **managed platform**
(Render/Fly.io/Railway), a **Docker** image, and a **plain VPS** - plus the database and
environment-variable checklists that apply to all of them. Keep the section for the target you chose
and delete the rest; if you ran the setup interview, the deploy-target answer already tells you which
one.

Before any deploy, the quality gate must be green:

```bash
ruff check . && ruff format --check . && mypy . && pytest
```

CI runs the same gate on every PR - never deploy a commit that has not passed it.

## Environment variables

Copy `.env.example` to `.env` for local work and set the same keys in your deploy target's secret
store. Never commit a real `.env*` file (only `.env.example` is tracked). Read config through a
settings object (e.g. Pydantic `BaseSettings`) that loads from the environment - never hard-code a
secret.

- [ ] Every key in `.env.example` has a value in the target's secret store.
- [ ] Secrets (DB URLs, API keys) are read from the environment, never committed or logged.
- [ ] `APP_ENV=production` in the deployed environment, with debug/auto-reload off.
- [ ] Values differ per environment (staging/production) - no shared production secrets.
- [ ] Rotate any secret that has ever been committed or pasted into a log/PR.

## Database

Skip this section if the service has no database.

- [ ] Provision the database and put its connection string in the secret store (see above).
- [ ] Run migrations as a deliberate release step, not on app boot: `alembic upgrade head` (wire
      this to your migration tool) in a release step or one-off job.
- [ ] Size the connection pool for the runtime; front many short-lived connections with a pooler
      (PgBouncer, or the provider's pooled URL). Use an async driver (`asyncpg`) with async SQLAlchemy.
- [ ] Backups are enabled and you have restored one at least once.
- [ ] Migrations are backward-compatible with the currently-running version (expand-then-contract),
      so a rollback does not strand the schema.

## Target: managed platform (Render / Fly.io / Railway)

A PaaS that builds and hosts from your repo - the path of least resistance.

1. Connect the Git repository; set the production branch to your default branch.
2. Build with uv (`uv sync --frozen --no-dev`); start with a production ASGI server:
   `uvicorn app.main:app --host 0.0.0.0 --port $PORT` (or `gunicorn -k uvicorn.workers.UvicornWorker`
   for multiple workers).
3. Add every key from `.env.example` to the platform's secret/config store, scoped per environment.
4. Add a health check pointing at the app's health route. Deploy from the production branch; roll
   back by re-promoting the previous release.

## Target: Docker

Ship a reproducible image and run it anywhere a container runtime exists.

1. Write a multi-stage `Dockerfile`: a build stage that runs `uv sync --frozen --no-dev` into a
   virtualenv, then a slim `python:3.12-slim` runtime stage that copies the venv and app and runs as
   a non-root user.
2. Build and run:

   ```bash
   docker build -t my-app .
   docker run -p 8000:8000 --env-file .env.production my-app
   ```

3. The container runs `uvicorn`/`gunicorn` bound to `0.0.0.0`; put a reverse proxy (nginx/Caddy or
   the platform's load balancer) in front for TLS.
4. Tag images with the commit SHA, never rely on `latest`; roll back by redeploying the previous
   tag.

## Target: plain VPS

Full control, most manual. You own the runtime, the process manager, and TLS.

1. Install the pinned Python and uv from `.tool-versions` (via asdf/mise) on the host.
2. Deploy the code (git pull or rsync), then `uv sync --frozen --no-dev` to build the virtualenv.
3. Run `gunicorn -k uvicorn.workers.UvicornWorker app.main:app` under a process manager - a systemd
   unit is the boring default - with the env file loaded and auto-restart on crash/reboot.
4. Front it with nginx or Caddy for TLS termination and reverse-proxy to the app's local port.
5. Roll back by checking out the previous release and restarting the service - keep the last known-
   good build around.

## After first deploy

- [ ] The app responds over HTTPS on the real domain.
- [ ] A trivial change deploys end-to-end (proves the pipeline, not just the first push).
- [ ] Logs and an uptime/health check are visible somewhere you will actually look.
- [ ] A rollback has been tested once, before you need it.
