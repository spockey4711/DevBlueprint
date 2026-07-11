
---

## Stack-specific conventions (Infrastructure as Code / Terraform)

### Language & tooling

- **One pinned toolchain.** Pin the Terraform CLI in `.tool-versions` and the `required_version`
  constraint, pin providers with `required_providers` version constraints, and commit
  `.terraform.lock.hcl` so everyone resolves the exact same provider hashes.
- **`terraform fmt`** owns formatting - do not hand-format, run `terraform fmt -recursive` to fix
  and `terraform fmt -check -recursive` to gate. **`terraform validate`** checks configuration and
  types; **tflint** owns lint (deprecated syntax, naming, provider-aware rules). A reported issue
  fails the build. Zero in CI.
- **Scan for misconfiguration.** Trivy (`trivy config .`) runs in CI and flags insecure defaults;
  treat a HIGH/CRITICAL finding as a build failure, not a warning.

### Structure & Terraform idioms

- Layer by responsibility: reusable, provider-agnostic building blocks in `modules/`; a root module
  composes them and owns the backend, provider config and per-environment inputs. Keep modules
  small and single-purpose.
- **Modules are the boundary.** Consume a module only through its input variables and outputs, never
  by reaching into its resources. Expose a typed interface - `variables.tf` with `description` and
  `validation` blocks, `outputs.tf` with descriptions - and never hard-code a value a caller owns.
- **Prefer `for_each` over `count`** for collections so resources have stable, key-addressed
  identities; removing one element does not re-index and destroy the rest.
- Keep `locals` for derived values and naming, `data` sources for lookups; do not repeat literals -
  compute a name/tag once in `locals` and reference it.

### State & security

- **State can contain secrets in plaintext.** Never commit it (it is git-ignored); store it in a
  remote backend with encryption and state locking. Never point two environments at one state file.
- **Never trust or commit secrets.** Read them from a secret manager or `TF_VAR_*`/environment at
  plan/apply time; ship `example.tfvars` with safe placeholders and keep real `*.tfvars` out of
  git. Mark sensitive variables and outputs `sensitive = true`.
- **Pin, don't drift.** Reference remote modules by a pinned version (tag or `?ref=`), never a
  moving branch. Read the `terraform plan` before every apply; never apply an unreviewed plan.
- **Least privilege.** Scope IAM/roles and network rules to exactly what a resource needs;
  encrypt at rest, keep storage private, and let Trivy/tflint catch the insecure default.

### Naming

- Resources, variables, outputs, locals and modules use `snake_case`
  (`aws_s3_bucket.app_assets`, `var.instance_count`). Do not repeat the resource type in its local
  name (`aws_s3_bucket.assets`, not `aws_s3_bucket.assets_bucket`); name the singular unnamed
  resource `this`.
- Files by role: `main.tf` (resources / module calls), `variables.tf`, `outputs.tf`,
  `versions.tf` (`required_version` + `required_providers`), `providers.tf` for provider config.
- Tag every taggable resource consistently (project, environment, owner, managed-by) from a shared
  `locals` map, not per-resource literals.
