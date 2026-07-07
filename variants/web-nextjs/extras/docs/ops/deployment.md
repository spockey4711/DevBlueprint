# Deployment runbook (Next.js)

A runbook, not a hosted deploy. It covers the three common targets - a **managed platform**
(Vercel/Netlify), a **Docker** image, and a **plain VPS** - plus the database and environment-variable
checklists that apply to all of them. Keep the section for the target you chose and delete the rest;
if you ran the setup interview, the deploy-target answer already tells you which one.

Before any deploy, the quality gate must be green:

```bash
pnpm lint && pnpm typecheck && pnpm test && pnpm build
```

CI runs the same gate on every PR - never deploy a commit that has not passed it.

## Environment variables

Copy `.env.example` to `.env.local` for local work and set the same keys in your deploy target's
secret store. Never commit a real `.env*` file (only `.env.example` is tracked).

- [ ] Every key in `.env.example` has a value in the target's secret store.
- [ ] Server-only secrets (DB URLs, API keys) are **not** prefixed `NEXT_PUBLIC_` - that prefix
      inlines the value into the client bundle and ships it to every visitor.
- [ ] `NODE_ENV=production` in the deployed environment.
- [ ] Values differ per environment (preview/staging/production) - no shared production secrets.
- [ ] Rotate any secret that has ever been committed or pasted into a log/PR.

## Database

- [ ] Provision the database and put its connection string in the secret store (see above).
- [ ] Run migrations as a deliberate step, not on app boot: `pnpm db:migrate` (wire this script to
      your ORM/tool) in a release step or one-off job.
- [ ] The app connects through a pool sized for the platform - serverless/edge runtimes open many
      short-lived connections, so use a pooler (PgBouncer, or the provider's pooled URL).
- [ ] Backups are enabled and you have restored one at least once.
- [ ] Migrations are backward-compatible with the currently-running version (expand-then-contract),
      so a rollback does not strand the schema.

## Target: managed platform (Vercel / Netlify)

The path of least resistance for Next.js - the platform builds and hosts from your repo.

1. Connect the Git repository; set the production branch to your default branch.
2. Framework preset: **Next.js**. Build command `pnpm build`, install command `pnpm install`.
3. Add every key from `.env.example` under the project's Environment Variables, scoped per
   environment.
4. Push to the production branch (or promote a preview) to release. Roll back by re-promoting the
   previous deployment.

## Target: Docker

Use Next.js standalone output so the image ships only the traced runtime deps.

1. Set `output: 'standalone'` in `next.config.js`.
2. Build a multi-stage image (deps -> build -> runtime); the runtime stage copies
   `.next/standalone`, `.next/static`, and `public/`, then runs `node server.js` as a non-root user.
3. Build and run:

   ```bash
   docker build -t my-app .
   docker run -p 3000:3000 --env-file .env.production my-app
   ```

4. Put a reverse proxy (the platform's load balancer, or nginx/Caddy) in front for TLS.
5. Roll back by redeploying the previous image tag - tag images with the commit SHA, never rely on
   `latest`.

## Target: plain VPS

Full control, most manual. You own the runtime, the process manager, and TLS.

1. Install the pinned Node from `.tool-versions` (via asdf/mise) and enable pnpm via corepack.
2. Deploy code (git pull or an rsync of the build), then `pnpm install --prod=false && pnpm build`.
3. Run `pnpm start` under a process manager - systemd unit or pm2 - with the env file loaded and
   auto-restart on crash/reboot.
4. Front it with nginx or Caddy for TLS termination and reverse-proxy to `127.0.0.1:3000`.
5. Roll back by checking out the previous release and restarting the service - keep the last known-
   good build around.

## After first deploy

- [ ] The app responds over HTTPS on the real domain.
- [ ] A trivial change deploys end-to-end (proves the pipeline, not just the first push).
- [ ] Logs and an uptime/health check are visible somewhere you will actually look.
- [ ] A rollback has been tested once, before you need it.
