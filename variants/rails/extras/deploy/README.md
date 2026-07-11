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
  secrets manager) and keep `.env*` and `config/master.key` out of the repo and
  out of the image (see [`../.dockerignore`](../.dockerignore)). `SECRET_KEY_BASE`
  and `RAILS_MASTER_KEY` are secrets - they belong in the platform store only.
- **The image is built from the repo's `Dockerfile`** (gems + precompiled assets in
  a slim non-root runtime running Puma). Tag it with the commit SHA, never `latest`,
  so a rollback is just a redeploy of a known-good tag.
- **Migrations are a release step, not a boot step.** Run `rails db:migrate` as a
  deliberate release/one-off job (see the runbook), never from the container's
  entrypoint - a crashing boot must not also touch the schema.
- **`.env.example` / `.env.schema` are the single source of truth** for which
  variables every target must supply. `make check` fails if they drift apart, so
  the platform config above and the app stay in agreement on what the environment
  needs.
