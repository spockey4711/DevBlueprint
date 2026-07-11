# Deployment runbook (data pipeline)

A runbook, not a hosted deploy. This is a **batch/pipeline** project: the artifact is a container
image that runs the pipeline to completion and exits, dispatched on a schedule - there is no
always-on web service. It covers the three common ways to run that image - a **scheduler /
orchestrator** (cron, Airflow, Prefect, Dagster), a **managed Batch service** (AWS Batch, Cloud
Run jobs, Azure Container Apps jobs), and a **Docker** image you run yourself - plus the
source/warehouse and environment-variable checklists that apply to all of them. Keep the section
for the target you chose and delete the rest.

Before any deploy, the quality gate must be green:

```bash
make check
```

CI runs the same gate on every PR - never deploy a commit that has not passed it.

## Environment variables

Copy `.env.example` to `.env` for local work and set the same keys in your run target's secret
store (the scheduler's secret injection, the Batch job definition's secret refs). Never commit a
real `.env*` file (only `.env.example` is tracked). Read config from the environment (12-factor) -
never hard-code a secret in code, logs or committed files, and pull credentials from a secrets
manager rather than a static value. `.env.schema` is the contract these variables must satisfy, and
`make check` fails if `.env.example` drifts from it (or if a real `.env` is missing a required key) -
so the environment stays validated, not just documented.

- [ ] Every key in `.env.example` has a value in the target's secret store.
- [ ] Secrets (warehouse URLs, object-store keys) are read from the environment / a secrets
      manager, never committed or logged.
- [ ] `APP_ENV=production` in the deployed environment.
- [ ] Values differ per environment (staging/production) - no shared production secrets.
- [ ] Prefer a workload/instance role over static object-store keys where the platform allows it.
- [ ] Required keys and value formats are declared in `.env.schema` so the gate catches a missing
      or malformed one before deploy.
- [ ] Rotate any secret that has ever been committed or pasted into a log/PR.

## Source and warehouse

Skip this section if the pipeline reads and writes only local files.

- [ ] Provision the source/warehouse and put its connection string in the secret store (see above).
- [ ] Treat inputs as immutable and idempotent: a re-run over the same input must produce the same
      output, so a retried run is safe.
- [ ] Write outputs atomically (a staging path swapped in on success) so a failed run never leaves
      a half-written partition downstream consumers might read.
- [ ] Object-store buckets have versioning/lifecycle rules set, so a bad run is recoverable and old
      data expires on a schedule.
- [ ] Schema migrations on the warehouse are a deliberate, backward-compatible step, run before the
      pipeline that depends on them.

## Target: scheduler / orchestrator (cron, Airflow, Prefect, Dagster)

The path of least resistance: an orchestrator triggers the job image on a schedule or when an
upstream dependency lands.

Starter configs ship under `deploy/` - `deploy/terraform/` for declarative provisioning of the
compute and storage; keep it and fill in its `<...>` placeholders (see `deploy/README.md`).

1. Build the job image from the shipped `Dockerfile` and push it to a registry, tagged with the
   commit SHA (never `latest`).
2. Register a task/DAG that runs that image to completion on the schedule you want, injecting every
   key from `.env.example` from the orchestrator's secret store.
3. Set retries with backoff and a run timeout, so a transient failure retries but a stuck run does
   not hang forever.
4. Alert on a failed or missed run (see "Job success and alerting" below) - this replaces the
   always-on health check a web service would have.

## Target: managed Batch service (AWS Batch / Cloud Run jobs / Azure Container Apps jobs)

A cloud service pulls the image, runs it once, and reports success or failure.

1. Push the SHA-tagged image to the provider's registry.
2. Define the job (CPU/memory, the image, the command) and reference secrets from the platform's
   secret store in the job definition - never inline them.
3. Trigger it on a schedule (EventBridge / Cloud Scheduler / a cron trigger) or on demand.
4. Wire the job's failure signal (a non-zero exit / failed state) to your alerting.

## Target: Docker (self-run)

Full control - a cron entry or a Kubernetes CronJob on your own box.

1. Build and run the image - or use `docker compose run --build job`, which reads the shipped
   `docker-compose.yml`. `.dockerignore` already keeps VCS history, `.env*` and bulky `data/` out
   of the build context.

   ```bash
   docker build -t my-pipeline .
   docker run --rm --env-file .env.production my-pipeline
   ```

2. The container runs the pipeline and exits; there is no port and no reverse proxy. Schedule it
   with cron (`0 3 * * * docker run ... my-pipeline`) or a Kubernetes CronJob.
3. Tag images with the commit SHA, never rely on `latest`; roll back by re-running the previous tag.
4. Capture the container's exit code and logs - a non-zero exit is a failed run and must alert.

## Job success and alerting

A batch job has no always-on endpoint to health-check; instead you watch that runs happen and
succeed.

- [ ] A failed run (non-zero exit) raises an alert somewhere you will actually see it.
- [ ] A missed run (the schedule did not fire) alerts too - a silent job that never runs is the
      failure you notice last.
- [ ] Runtime and row counts are logged/emitted, so a run that "succeeds" but processes zero rows
      is visible.
- [ ] Logs from each run are retained and searchable.

## After first deploy

- [ ] The pipeline runs end-to-end on the schedule and produces the expected output.
- [ ] A trivial change deploys and runs on the next trigger (proves the pipeline, not just the
      first push).
- [ ] A failed run is observable: force one and confirm the alert fires.
- [ ] A re-run over the same input is safe (idempotent) and has been tested once.
