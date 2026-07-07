# Quality gate for a Node/Express/TypeScript API. `make check` runs the whole
# gate; CI calls the same npm scripts. The scripts themselves live in
# package.json (wired by setup.sh), so this stays a thin wrapper.
.PHONY: check lint format typecheck test build clean

check: lint typecheck test build

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
