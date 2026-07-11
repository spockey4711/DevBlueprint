# Deploy configs

Optional, per-platform infrastructure config to go with the deployment runbook in
[`../docs/ops/deployment.md`](../docs/ops/deployment.md). These are skeletons: pick
the one target you are deploying to, fill in the `<...>` placeholders, and delete
the rest - three half-configured platforms help no one. If you ran the setup
interview, the deploy-target answer already tells you which to keep.

| Path | Target | Use when |
|------|--------|----------|
| [`../Dockerfile`](../Dockerfile), [`../docker-compose.yml`](../docker-compose.yml) | Any container runtime | You build and run your own image (VPS, Kubernetes, ...). |
| [`fly.toml`](fly.toml) | Fly.io | `fly deploy` from the repo. |
| [`render.yaml`](render.yaml) | Render | Render Blueprint, provisioned from the repo. |
| [`terraform/`](terraform/) | Any (IaC) | You provision infrastructure declaratively. |

Rules that apply to every target:

- **Secrets never live in these files.** Set them in the platform's secret store
  (`fly secrets set`, the Render dashboard, Terraform variables sourced from a
  secrets manager) and keep `.env*` out of the repo and out of the image (see
  [`../.dockerignore`](../.dockerignore)).
- **The image is built from the repo's `Dockerfile`** (a `cargo build --release`
  binary in a distroless runtime). Tag it with the commit SHA, never `latest`, so
  a rollback is just a redeploy of a known-good tag.
- **`.env.example` / `.env.schema` are the single source of truth** for which
  variables every target must supply. `make check` fails if they drift apart, so
  the platform config above and the app stay in agreement on what the environment
  needs.
