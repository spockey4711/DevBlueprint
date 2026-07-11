#!/usr/bin/env bash
# setup.sh - wire the SvelteKit/pnpm toolchain after `devblueprint init`.
#
# Idempotent and safe: it only creates files that are missing and adds the
# package.json scripts/fields that are absent, so it can be re-run and will not
# clobber your edits. Run it from the project root:
#
#   ./setup.sh              # wire config + install the dev toolchain
#   ./setup.sh --no-install # wire config only, skip `pnpm add`
#
# It does NOT scaffold the SvelteKit app itself - run `npx sv create .` first
# (or point this at an existing app). The scaffold provides svelte.config.js,
# vite.config.ts, tsconfig.json and src/app.html; this wires the lint / format /
# type-check / test toolchain the quality gate expects on top of it.
set -euo pipefail

DO_INSTALL=1
[ "${1:-}" = "--no-install" ] && DO_INSTALL=0

say() { printf '  %s\n' "$*"; }

# write_if_absent <path> : create the file from stdin unless it already exists.
write_if_absent() {
  if [ -e "$1" ]; then say "skip $1 (exists)"; return 0; fi
  mkdir -p "$(dirname "$1")"
  cat > "$1"
  say "wrote $1"
}

echo "Wiring the SvelteKit toolchain..."

# --- package.json: create if missing, then add scripts + fields idempotently --
if [ ! -f package.json ]; then
  printf '{\n  "name": "%s",\n  "private": true,\n  "type": "module",\n  "version": "0.1.0"\n}\n' \
    "$(basename "$PWD")" > package.json
  say "wrote package.json (minimal)"
fi

PM_VERSION="$(pnpm --version 2>/dev/null || echo 9)"
NODE_MAJOR="$(node -v 2>/dev/null | sed 's/^v//; s/\..*//')"
[ -n "$NODE_MAJOR" ] || NODE_MAJOR=22

# Patch package.json with node (available in a Node project). Only fills gaps.
PM_VERSION="$PM_VERSION" node <<'NODE'
const fs = require('fs');
const p = JSON.parse(fs.readFileSync('package.json', 'utf8'));
p.scripts ||= {};
const scripts = {
  wt: 'bash scripts/wt.sh',
  dev: 'vite dev',
  build: 'vite build',
  preview: 'vite preview',
  check: 'svelte-kit sync && svelte-check --tsconfig ./tsconfig.json',
  'check:watch': 'svelte-kit sync && svelte-check --tsconfig ./tsconfig.json --watch',
  lint: 'prettier --check . && eslint .',
  format: 'prettier --write .',
  test: 'vitest run',
  'test:watch': 'vitest',
  'test:e2e': 'playwright test',
};
for (const [k, v] of Object.entries(scripts)) if (!p.scripts[k]) p.scripts[k] = v;
p.type ||= 'module';
if (!p.packageManager) p.packageManager = `pnpm@${process.env.PM_VERSION}`;
fs.writeFileSync('package.json', JSON.stringify(p, null, 2) + '\n');
NODE
say "patched package.json (scripts + packageManager)"

# --- version pin for CI (.nvmrc) --------------------------------------------
[ -f .nvmrc ] || { printf '%s\n' "$NODE_MAJOR" > .nvmrc; say "wrote .nvmrc ($NODE_MAJOR)"; }

# --- ESLint (flat config: TS + Svelte, prettier last to disable style rules) --
write_if_absent eslint.config.js <<'EOF'
import js from '@eslint/js';
import ts from 'typescript-eslint';
import svelte from 'eslint-plugin-svelte';
import prettier from 'eslint-config-prettier';
import globals from 'globals';

export default ts.config(
  js.configs.recommended,
  ...ts.configs.recommended,
  ...svelte.configs['flat/recommended'],
  prettier,
  ...svelte.configs['flat/prettier'],
  {
    languageOptions: { globals: { ...globals.browser, ...globals.node } },
  },
  {
    // .svelte files need the TS parser wired through the Svelte parser.
    files: ['**/*.svelte'],
    languageOptions: { parserOptions: { parser: ts.parser } },
  },
  { ignores: ['build/', '.svelte-kit/', 'dist/'] },
);
EOF

# --- Prettier (SvelteKit house style + the Svelte plugin) --------------------
write_if_absent .prettierrc <<'EOF'
{
  "useTabs": true,
  "singleQuote": true,
  "trailingComma": "none",
  "printWidth": 100,
  "plugins": ["prettier-plugin-svelte"],
  "overrides": [{ "files": "*.svelte", "options": { "parser": "svelte" } }]
}
EOF
write_if_absent .prettierignore <<'EOF'
pnpm-lock.yaml
.svelte-kit/
build/
coverage/
playwright-report/
EOF

# --- Vitest (unit tests; jsdom for component tests) --------------------------
# Wired in a standalone config so it works even when the scaffold keeps the app
# build config free of test settings. If your vite.config.ts already defines a
# `test` block, delete this file and keep the single config.
write_if_absent vitest.config.ts <<'EOF'
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  plugins: [sveltekit()],
  test: {
    environment: 'jsdom',
    include: ['src/**/*.{test,spec}.{js,ts}', 'tests/unit/**/*.{test,spec}.{js,ts}'],
  },
});
EOF

# --- Playwright (e2e against the production preview server) ------------------
write_if_absent playwright.config.ts <<'EOF'
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: 'tests/e2e',
  use: { baseURL: 'http://localhost:4173' },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
  webServer: {
    command: 'pnpm build && pnpm preview',
    port: 4173,
    reuseExistingServer: !process.env.CI,
  },
});
EOF

# --- pre-commit: husky + lint-staged ----------------------------------------
write_if_absent .lintstagedrc.json <<'EOF'
{
  "*.{js,ts,svelte,css,md,json,html}": ["prettier --write"],
  "*.{js,ts,svelte}": ["eslint --fix"]
}
EOF
write_if_absent .husky/pre-commit <<'EOF'
pnpm exec lint-staged
EOF
chmod +x .husky/pre-commit 2>/dev/null || true

# --- install the dev toolchain ----------------------------------------------
DEV_DEPS="eslint @eslint/js typescript-eslint eslint-plugin-svelte \
eslint-config-prettier globals prettier prettier-plugin-svelte svelte-check \
typescript vitest jsdom @testing-library/svelte @testing-library/jest-dom \
@playwright/test husky lint-staged"

if [ "$DO_INSTALL" -eq 1 ] && command -v pnpm >/dev/null 2>&1; then
  echo "Installing dev dependencies (pnpm add -D)..."
  # shellcheck disable=SC2086
  if pnpm add -D $DEV_DEPS && pnpm exec playwright install chromium; then
    :
  else
    say "install failed - run it manually (see below)"; DO_INSTALL=0
  fi
else
  DO_INSTALL=0
fi

echo
echo "Toolchain wired."
[ "$DO_INSTALL" -eq 0 ] && {
  echo "Still to do yourself (setup.sh cannot scaffold the SvelteKit app):"
  echo "  1. Scaffold into this directory:  npx sv create ."
  echo "  2. Install the dev toolchain:"
  echo "       pnpm add -D $DEV_DEPS"
  echo "       pnpm exec playwright install chromium"
}
echo "Then: pnpm install && git init && git switch -c develop"
echo "Verify the gate: pnpm lint && pnpm check && pnpm test && pnpm build"
