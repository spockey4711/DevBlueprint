# Deploy configs

Optional infrastructure config to go with the deployment runbook in
[`../docs/ops/deployment.md`](../docs/ops/deployment.md). These are skeletons: pick
the way you run the job, fill in the `<...>` placeholders, and delete the rest.

This is a **batch/pipeline** project, not a long-running web service, so there is
no always-on host to deploy to and no `fly.toml` / `render.yaml` here. Instead you
publish the container image to a registry and have a **scheduler** run it: cron on
a box, an Airflow/Prefect/Dagster task, or a managed Batch service (AWS Batch, GCP
Cloud Run jobs, Azure Container Apps jobs). Terraform provisions the compute the
scheduler dispatches to and the object storage the pipeline reads and writes.

| Path | Target | Use when |
|------|--------|----------|
| [`../Dockerfile`](../Dockerfile), [`../docker-compose.yml`](../docker-compose.yml) | Any container runtime | You build the job image and run it locally or on your own box (cron, a VM, Kubernetes CronJob). |
| Scheduler / orchestrator | Airflow, Prefect, Dagster, cron | An orchestrator triggers the image on a schedule or a dependency. See the runbook. |
| Managed Batch service | AWS Batch, Cloud Run jobs, Azure Container Apps jobs | A cloud service pulls the image, runs it to completion, and reports success/failure. |
| [`terraform/`](terraform/) | Any (IaC) | You provision the compute (the Batch/job runner) and storage (object-store buckets, the warehouse) declaratively. |

Rules that apply to every target:

- **Secrets never live in these files.** Set them in the platform's secret store
  (the scheduler's secret injection, the Batch job definition's secret refs,
  Terraform variables sourced from a secrets manager) and keep `.env*` out of the
  repo and out of the image (see [`../.dockerignore`](../.dockerignore)).
- **The image is built from the repo's `Dockerfile`** (a `python:3.12-slim` job
  image that runs the pipeline and exits). Tag it with the commit SHA, never
  `latest`, so a rollback is just re-running a known-good tag.
- **`.env.example` / `.env.schema` are the single source of truth** for which
  variables every target must supply. `make check` fails if they drift apart, so
  the platform config above and the pipeline stay in agreement on what the
  environment needs.
