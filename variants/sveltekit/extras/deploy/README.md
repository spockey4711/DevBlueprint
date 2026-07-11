# Deploy configs

Optional, per-platform infrastructure config to go with the deployment runbook in
[`../docs/ops/deployment.md`](../docs/ops/deployment.md). These are skeletons: pick
the one target you are deploying to, fill in the `<...>` placeholders, and delete
the rest - several half-configured platforms help no one. If you ran the setup
interview, the deploy-target answer already tells you which to keep.

| Path | Target | Use when |
|------|--------|----------|
| [`vercel.json`](vercel.json) | Vercel | Zero-Dockerfile managed hosting via `@sveltejs/adapter-vercel`. |
| [`../Dockerfile`](../Dockerfile), [`../docker-compose.yml`](../docker-compose.yml) | Any container runtime | You self-host with `@sveltejs/adapter-node` (VPS, Kubernetes, ...). |
| [`fly.toml`](fly.toml) | Fly.io | `fly deploy` from the repo (adapter-node image). |
| [`render.yaml`](render.yaml) | Render | Render Blueprint, provisioned from the repo. |
| [`terraform/`](terraform/) | Any (IaC) | You provision infrastructure declaratively. |

## Managed (zero-Dockerfile) vs self-hosted

Vercel and Netlify are the **zero-Dockerfile managed path**: swap in
`@sveltejs/adapter-vercel` (or `-netlify`), push the repo, and the platform builds and
serves the app - no image, no `docker-compose.yml`, no process manager. `vercel.json` is
the only config you commit for that path.

The shipped [`../Dockerfile`](../Dockerfile) is the **self-hosting path** and assumes
`@sveltejs/adapter-node`: it builds the adapter-node server and runs `node build` as a
non-root user. Fly, Render and any container runtime use that image. Pick one adapter -
the managed adapters and adapter-node are mutually exclusive per build target.

Rules that apply to every target:

- **Secrets never live in these files.** Set them in the platform's secret store
  (`fly secrets set`, the Render dashboard, Vercel/Netlify env settings, Terraform
  variables sourced from a secrets manager) and keep `.env*` out of the repo and out of
  the image (see [`../.dockerignore`](../.dockerignore)).
- **`PUBLIC_*` variables are not secrets.** They are inlined into the client bundle at
  build time, so they must be present at build, and anything behind that prefix is
  world-readable. Keep real credentials in server-only variables.
- **The self-hosted image is built from the repo's `Dockerfile`** (an adapter-node server
  on a slim non-root Node runtime). Tag it with the commit SHA, never `latest`, so a
  rollback is just a redeploy of a known-good tag.
- **`.env.example` / `.env.schema` are the single source of truth** for which variables
  every target must supply. `make check` fails if they drift apart, so the platform config
  above and the app stay in agreement on what the environment needs.
