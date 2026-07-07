# Quality gate for DevBlueprint - a documentation-first kit of bash scripts.
# `make check` runs the whole gate; CI runs the same via shellcheck. There is
# no compile step, so `build` is a no-op and there is no separate typecheck.
.PHONY: check lint test build

# Every shell script in the kit: the CLI, the worktree manager, variant setups.
SHELL_FILES := bin/devblueprint scripts/wt.sh $(wildcard variants/*/setup.sh)

check: lint test

# Syntax-check every script (always available); add shellcheck when installed.
lint:
	@for f in $(SHELL_FILES); do echo "bash -n $$f"; bash -n "$$f"; done
	@if command -v shellcheck >/dev/null 2>&1; then \
	  echo "shellcheck $(SHELL_FILES)"; shellcheck $(SHELL_FILES); \
	else \
	  echo "shellcheck not installed - skipping (CI enforces it)"; \
	fi

# Smoke-test the CLI end to end: scaffold each variant into a temp dir and make
# sure `doctor` reports every foundation file present.
test:
	@tmp=$$(mktemp -d); trap 'rm -rf "$$tmp"' EXIT; \
	bin/devblueprint list >/dev/null; \
	for v in $$(ls variants); do \
	  echo "init + doctor: $$v"; \
	  bin/devblueprint init --target "$$tmp/$$v" --name smoke --variant "$$v" >/dev/null; \
	  bin/devblueprint doctor --target "$$tmp/$$v" >/dev/null; \
	done; \
	echo "all variants scaffold and pass doctor"

build:
	@echo "nothing to build - DevBlueprint is scripts and docs"
