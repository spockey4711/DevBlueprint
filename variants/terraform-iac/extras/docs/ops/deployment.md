# Deployment runbook (Terraform)

A runbook, not a hosted deploy. For an Infrastructure-as-Code stack "deploying" means running
Terraform: `terraform init` -> `plan` -> `apply` against a cloud provider, with state kept in a
shared remote backend and every apply gated on a reviewed plan. This document covers that
workflow plus the state-backend, secrets and environment checklists that apply whichever cloud
you target.

Before any plan or apply, the quality gate must be green:

```bash
make check
```

CI runs the same gate on every PR - never apply a commit that has not passed it.

## Why there is no Dockerfile / docker-compose / fly.toml / render.yaml here

The container and PaaS ops artifacts the application variants ship (a `Dockerfile`,
`.dockerignore`, `docker-compose.yml`, and `deploy/fly.toml` / `deploy/render.yaml` /
`deploy/terraform/`) are **deliberately omitted** for this variant. Those files exist to package
and host an application; this variant *is* the deploy / infrastructure layer, so it has no app to
containerize and no separate `deploy/terraform/` tree to scaffold - the whole repository already
is the Terraform code. Shipping them would be redundant and misleading. What remains, and what
this variant ships, is the piece that still applies: a validated environment contract
(`.env.schema` + `.env.example`, enforced by `scripts/check-env.sh` in the gate) and this runbook.

## Environment variables

Copy `.env.example` to `.env` for local work and set the same keys in your CI secret store and
your shell (or a secrets manager) for plan/apply. Never commit a real `.env*` file (only
`.env.example` is tracked) or a real `*.tfvars`. Read provider credentials, backend config and
`TF_VAR_*` inputs from the environment or a secrets manager at plan/apply time - never hard-code
a secret in code, logs or committed files. `.env.schema` is the contract these variables must
satisfy, and `make check` fails if `.env.example` drifts from it (or if a real `.env` is missing
a required key) - so the environment stays validated, not just documented.

- [ ] Every key in `.env.example` has a value in the target's secret store and your plan/apply
      environment.
- [ ] Provider credentials and state-backend secrets are read from the environment or a secrets
      manager, never committed or logged.
- [ ] `TF_VAR_environment` matches the environment you are applying to (dev/staging/production).
- [ ] Values differ per environment - no shared production credentials or state.
- [ ] Required keys and value formats are declared in `.env.schema` so the gate catches a missing
      or malformed one before a plan.
- [ ] Rotate any credential that has ever been committed or pasted into a log/PR.

## Remote state backend

Configure a remote state backend **before any team use** - local state in a shared repo strands
teammates and can leak secrets, since state is stored in plaintext. Pick one and wire it in the
root module's `backend` block:

- [ ] **S3 + DynamoDB** (AWS): an encrypted, versioned S3 bucket for state plus a DynamoDB table
      for locking. Bucket and lock table names come from `TF_BACKEND_BUCKET` / `TF_BACKEND_KEY` /
      `TF_BACKEND_DYNAMODB_TABLE`.
- [ ] **GCS** (GCP): a versioned Cloud Storage bucket (GCS provides locking natively).
- [ ] **Terraform Cloud / Enterprise**: a workspace-backed remote backend that also runs plan/apply
      remotely and stores state for you.
- [ ] State encryption and object versioning are enabled, and access is locked down to the team.
- [ ] Locking is on, so two concurrent applies cannot corrupt state.
- [ ] `.terraform.lock.hcl` is committed so provider versions are reproducible across the team.

`make check` runs `terraform init -backend=false` so `validate` and `test` stay offline and need
no backend credentials; a real `init` (below) points at the configured backend.

## Deploy: terraform init -> plan -> apply

1. **Init.** `terraform init` - resolve providers/modules against the committed
   `.terraform.lock.hcl` and connect to the configured remote backend. In CI this pulls the
   backend config from the environment; locally it reads your `.env`/shell.
2. **Plan.** `terraform plan -out=tfplan` - the plan is the diff. Read it in full before every
   apply; never apply an unreviewed plan. Prefer small, reversible changes so a plan stays easy
   to review and a rollback is a re-apply of the previous config.
3. **Review.** Have a human read the plan (in the PR or the CI job output). This is the gate that
   replaces a code review of the resource diff.
4. **Apply.** `terraform apply tfplan` - apply the exact reviewed plan, not a fresh one. Roll back
   by re-applying the previously-known-good configuration from git.

## CI apply gated on plan review

- [ ] CI runs `terraform plan` on every PR and surfaces the plan for review (the PR is where the
      diff is read and approved).
- [ ] `terraform apply` runs only after the plan is reviewed and the PR is merged - never on an
      unreviewed plan, and against the exact plan artifact that was reviewed.
- [ ] Apply credentials live in the CI secret store, scoped per environment, never in the repo.
- [ ] A protected-environment / manual-approval gate guards production applies, so a human signs
      off before infrastructure changes land.

## After first apply

- [ ] The provisioned infrastructure is reachable and healthy (the resources the plan created
      actually exist and respond).
- [ ] A trivial change plans, is reviewed, and applies end-to-end (proves the pipeline, not just
      the first apply).
- [ ] Remote state is populated, encrypted, versioned and locked - and a teammate can plan against
      it without stepping on you.
- [ ] A rollback (re-applying the previous config) has been rehearsed once, before you need it.
