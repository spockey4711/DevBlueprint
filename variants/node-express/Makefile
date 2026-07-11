# Quality gate for a Node/Express/TypeScript API. `make check` runs the whole
# gate; CI calls the same npm scripts. The scripts themselves live in
# package.json (wired by setup.sh), so this stays a thin wrapper.
.PHONY: check validate-env lint format typecheck test build clean

check: validate-env lint typecheck test build

# Enforce the environment contract: .env.example must stay in lockstep with
# .env.schema, and a real .env (if present) must satisfy every required key. This
# is stack-agnostic and always on - fill in the schema, not this target.
validate-env:
	@sh scripts/check-env.sh

lint:
	npm run lint

format:
	npm run format

typecheck:
	npm run typecheck

test:
	npm test

build:
	npm run build

clean:
	rm -rf dist coverage .eslintcache *.tsbuildinfo
