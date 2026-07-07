# Deployment runbook (generic)

A runbook, not a hosted deploy - and stack-agnostic, so fill the `<...>` placeholders with your
project's real commands. It covers the three common targets - a **managed platform**, a **Docker**
image, and a **plain VPS** - plus the database and environment-variable checklists that apply to all
of them. Keep the section for the target you chose and delete the rest; if you ran the setup
interview, the deploy-target answer already tells you which one.

Before any deploy, the quality gate must be green:

```bash
make check
```

CI runs the same gate on every PR - never deploy a commit that has not passed it.

## Environment variables

Copy `.env.example` to `.env` for local work and set the same keys in your deploy target's secret
store. Never commit a real `.env*` file (only `.env.example` is tracked).

- [ ] Every key in `.env.example` has a value in the target's secret store.
- [ ] Secrets are read from the environment, never hard-coded or committed.
- [ ] Values differ per environment (staging/production) - no shared production secrets.
- [ ] Rotate any secret that has ever been committed or pasted into a log/PR.

## Database

Skip this section if the project has no database.

- [ ] Provision the database and put its connection string in the secret store (see above).
- [ ] Run migrations as a deliberate release step, not on app boot: `<your migrate command>`.
- [ ] Connection pool sized for the runtime; use a pooler if the platform opens many short-lived
      connections.
- [ ] Backups are enabled and you have restored one at least once.
- [ ] Migrations are backward-compatible with the running version (expand-then-contract), so a
      rollback does not strand the schema.

## Target: managed platform

A PaaS (Render, Fly.io, Railway, App Engine, and similar) that builds and hosts from your repo.

1. Connect the Git repository; set the production branch to your default branch.
2. Configure the build command (`<your build command>`) and the start command
   (`<your run command>`).
3. Add every key from `.env.example` to the platform's secret/config store, scoped per environment.
4. Deploy from the production branch; roll back by re-promoting the previous release.

## Target: Docker

Ship a reproducible image and run it anywhere a container runtime exists.

1. Write a multi-stage `Dockerfile` (build stage -> slim runtime stage) that runs as a non-root user
   and exposes the app port.
2. Build and run:

   ```bash
   docker build -t my-app .
   docker run -p <port>:<port> --env-file .env.production my-app
   ```

3. Put a reverse proxy (nginx/Caddy or the platform's load balancer) in front for TLS.
4. Tag images with the commit SHA, never rely on `latest`; roll back by redeploying the previous
   tag.

## Target: plain VPS

Full control, most manual. You own the runtime, the process manager, and TLS.

1. Install the pinned toolchain from `.tool-versions` (via asdf/mise) on the host.
2. Deploy the code (git pull or rsync), then build/install: `<your build command>`.
3. Run the app under a process manager - a systemd unit is the boring default - with the env file
   loaded and auto-restart on crash/reboot.
4. Front it with nginx or Caddy for TLS termination and reverse-proxy to the app's local port.
5. Roll back by checking out the previous release and restarting the service - keep the last known-
   good build around.

## After first deploy

- [ ] The app responds over HTTPS on the real domain.
- [ ] A trivial change deploys end-to-end (proves the pipeline, not just the first push).
- [ ] Logs and an uptime/health check are visible somewhere you will actually look.
- [ ] A rollback has been tested once, before you need it.
