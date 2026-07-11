# Deployment runbook (Node / Express / TypeScript)

A runbook, not a hosted deploy. It covers the three common targets - a **managed platform**
(Render/Fly.io/Railway), a **Docker** image, and a **plain VPS** - plus the database and
environment-variable checklists that apply to all of them. Keep the section for the target you chose
and delete the rest; if you ran the setup interview, the deploy-target answer already tells you which
one.

Before any deploy, the quality gate must be green:

```bash
npm run lint && npm run typecheck && npm test && npm run build
```

CI runs the same gate on every PR - never deploy a commit that has not passed it.

## Environment variables

Copy `.env.example` to `.env` for local work and set the same keys in your deploy target's secret
store. Never commit a real `.env*` file (only `.env.example` is tracked). Read config from the
environment (`process.env`, validated at startup) - never hard-code a secret. `.env.schema` is the
contract these variables must satisfy, and `make check` fails if `.env.example` drifts from it (or if
a real `.env` is missing a required key) - so the environment stays validated, not just documented.

- [ ] Every key in `.env.example` has a value in the target's secret store.
- [ ] Secrets (DB URLs, API keys) are read from the environment, never committed or logged.
- [ ] `NODE_ENV=production` in the deployed environment (Express skips dev-only work, and deps
      install with `npm ci --omit=dev` for the runtime).
- [ ] Values differ per environment (staging/production) - no shared production secrets.
- [ ] Required keys and value formats are declared in `.env.schema` so the gate catches a missing
      or malformed one before deploy.
- [ ] Rotate any secret that has ever been committed or pasted into a log/PR.

## Database

Skip this section if the service has no database.

- [ ] Provision the database and put its connection string in the secret store (see above).
- [ ] Run migrations as a deliberate release step, not on app boot: `npm run db:migrate` (wire this
      script to your ORM/tool, e.g. Prisma/Drizzle/Knex) in a release step or one-off job.
- [ ] Size the connection pool for the runtime; front many short-lived connections with a pooler
      (PgBouncer, or the provider's pooled URL).
- [ ] Backups are enabled and you have restored one at least once.
- [ ] Migrations are backward-compatible with the currently-running version (expand-then-contract),
      so a rollback does not strand the schema.

## Target: managed platform (Render / Fly.io / Railway)

A PaaS that builds and hosts from your repo - the path of least resistance.

Starter configs ship under `deploy/` - `deploy/fly.toml` (Fly.io), `deploy/render.yaml` (Render),
and `deploy/terraform/` for declarative provisioning; keep the one you use and fill in its `<...>`
placeholders (see `deploy/README.md`).

1. Connect the Git repository; set the production branch to your default branch.
2. Build command `npm ci && npm run build`; start command `node dist/server.js` (never `tsx`/`ts-node`
   in production - ship the compiled `dist/`). Many platforms detect Node automatically; the shipped
   `Dockerfile` (below) gives you full control.
3. Add every key from `.env.example` to the platform's secret/config store, scoped per environment.
4. Add a health check pointing at `GET /health`. Deploy from the production branch; roll back by
   re-promoting the previous release.

## Target: Docker

Ship a reproducible image and run it anywhere a container runtime exists.

1. Fill in the shipped multi-stage `Dockerfile`: a `node:22-slim` build stage that runs
   `npm ci && npm run build`, then a slim runtime stage that carries only the production
   `node_modules` (`npm ci --omit=dev`) and `dist/` and runs `node dist/server.js` as the non-root
   `node` user. `.dockerignore` already keeps VCS history and `.env*` out of the build context.
2. Build and run - or use `docker compose up --build`, which reads the shipped
   `docker-compose.yml`:

   ```bash
   docker build -t my-app .
   docker run -p 3000:3000 --env-file .env.production my-app
   ```

3. The app listens on the configured port; put a reverse proxy (nginx/Caddy or the platform's load
   balancer) in front for TLS.
4. Tag images with the commit SHA, never rely on `latest`; roll back by redeploying the previous
   tag.

## Target: plain VPS

Full control, most manual. You own the runtime, the process manager, and TLS.

1. Install the pinned Node from `.tool-versions` (via asdf/mise) on the host; npm ships with it.
2. Deploy the code (git pull or rsync), then `npm ci && npm run build` to produce `dist/`.
3. Run `node dist/index.js` under a process manager - a systemd unit or pm2 - with the env file
   loaded and auto-restart on crash/reboot.
4. Front it with nginx or Caddy for TLS termination and reverse-proxy to `127.0.0.1:3000`.
5. Roll back by checking out the previous release, rebuilding, and restarting the service - keep the
   last known-good build around.

## After first deploy

- [ ] The app responds over HTTPS on the real domain (`GET /health` returns ok).
- [ ] A trivial change deploys end-to-end (proves the pipeline, not just the first push).
- [ ] Logs and an uptime/health check are visible somewhere you will actually look.
- [ ] A rollback has been tested once, before you need it.
