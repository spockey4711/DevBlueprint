# Quality gate for DevBlueprint - a documentation-first kit of bash scripts.
# `make check` runs the whole gate: shellcheck (lint) plus the bats CLI suite
# (test). CI runs the same. There is no compile step, so `build` is a no-op and
# there is no separate typecheck.
.PHONY: check lint test build

# Every shell script in the kit: the CLI, the worktree manager, the curl|sh
# installer, and the variant setups.
SHELL_FILES := bin/devblueprint scripts/wt.sh scripts/protect-branches.sh scripts/scaffold-check.sh scripts/beginner-artifacts-check.sh scripts/docs-check.sh scripts/docs-freshness.sh install.sh $(wildcard variants/*/setup.sh)

# The npm launcher is the kit's only JavaScript (npm channel only).
JS_FILES := packaging/npm/launch.cjs

check: lint test

# Syntax-check every script (always available); add shellcheck when installed.
lint:
	@for f in $(SHELL_FILES); do echo "bash -n $$f"; bash -n "$$f"; done
	@if command -v shellcheck >/dev/null 2>&1; then \
	  echo "shellcheck $(SHELL_FILES)"; shellcheck $(SHELL_FILES); \
	else \
	  echo "shellcheck not installed - skipping (CI enforces it)"; \
	fi
	@if command -v node >/dev/null 2>&1; then \
	  for f in $(JS_FILES); do echo "node --check $$f"; node --check "$$f"; done; \
	else \
	  echo "node not installed - skipping launcher check (CI enforces it)"; \
	fi

# CLI test suite (bats): scaffolds into temp dirs and asserts init/doctor,
# overwrite safety, branch modes and token substitution. Always available in CI;
# locally it is skipped if bats is not installed (same shape as shellcheck).
test:
	@if command -v bats >/dev/null 2>&1; then \
	  bats test/; \
	else \
	  echo "bats not installed - skipping (CI enforces it)"; \
	fi

build:
	@echo "nothing to build - DevBlueprint is scripts and docs"
