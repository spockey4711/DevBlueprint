# Deployment runbook (.NET)

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
environment (12-factor) - never hard-code a secret in code, logs or committed files. In .NET a `__`
(double underscore) in a variable name binds to a nested config section, so
`ConnectionStrings__Default` maps to `ConnectionStrings:Default`. `.env.schema` is the contract these
variables must satisfy, and `make check` fails if `.env.example` drifts from it (or if a real `.env`
is missing a required key) - so the environment stays validated, not just documented.

- [ ] Every key in `.env.example` has a value in the target's secret store.
- [ ] Secrets (connection strings, API keys, JWT secrets) are read from the environment, never
      committed or logged.
- [ ] `ASPNETCORE_ENVIRONMENT=Production` in the deployed environment.
- [ ] Values differ per environment (staging/production) - no shared production secrets.
- [ ] Required keys and value formats are declared in `.env.schema` so the gate catches a missing
      or malformed one before deploy.
- [ ] Rotate any secret that has ever been committed or pasted into a log/PR.

## Database

Skip this section if the service has no database.

- [ ] Provision the database and put its connection string in the secret store (see above), read as
      `ConnectionStrings__Default`.
- [ ] Run EF Core migrations as a deliberate release step, not on app boot: `dotnet ef database
      update` (or apply a `dotnet ef migrations bundle` artifact) in a release step or one-off job.
      Do not call `Database.Migrate()` on startup in production.
- [ ] Configure the connection pool (Npgsql/provider pooling, `Max Pool Size`) for the runtime;
      front many short-lived connections with a pooler (PgBouncer, or the provider's pooled URL).
- [ ] Backups are enabled and you have restored one at least once.
- [ ] Migrations are backward-compatible with the currently-running version (expand-then-contract),
      so a rollback does not strand the schema.

## Target: managed platform (Render / Fly.io / Railway)

A PaaS that builds and hosts from your repo - the path of least resistance.

Starter configs ship under `deploy/` - `deploy/fly.toml` (Fly.io), `deploy/render.yaml` (Render),
and `deploy/terraform/` for declarative provisioning; keep the one you use and fill in its `<...>`
placeholders (see `deploy/README.md`).

1. Connect the Git repository; set the production branch to your default branch.
2. Publish a Release build (`dotnet publish -c Release -o out`) and set the start command to run the
   published entry assembly (`dotnet App.dll`). Many platforms detect .NET automatically; the shipped
   `Dockerfile` (below) gives you full control. Bind Kestrel to the platform's port via
   `ASPNETCORE_URLS` (or map an injected `PORT`).
3. Add every key from `.env.example` to the platform's secret/config store, scoped per environment.
4. Add a health check pointing at the app's health route. Deploy from the production branch; roll
   back by re-promoting the previous release.

## Target: Docker

A multi-stage build keeps the SDK out of the final image.

1. Fill in the shipped multi-stage `Dockerfile`: an `mcr.microsoft.com/dotnet/sdk:8.0` build stage
   that runs `dotnet restore` then `dotnet publish -c Release -o /app`, then an
   `mcr.microsoft.com/dotnet/aspnet:8.0` runtime stage (or a chiseled/distroless tag) that copies the
   published output and runs as a non-root user. `.dockerignore` already keeps VCS history and
   `.env*` out of the build context.
2. Build and run - or use `docker compose up --build`, which reads the shipped
   `docker-compose.yml`:

   ```bash
   docker build -t my-app .
   docker run -p 8080:8080 --env-file .env.production my-app
   ```

3. Kestrel listens on `ASPNETCORE_URLS` (the image binds `http://+:8080`); put a reverse proxy
   (nginx/Caddy or the platform's load balancer) in front for TLS.
4. Tag images with the commit SHA, never rely on `latest`; roll back by redeploying the previous
   tag.

## Target: plain VPS

Full control, most manual. You own the runtime, the process manager, and TLS.

1. Publish in CI or locally (`dotnet publish -c Release -o out`); the pinned SDK from
   `.tool-versions` and `global.json` (via asdf/mise) keeps the build reproducible. A
   framework-dependent publish needs the ASP.NET runtime on the host; a self-contained publish
   (`--self-contained -r <rid>`) bundles it so there is no runtime to install.
2. Ship the published output to the host (scp/rsync or fetch a release artifact).
3. Run it under a process manager - a systemd unit is the boring default - with the env file loaded
   and auto-restart on crash/reboot. Set `ASPNETCORE_ENVIRONMENT=Production` and bind
   `ASPNETCORE_URLS` to a local port.
4. Front it with nginx or Caddy for TLS termination and reverse-proxy to the app's local port.
5. Roll back by swapping in the previous published output and restarting the service - keep the last
   known-good build around.

## After first deploy

- [ ] The app responds over HTTPS on the real domain.
- [ ] A trivial change deploys end-to-end (proves the pipeline, not just the first push).
- [ ] Logs and an uptime/health check are visible somewhere you will actually look.
- [ ] A rollback has been tested once, before you need it.
