#!/usr/bin/env bash
# setup.sh - wire the Nuxt/pnpm toolchain after `devblueprint init`.
#
# Idempotent and safe: it only creates files that are missing and adds the
# package.json scripts/fields that are absent, so it can be re-run and will not
# clobber your edits. Run it from the project root:
#
#   ./setup.sh              # wire config + install the dev toolchain
#   ./setup.sh --no-install # wire config only, skip `pnpm add`
#
# It does NOT scaffold the Nuxt app itself - run `pnpm create nuxt@latest .`
# first (or point this at an existing app).
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

echo "Wiring the Nuxt toolchain..."

# --- package.json: create if missing, then add scripts + fields idempotently --
if [ ! -f package.json ]; then
  printf '{\n  "name": "%s",\n  "private": true,\n  "version": "0.1.0"\n}\n' \
    "$(basename "$PWD")" > package.json
  say "wrote package.json (minimal)"
fi

PM_VERSION="$(pnpm --version 2>/dev/null || echo 9)"
NODE_MAJOR="$(node -v 2>/dev/null | sed 's/^v//; s/\..*//')"
[ -n "$NODE_MAJOR" ] || NODE_MAJOR=22

# Patch package.json with node (available in a Node project). Only fills gaps.
# `nuxt prepare` runs on postinstall so .nuxt/ (types, tsconfig) exists before a
# typecheck; `nuxt typecheck` prepares + runs vue-tsc, so it is self-contained.
PM_VERSION="$PM_VERSION" node <<'NODE'
const fs = require('fs');
const p = JSON.parse(fs.readFileSync('package.json', 'utf8'));
p.scripts ||= {};
const scripts = {
  wt: 'bash scripts/wt.sh',
  dev: 'nuxt dev',
  build: 'nuxt build',
  preview: 'nuxt preview',
  generate: 'nuxt generate',
  start: 'node .output/server/index.mjs',
  postinstall: 'nuxt prepare',
  lint: 'eslint .',
  typecheck: 'nuxt typecheck',
  test: 'vitest run',
  'test:watch': 'vitest',
  'test:e2e': 'playwright test',
  format: 'prettier --write .',
  'format:check': 'prettier --check .',
  prepare: 'husky',
};
for (const [k, v] of Object.entries(scripts)) if (!p.scripts[k]) p.scripts[k] = v;
if (!p.packageManager) p.packageManager = `pnpm@${process.env.PM_VERSION}`;
fs.writeFileSync('package.json', JSON.stringify(p, null, 2) + '\n');
NODE
say "patched package.json (scripts + packageManager)"

# --- version pin for CI (.nvmrc) --------------------------------------------
[ -f .nvmrc ] || { printf '%s\n' "$NODE_MAJOR" > .nvmrc; say "wrote .nvmrc ($NODE_MAJOR)"; }

# --- ESLint (flat config, Nuxt preset, formatting left to Prettier) ----------
# @nuxt/eslint-config/flat is a standalone flat config - no Nuxt module needed.
# stylistic:false hands all formatting to Prettier so the two never fight.
write_if_absent eslint.config.mjs <<'EOF'
import { createConfigForNuxt } from '@nuxt/eslint-config/flat';

export default createConfigForNuxt({
  features: { stylistic: false },
}).append({
  rules: {
    'vue/multi-word-component-names': 'off',
  },
});
EOF

# --- Prettier ----------------------------------------------------------------
write_if_absent prettier.config.mjs <<'EOF'
/** @type {import('prettier').Config} */
export default {
  plugins: ['prettier-plugin-tailwindcss'],
};
EOF
write_if_absent .prettierignore <<'EOF'
pnpm-lock.yaml
.nuxt/
.output/
coverage/
playwright-report/
EOF

# --- TypeScript (strict) - extend Nuxt's generated tsconfig ------------------
# Nuxt writes .nuxt/tsconfig.json on `nuxt prepare`; the project tsconfig just
# extends it. `nuxi init` already ships this, so write_if_absent usually skips.
write_if_absent tsconfig.json <<'EOF'
{
  "extends": "./.nuxt/tsconfig.json"
}
EOF

# --- Vitest + @nuxt/test-utils (Nuxt-aware environment) ----------------------
write_if_absent vitest.config.ts <<'EOF'
import { defineVitestConfig } from '@nuxt/test-utils/config';

export default defineVitestConfig({
  test: {
    environment: 'nuxt',
    include: ['tests/unit/**/*.test.ts'],
  },
});
EOF

# --- Playwright --------------------------------------------------------------
write_if_absent playwright.config.ts <<'EOF'
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: 'tests/e2e',
  use: { baseURL: 'http://localhost:3000' },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
  webServer: {
    command: 'pnpm dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
EOF

# --- pre-commit: husky + lint-staged ----------------------------------------
write_if_absent .lintstagedrc.json <<'EOF'
{
  "*.{ts,vue,js,mjs,css,md,json}": ["prettier --write"],
  "*.{ts,vue,js,mjs}": ["eslint --fix"]
}
EOF
write_if_absent .husky/pre-commit <<'EOF'
pnpm exec lint-staged
EOF
chmod +x .husky/pre-commit 2>/dev/null || true

# --- install the dev toolchain ----------------------------------------------
DEV_DEPS="eslint @nuxt/eslint-config prettier prettier-plugin-tailwindcss \
typescript vue-tsc @types/node vitest @nuxt/test-utils @vue/test-utils \
happy-dom @testing-library/vue @playwright/test husky lint-staged"

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
  echo "Still to run yourself:"
  echo "  pnpm add -D $DEV_DEPS"
  echo "  pnpm exec playwright install chromium"
}
echo "Then: pnpm install && git init && git switch -c develop"
echo "Verify the gate: pnpm lint && pnpm typecheck && pnpm test && pnpm build"
