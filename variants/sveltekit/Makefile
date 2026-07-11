# Quality gate for a SvelteKit / pnpm project. `make check` runs the whole gate;
# CI calls the same underlying pnpm scripts. Everything runs through the
# pnpm-installed toolchain so local, CI and teammates use the versions pinned in
# pnpm-lock.yaml.
.PHONY: check lint format format-check typecheck test test-e2e build dev clean install

check: lint typecheck test build

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
