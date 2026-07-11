# Quality gate for a Terraform IaC project. `make check` runs the whole gate; CI
# calls the same tools. Everything runs through the terraform CLI and tflint on
# the versions pinned in .tool-versions and .terraform.lock.hcl - local, CI and
# teammates match.
.PHONY: check validate-env fmt fmt-check init validate lint test plan scan clean

check: validate-env fmt-check validate lint test

# Enforce the environment contract: .env.example must stay in lockstep with
# .env.schema, and a real .env (if present) must satisfy every required key. This
# is stack-agnostic and always on - fill in the schema, not this target.
validate-env:
	@sh scripts/check-env.sh

# fmt-check verifies canonical formatting (terraform fmt); validate runs the
# terraform type/consistency check; lint runs tflint (provider/naming/deprecation
# rules); test runs the native terraform test framework. Separate targets so a red
# one is obvious.
fmt-check:
	terraform fmt -check -recursive

fmt:
	terraform fmt -recursive

# validate and test need providers/modules installed. Init without a backend so
# it runs offline and in CI without remote-state credentials.
init:
	terraform init -backend=false -input=false

validate: init
	terraform validate

lint:
	tflint --init
	tflint --recursive

test: init
	terraform test

# plan is the human-review step against real state (not part of the merge gate).
plan:
	terraform plan

# scan runs the Trivy IaC misconfiguration check locally, mirroring the security
# workflow. Not part of `make check` (it needs network for the policy DB); CI runs
# it in security.yml.
scan:
	trivy config .

clean:
	rm -rf .terraform *.tfplan crash.log
