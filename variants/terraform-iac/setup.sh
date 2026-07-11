#!/usr/bin/env bash
# setup.sh - wire the Terraform IaC toolchain after `devblueprint init`.
#
# Idempotent and safe: only creates files that are missing. Run from the project
# root:
#
#   ./setup.sh              # wire config + warm the provider cache
#   ./setup.sh --no-install # wire config only
#
# It does NOT write your infrastructure for you - author the root module
# (main.tf, variables.tf, outputs.tf, versions.tf) and any reusable modules under
# modules/, then the fmt, validate, tflint and terraform test tooling wired here
# applies to them.
set -euo pipefail

DO_INSTALL=1
[ "${1:-}" = "--no-install" ] && DO_INSTALL=0

say() { printf '  %s\n' "$*"; }
write_if_absent() {
  if [ -e "$1" ]; then say "skip $1 (exists)"; return 0; fi
  mkdir -p "$(dirname "$1")"
  cat > "$1"
  say "wrote $1"
}

echo "Wiring the Terraform IaC toolchain..."

# --- tflint config -----------------------------------------------------------
# tflint owns lint rules beyond `terraform validate`: deprecated syntax, naming
# conventions, and provider-specific checks via plugins. `tflint --init` installs
# the plugins listed here; `tflint --recursive` gates. Uncomment a cloud plugin
# for provider-aware rules (unset attributes, invalid instance types, ...).
write_if_absent .tflint.hcl <<'EOF'
# tflint configuration. `tflint --init` installs plugins; `tflint --recursive`
# gates. See https://github.com/terraform-linters/tflint.
config {
  call_module_type = "local"
  force            = false
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Provider-aware rules. Enable the one that matches your target and run
# `tflint --init` to install it.
# plugin "aws" {
#   enabled = true
#   version = "0.35.0"
#   source  = "github.com/terraform-linters/tflint-ruleset-aws"
# }
EOF

# --- versions/toolchain pin --------------------------------------------------
# Pins the Terraform CLI so `make check` and CI reject an unexpected version.
# Keep required_version aligned with .tool-versions. Add your provider blocks and
# run `terraform init` to generate the committed .terraform.lock.hcl.
write_if_absent versions.tf <<'EOF'
# Toolchain and provider version constraints. Keep required_version aligned with
# .tool-versions. After adding required_providers, run `terraform init` to write
# the committed .terraform.lock.hcl so provider versions are reproducible.
terraform {
  required_version = "~> 1.10"

  # required_providers {
  #   aws = {
  #     source  = "hashicorp/aws"
  #     version = "~> 5.0"
  #   }
  # }
}
EOF

# --- example variables file --------------------------------------------------
# example.tfvars is committed (it is un-ignored in .gitignore); real *.tfvars are
# ignored because they carry per-env values and secrets.
write_if_absent example.tfvars <<'EOF'
# Example variable values. Copy to a real, git-ignored *.tfvars (or set TF_VAR_*
# env vars) and fill in per-environment values. Never commit real secrets.
# region = "eu-central-1"
# environment = "dev"
EOF

# --- pre-commit hook (committable, via core.hooksPath) -----------------------
# Runs fmt check + validate + tflint so a formatting slip or lint error never
# reaches CI. No-op before providers are installed / a config exists.
write_if_absent .githooks/pre-commit <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if command -v terraform >/dev/null 2>&1 && ls ./*.tf >/dev/null 2>&1; then
  terraform fmt -check -recursive
  terraform validate >/dev/null 2>&1 || terraform init -backend=false -input=false >/dev/null && terraform validate
  # tflint only lints once installed; run it when the binary is available.
  if command -v tflint >/dev/null 2>&1; then
    tflint --recursive
  fi
fi
EOF
chmod +x .githooks/pre-commit 2>/dev/null || true
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git config core.hooksPath .githooks && say "set core.hooksPath = .githooks"
else
  say "not a git repo yet - after 'git init' run: git config core.hooksPath .githooks"
fi

# --- warm the provider cache -------------------------------------------------
if [ "$DO_INSTALL" -eq 1 ] && command -v terraform >/dev/null 2>&1 && ls ./*.tf >/dev/null 2>&1; then
  echo "Installing providers and modules (terraform init -backend=false)..."
  terraform init -backend=false -input=false >/dev/null 2>&1 \
    || say "terraform init failed - run it manually once your root module is set up"
  if command -v tflint >/dev/null 2>&1; then
    tflint --init >/dev/null 2>&1 || say "tflint --init failed - run it manually"
  fi
else
  DO_INSTALL=0
fi

echo
echo "Toolchain wired."
[ "$DO_INSTALL" -eq 0 ] && echo "Still to run yourself:  terraform init  (once a root module exists)"
cat <<'EOF'
Still to do yourself (setup.sh cannot author your infrastructure):
  1. Write the root module at the repo root:
       main.tf        # resources / module calls
       variables.tf   # typed input variables with descriptions
       outputs.tf     # outputs with descriptions
       versions.tf    # required_version + required_providers (scaffolded above)
  2. Add your provider block(s) to versions.tf, then generate the lock file:
       terraform init            # writes the committed .terraform.lock.hcl
  3. Enable the provider-aware tflint plugin in .tflint.hcl for your cloud, then:
       tflint --init
  4. Write tests as tests/*.tftest.hcl (run offline with `plan` assertions where
     possible) so `terraform test` exercises the module.
Verify the gate: terraform fmt -check -recursive && terraform validate && tflint --recursive && terraform test
EOF
