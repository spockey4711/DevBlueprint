# Variant: Infrastructure as Code (Terraform)

A declarative infrastructure stack: Terraform for provisioning, `terraform fmt` for formatting,
`terraform validate` for configuration/type checks, tflint for lint (naming, deprecations,
provider-aware rules), the native `terraform test` framework for module tests, Trivy for IaC
misconfiguration scanning, and GitHub Actions CI.

## Quality gate

```bash
terraform fmt -check -recursive && terraform validate && tflint --recursive && terraform test
```

Or, with the shipped Makefile: `make check` (it runs `terraform init -backend=false` first so
`validate` and `test` have their providers).

## What `devblueprint init --variant terraform-iac` adds

- `docs/engineering/` - git-workflow, conventions (+ Terraform/IaC overlay),
  quality-and-testing, engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `terraform init -backend=false`).
- `Makefile` wiring the quality gate (`make check`).
- `.github/workflows/` - `ci.yml` (fmt + validate + tflint + terraform test), plus the shared
  `security.yml` (gitleaks + semgrep + dependency-review, extended with a Trivy IaC misconfig
  scan) and `commit-checks.yml` baseline.
- `.github/dependabot.yml` (terraform + github-actions updates) and `.tool-versions`
  (Terraform + tflint + Trivy pins).
- `.gitignore` for state, the provider cache, plan output, `*.tfvars` secrets and crash logs
  (the committed `.terraform.lock.hcl` is kept).
- `modules`, `tests` scaffold.

There is no `coverage.yml`: Terraform has no line-coverage metric, so `terraform test` runs in
`ci.yml` as the test gate rather than behind a coverage floor.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. It cannot author your infrastructure - write the root
module first, then run setup:

```bash
./setup.sh              # writes .tflint.hcl, versions.tf, example.tfvars, the pre-commit hook
                        # (via core.hooksPath), then runs terraform init -backend=false
./setup.sh --no-install # config only
```

`setup.sh` scaffolds `versions.tf` (`required_version` + a `required_providers` stub) and
`.tflint.hcl` so `make check` and CI enforce the gate. Add your provider block(s), run
`terraform init` to generate the committed `.terraform.lock.hcl`, and enable the provider-aware
tflint plugin for your cloud - the exact snippets are printed at the end of `setup.sh`. Idempotent;
never clobbers existing files.
