#!/usr/bin/env bash
# setup.sh - wire the Node/Express/TypeScript toolchain after `devblueprint init`.
#
# Idempotent and safe: it only creates files that are missing and adds the
# package.json scripts/fields that are absent, so it can be re-run and will not
# clobber your edits. Run it from the project root:
#
#   ./setup.sh              # wire config + a minimal Express app + `npm install`
#   ./setup.sh --no-install # wire config only, skip `npm install`
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

PROJECT="$(basename "$PWD")"

echo "Wiring the Node/Express toolchain..."

# --- package.json: create if missing, then add scripts + fields idempotently --
if [ ! -f package.json ]; then
  printf '{\n  "name": "%s",\n  "private": true,\n  "version": "0.1.0"\n}\n' \
    "$PROJECT" > package.json
  say "wrote package.json (minimal)"
fi

NODE_MAJOR="$(node -v 2>/dev/null | sed 's/^v//; s/\..*//')"
[ -n "$NODE_MAJOR" ] || NODE_MAJOR=22

# Patch package.json with node (available in a Node project). Only fills gaps.
NODE_MAJOR="$NODE_MAJOR" node <<'NODE'
const fs = require('fs');
const p = JSON.parse(fs.readFileSync('package.json', 'utf8'));
p.scripts ||= {};
const scripts = {
  wt: 'bash scripts/wt.sh',
  dev: 'tsx watch src/server.ts',
  build: 'tsc -p tsconfig.build.json',
  start: 'node dist/server.js',
  lint: 'eslint .',
  typecheck: 'tsc --noEmit',
  test: 'vitest run --passWithNoTests',
  'test:watch': 'vitest',
  format: 'prettier --write .',
  'format:check': 'prettier --check .',
  prepare: 'husky',
};
for (const [k, v] of Object.entries(scripts)) if (!p.scripts[k]) p.scripts[k] = v;
p.engines ||= {};
p.engines.node ||= `>=${process.env.NODE_MAJOR}`;
fs.writeFileSync('package.json', JSON.stringify(p, null, 2) + '\n');
NODE
say "patched package.json (scripts + engines)"

# --- version pin for CI (.nvmrc) --------------------------------------------
[ -f .nvmrc ] || { printf '%s\n' "$NODE_MAJOR" > .nvmrc; say "wrote .nvmrc ($NODE_MAJOR)"; }

# --- TypeScript (strict; CommonJS so the starter runs with no ESM ceremony) --
write_if_absent tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "lib": ["ES2022"],
    "types": ["node"],
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "noFallthroughCasesInSwitch": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "skipLibCheck": true,
    "noEmit": true
  },
  "include": ["src/**/*", "tests/**/*"]
}
EOF
write_if_absent tsconfig.build.json <<'EOF'
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "noEmit": false,
    "outDir": "dist",
    "rootDir": "src",
    "declaration": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["tests", "**/*.test.ts"]
}
EOF

# --- ESLint (flat config, typescript-eslint type-checked + prettier last) -----
write_if_absent eslint.config.mjs <<'EOF'
import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import prettier from 'eslint-config-prettier';

export default tseslint.config(
  {
    // Build output and the flat config files themselves (the config files are
    // not part of a tsconfig, so the type-checked rules cannot resolve them).
    ignores: ['dist/', 'coverage/', 'node_modules/', '**/*.config.{js,cjs,mjs,ts}'],
  },
  js.configs.recommended,
  ...tseslint.configs.recommendedTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      // Underscore-prefixed params are intentionally unused (e.g. Express's
      // four-arg error-handler signature).
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
    },
  },
  {
    // Tests talk to loosely-typed fixtures (a supertest response body is `any`);
    // keep the type-safety rules where they earn their keep, not on assertions.
    files: ['tests/**/*.ts'],
    rules: {
      '@typescript-eslint/no-unsafe-member-access': 'off',
      '@typescript-eslint/no-unsafe-assignment': 'off',
    },
  },
  prettier,
);
EOF

# --- Prettier ----------------------------------------------------------------
write_if_absent prettier.config.mjs <<'EOF'
/** @type {import('prettier').Config} */
export default {
  singleQuote: true,
  semi: true,
  trailingComma: 'all',
};
EOF
write_if_absent .prettierignore <<'EOF'
dist/
coverage/
package-lock.json
EOF

# --- Vitest ------------------------------------------------------------------
write_if_absent vitest.config.ts <<'EOF'
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    include: ['tests/**/*.test.ts'],
    coverage: {
      provider: 'v8',
      include: ['src/**/*.ts'],
    },
  },
});
EOF

# --- pre-commit: husky + lint-staged ----------------------------------------
write_if_absent .lintstagedrc.json <<'EOF'
{
  "*.{ts,js,json,md}": ["prettier --write"],
  "*.ts": ["eslint --fix"]
}
EOF
write_if_absent .husky/pre-commit <<'EOF'
npx lint-staged
EOF
chmod +x .husky/pre-commit 2>/dev/null || true

# --- minimal Express app (starter; Express has no official scaffolder) --------
# User-facing strings live in one module, not scattered literals - see the copy
# convention in docs/engineering/conventions.md.
write_if_absent src/lib/messages.ts <<'EOF'
// Central copy layer: all user-facing API strings live here, never inline.
export const messages = {
  notFound: 'Resource not found',
  internalError: 'Internal server error',
} as const;
EOF
write_if_absent src/routes/health.ts <<'EOF'
import { Router } from 'express';

export const healthRouter = Router();

healthRouter.get('/health', (_req, res) => {
  res.json({ status: 'ok', uptime: process.uptime() });
});
EOF
write_if_absent src/middleware/error-handler.ts <<'EOF'
import type { NextFunction, Request, Response } from 'express';
import { messages } from '../lib/messages';

export function notFoundHandler(_req: Request, res: Response): void {
  res.status(404).json({ error: messages.notFound });
}

// Express identifies error handlers by their four-argument signature, so `next`
// must stay in the list even though it is unused here.
export function errorHandler(
  err: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void {
  console.error(err);
  res.status(500).json({ error: messages.internalError });
}
EOF
write_if_absent src/app.ts <<'EOF'
import express from 'express';
import { healthRouter } from './routes/health';
import { errorHandler, notFoundHandler } from './middleware/error-handler';

export function createApp() {
  const app = express();
  app.use(express.json());

  app.use(healthRouter);

  app.use(notFoundHandler);
  app.use(errorHandler);
  return app;
}
EOF
write_if_absent src/server.ts <<'EOF'
import { createApp } from './app';

const port = Number(process.env.PORT ?? 3000);

createApp().listen(port, () => {
  console.log(`Listening on http://localhost:${port}`);
});
EOF
write_if_absent tests/integration/health.test.ts <<'EOF'
import request from 'supertest';
import { describe, expect, it } from 'vitest';
import { createApp } from '../../src/app';

describe('GET /health', () => {
  it('returns ok', async () => {
    const res = await request(createApp()).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });

  it('404s an unknown route with the shared message', async () => {
    const res = await request(createApp()).get('/nope');
    expect(res.status).toBe(404);
    expect(res.body.error).toBe('Resource not found');
  });
});
EOF
write_if_absent .env.example <<'EOF'
# Copy to .env for local runs. Never commit real secrets.
PORT=3000
EOF

# --- install the toolchain ---------------------------------------------------
PROD_DEPS="express"
DEV_DEPS="typescript @types/node tsx eslint @eslint/js typescript-eslint \
eslint-config-prettier prettier vitest @vitest/coverage-v8 supertest \
@types/supertest @types/express husky lint-staged"

if [ "$DO_INSTALL" -eq 1 ] && command -v npm >/dev/null 2>&1; then
  echo "Installing dependencies (npm install)..."
  # shellcheck disable=SC2086
  if npm install --no-audit --no-fund $PROD_DEPS \
    && npm install --no-audit --no-fund --save-dev $DEV_DEPS; then
    # `prepare: husky` (run by npm install) wires the hook path to .husky/.
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
  echo "  npm install $PROD_DEPS"
  echo "  npm install --save-dev $DEV_DEPS"
}
echo "Then: git init && git switch -c develop"
echo "Verify the gate: npm run lint && npm run typecheck && npm test && npm run build"
