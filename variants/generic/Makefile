# Quality gate for a language-agnostic project. Fill in each target with the real
# command for your stack, then `make check` runs the whole gate. CI calls the same.
.PHONY: check validate-env lint typecheck test build

check: validate-env lint typecheck test build

# Enforce the environment contract: .env.example must stay in lockstep with
# .env.schema, and a real .env (if present) must satisfy every required key. This
# is stack-agnostic and always on - fill in the schema, not this target.
validate-env:
	@sh scripts/check-env.sh

lint:
	@echo "TODO: wire the linter for this project"

typecheck:
	@echo "TODO: wire the type checker (or remove this target)"

test:
	@echo "TODO: wire the test runner"

build:
	@echo "TODO: wire the build/compile step"
