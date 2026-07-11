## Stack notes (Infrastructure as Code / Terraform)

- Worktrees: `./scripts/wt.sh new <type>/<slug>` (post-create runs `terraform init -backend=false`
  to warm the provider/module cache). The Terraform, tflint and Trivy versions are pinned in
  `.tool-versions` and the `required_version` constraint so local, CI and teammates run one
  toolchain; provider versions are pinned in the committed `.terraform.lock.hcl`.
- Layer by responsibility: reusable, provider-agnostic building blocks live in `modules/`; a root
  module composes them and owns the backend, providers and per-environment inputs. Keep modules
  small and single-purpose, expose a typed interface (`variables.tf` with descriptions and
  validation, `outputs.tf`), and never hard-code a value a caller should own.
- Modules are the seam: a root module and another module consume a module only through its input
  variables and outputs, never by reaching into its internals. This keeps infrastructure composable
  and testable without applying to real cloud state.
- `terraform fmt` owns formatting - do not hand-format, run `terraform fmt -recursive` to fix and
  `terraform fmt -check -recursive` to gate. `terraform validate` checks configuration and types;
  tflint owns lint (deprecations, naming, provider-aware rules via `tflint --init`). Treat a
  reported issue as a build failure - zero in CI.
- Never trust or commit secrets. State can contain secrets in plaintext, so it is git-ignored and
  belongs in a remote backend with encryption and locking (never local state in a shared repo).
  Read secrets from a secret manager or `TF_VAR_*`/environment at plan/apply time; ship
  `example.tfvars` with safe placeholders and keep real `*.tfvars` out of git.
- Scan every change for misconfiguration: Trivy (`trivy config .`, wired into CI) flags insecure
  defaults - public buckets, open security groups, unencrypted volumes - before they reach an
  apply. Enable the provider-aware tflint plugin for your cloud so invalid instance types and
  unset required attributes fail fast too.
- Pin everything: `required_version` for the CLI, `required_providers` version constraints, and the
  committed `.terraform.lock.hcl` for exact provider hashes. Reference modules by a pinned version
  (a tag or `?ref=`), never a moving branch, so a plan is reproducible.
- Keep infrastructure changes reviewable: a `terraform plan` is the diff. Make small, reversible
  changes, read the plan before every apply, and never apply an unreviewed plan. Prefer `for_each`
  over `count` for stable addressing so removing one item does not churn the rest.
- Prefer fast, offline `terraform test` (`tests/*.tftest.hcl`) that assert on `plan` output over
  slow `apply`-based tests that touch real cloud state. Use variables and mocked providers so the
  gate stays hermetic; reserve `apply`-run tests for the few behaviors a plan cannot verify.
- The environment is a validated contract: `.env.schema` declares each input Terraform needs
  (provider credentials, the region, the remote-state backend, `TF_VAR_*`; each required/optional
  with an optional `pattern=`), and `make check` (plus CI) runs `scripts/check-env.sh` to keep
  `.env.example` in lockstep with it and enforce required keys in any real `.env`. Declare new
  variables in both the schema and `.env.example`, or the gate fails. See `docs/ops/deployment.md`
  for the `init` -> `plan` -> `apply` runbook, the remote-state-backend setup, and the CI apply
  gated on plan review.
- The container / PaaS ops artifacts the application variants ship (a `Dockerfile`, `.dockerignore`,
  `docker-compose.yml`, and `deploy/fly.toml` / `render.yaml` / `terraform/`) are intentionally
  omitted for this variant: it already *is* the deploy / infrastructure layer, so there is no app to
  containerize and no separate `deploy/terraform/` tree to scaffold - the repository is the
  Terraform code. Only the env contract and runbook, which still apply, ship.
