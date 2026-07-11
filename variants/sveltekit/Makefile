# Quality gate for a SvelteKit / pnpm project. `make check` runs the whole gate;
# CI calls the same underlying pnpm scripts. Everything runs through the
# pnpm-installed toolchain so local, CI and teammates use the versions pinned in
# pnpm-lock.yaml.
.PHONY: check validate-env lint format format-check typecheck test test-e2e build dev clean install

check: validate-env lint typecheck test build

# Enforce the environment contract: .env.example must stay in lockstep with
# .env.schema, and a real .env (if present) must satisfy every required key. This
# is stack-agnostic and always on - fill in the schema, not this target.
validate-env:
	@sh scripts/check-env.sh

# lint = Prettier format check + ESLint; typecheck = svelte-check (types across
# .svelte + .ts). Kept as separate targets so a red one is obvious.
lint:
	pnpm lint

typecheck:
	pnpm check

format:
	pnpm format

format-check:
	pnpm exec prettier --check .

test:
	pnpm test

test-e2e:
	pnpm test:e2e

build:
	pnpm build

dev:
	pnpm dev

install:
	pnpm install

clean:
	rm -rf .svelte-kit build coverage playwright-report node_modules/.vite
