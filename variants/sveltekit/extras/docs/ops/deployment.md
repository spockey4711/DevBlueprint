# Deployment runbook (SvelteKit)

A runbook, not a hosted deploy. It covers the common targets - a **managed platform**
(Vercel/Netlify, or Render/Fly.io with a Node runtime), a **Docker** image (adapter-node), and a
**plain VPS** - plus the database and environment-variable checklists that apply to all of them.
Keep the section for the target you chose and delete the rest; if you ran the setup interview, the
deploy-target answer already tells you which one.

Before any deploy, the quality gate must be green:

```bash
make check
```

CI runs the same gate on every PR - never deploy a commit that has not passed it.

## Choose an adapter first

SvelteKit builds through an adapter, and the adapter is the single biggest deploy decision:

- **Managed (zero-Dockerfile):** `@sveltejs/adapter-vercel` or `@sveltejs/adapter-netlify`. The
  platform builds and serves the app - no image, no process manager. `deploy/vercel.json` is the
  only config to commit for that path.
- **Self-hosted:** `@sveltejs/adapter-node`. `pnpm build` produces a Node server under `build/`
  that you run with `node build`. The shipped `Dockerfile` and every container target assume this
  adapter.

Pick one per build target - the managed adapters and adapter-node are mutually exclusive.

## Environment variables

Copy `.env.example` to `.env` for local work and set the same keys in your deploy target's secret
store. Never commit a real `.env*` file (only `.env.example` is tracked). Read config through
`$env/*` (12-factor) - never hard-code a secret in code, logs or committed files. `.env.schema`
is the contract these variables must satisfy, and `make check` fails if `.env.example` drifts from
it (or if a real `.env` is missing a required key) - so the environment stays validated, not just
documented.

- [ ] Every key in `.env.example` has a value in the target's secret store.
- [ ] Server-only secrets (DB URLs, session secrets) are read from `$env/*/private`, never sent to
      the browser, never committed or logged.
- [ ] `PUBLIC_*` vars are present **at build time** (they are inlined into the client bundle) and
      contain nothing secret - anything behind that prefix is world-readable.
- [ ] `NODE_ENV=production` in the deployed environment.
- [ ] `ORIGIN` is set to the public URL when self-hosting behind a proxy, so form actions and the
      built-in CSRF check resolve correctly.
- [ ] Values differ per environment (staging/production) - no shared production secrets.
- [ ] Required keys and value formats are declared in `.env.schema` so the gate catches a missing
      or malformed one before deploy.
- [ ] Rotate any secret that has ever been committed or pasted into a log/PR.

## Database

Skip this section if the app has no database.

- [ ] Provision the database and put its connection string in the secret store (see above).
- [ ] Run migrations as a deliberate release step, not on app boot (wire this to your migration
      tool, e.g. Drizzle Kit or Prisma Migrate) in a release step or one-off job.
- [ ] Configure the client's connection pool for the runtime; front many short-lived connections
      with a pooler (PgBouncer, or the provider's pooled URL) - especially on serverless adapters.
- [ ] Access the database only from server code (`$lib/server`, `+page.server.ts`, `+server.ts`),
      never from a universal `load` or a component.
- [ ] Backups are enabled and you have restored one at least once.
- [ ] Migrations are backward-compatible with the currently-running version (expand-then-contract),
      so a rollback does not strand the schema.

## Target: managed platform (Vercel / Netlify / Render / Fly.io)

A PaaS that builds and hosts from your repo - the path of least resistance.

Starter configs ship under `deploy/` - `deploy/vercel.json` (Vercel, zero-Dockerfile),
`deploy/fly.toml` (Fly.io), `deploy/render.yaml` (Render), and `deploy/terraform/` for declarative
provisioning; keep the one you use and fill in its `<...>` placeholders (see `deploy/README.md`).

1. Connect the Git repository; set the production branch to your default branch.
2. Swap in the platform's SvelteKit adapter (`@sveltejs/adapter-vercel` / `-netlify`) in
   `svelte.config.js`, or use the shipped adapter-node `Dockerfile` on Render/Fly for full control.
3. Add every key from `.env.example` to the platform's secret/config store, scoped per environment;
   remember `PUBLIC_*` vars must be available in the **build** environment too.
4. Add a health check pointing at the app's health route. Deploy from the production branch; roll
   back by re-promoting the previous release.

## Target: Docker

Self-hosting with `@sveltejs/adapter-node`.

1. Fill in the shipped multi-stage `Dockerfile`: a `node:22-slim` build stage that runs
   `pnpm install --frozen-lockfile` and `pnpm build`, then a slim runtime stage that copies the
   `build/` output plus production dependencies and runs `node build` as the non-root `node` user.
   `.dockerignore` already keeps VCS history and `.env*` out of the build context.
2. Build and run - or use `docker compose up --build`, which reads the shipped
   `docker-compose.yml`:

   ```bash
   docker build -t my-app .
   docker run -p 3000:3000 --env-file .env.production my-app
   ```

3. The adapter-node server listens on the configured port (`PORT`, default 3000); put a reverse
   proxy (nginx/Caddy or the platform's load balancer) in front for TLS, and set `ORIGIN` to the
   public URL so CSRF and form actions resolve.
4. Tag images with the commit SHA, never rely on `latest`; roll back by redeploying the previous
   tag.

## Target: plain VPS

Full control, most manual. You own the runtime, the process manager, and TLS.

1. Build with adapter-node (`pnpm build`) in CI or locally; the pinned Node/pnpm from
   `.tool-versions` (via asdf/mise) keeps the build reproducible.
2. Ship the `build/` output, `package.json` and production `node_modules` to the host (or build on
   the host from a checkout). Install the pinned Node runtime.
3. Run `node build` under a process manager - a systemd unit is the boring default - with the env
   file loaded, `PORT`/`ORIGIN` set, and auto-restart on crash/reboot.
4. Front it with nginx or Caddy for TLS termination and reverse-proxy to the app's local port.
5. Roll back by swapping in the previous build and restarting the service - keep the last known-
   good build around.

## After first deploy

- [ ] The app responds over HTTPS on the real domain.
- [ ] A trivial change deploys end-to-end (proves the pipeline, not just the first push).
- [ ] Logs and an uptime/health check are visible somewhere you will actually look.
- [ ] A rollback has been tested once, before you need it.
