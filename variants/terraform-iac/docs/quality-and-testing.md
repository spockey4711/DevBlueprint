# Quality and testing

**Purpose:** the quality bar and how it is enforced for this Terraform IaC project. Concrete overlay
of the blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing (`make check`); CI runs the identical set on every PR:

```bash
terraform fmt -check -recursive   # formatting is canonical (terraform fmt)
terraform validate                 # configuration + type/consistency check
tflint --recursive                 # lint: deprecations, naming, provider-aware rules; an issue = failure
terraform test                     # native module tests (tests/*.tftest.hcl)
```

`make check` runs `terraform init -backend=false` first so `validate` and `test` have their
providers and modules, on the versions pinned by `.terraform.lock.hcl` - so local, CI and teammates
use the same tools. Install the pre-commit hook (`setup.sh` wires it via `core.hooksPath`) and
`terraform fmt -check` + `validate` + tflint run on every commit.

## Testing strategy

Test behavior, not the provider. Favor fast, hermetic tests; assert on `plan` output and mock
providers wherever possible so the gate never touches real cloud state or needs credentials.

- **Plan tests (`terraform test`, `command = plan`):** the default - run a module through a plan and
  assert on resource arguments, computed values and outputs. No cloud calls, no credentials, fast.
- **Validation tests:** exercise `variable` `validation` blocks and `precondition`/`postcondition`
  checks with `expect_failures`, so bad inputs fail at plan time, not apply time.
- **Mocked providers:** use `mock_provider` (and `override_resource`/`override_data`) to supply
  computed attributes, so a plan test stays offline and deterministic.
- **Apply tests (`command = apply`):** reserve for the few behaviors a plan cannot verify. Run them
  against an ephemeral/sandbox account, and let the framework tear the resources back down.

Target meaningful assertions on the module's interface and the rules that matter (naming, security
defaults, conditional logic) - not a resource count, and not provider behavior. Terraform has no
line-coverage metric, so there is no coverage gate; the value is in what each test asserts.

## Tooling

- **Terraform CLI (version pinned in `.tool-versions` + `required_version`)** - provisioning,
  formatting, validation and the test runner.
- **`.terraform.lock.hcl`** - the committed provider dependency lock so installs are reproducible.
- **terraform fmt** - the single formatter; `terraform fmt -recursive` fixes,
  `terraform fmt -check -recursive` gates. No hand-formatting.
- **terraform validate** - configuration, type and reference consistency check.
- **tflint** - lint beyond validate (deprecations, naming, and provider-aware rules via
  `tflint --init`); `tflint --recursive` gates, config in `.tflint.hcl`.
- **terraform test** - the built-in test framework; `tests/*.tftest.hcl` with `plan`/`apply` runs
  and `mock_provider` for hermetic tests.
- **Trivy** - IaC misconfiguration scanning (`trivy config .`); flags insecure defaults and runs in
  the security workflow, failing on HIGH/CRITICAL.
- **pre-commit hook** - `.githooks/pre-commit` runs fmt check + validate + tflint on commit.
- **CI** - `.github/workflows/ci.yml` runs the full gate on every PR into `develop`/`master`.

## Definition of done

1. It works, the plan does what the task asked, and failure modes are handled deliberately
   (variable `validation`, `precondition`/`postcondition`) rather than left to a failed apply.
2. terraform fmt, validate, tflint and the tests are green, Trivy reports no HIGH/CRITICAL
   misconfiguration, and new logic is covered by a `tests/*.tftest.hcl` at the right layer.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR (the `terraform plan` is part of that review).
