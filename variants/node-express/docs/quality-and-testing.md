# Quality and testing

**Purpose:** the quality bar and how it is enforced for this Node/Express/TypeScript service.
Concrete overlay of the blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing (`make check`); CI runs the identical set on every PR:

```bash
npm run lint        # ESLint (typescript-eslint, type-checked) - zero warnings
npm run typecheck   # tsc --noEmit - strict, zero errors
npm test            # vitest - unit + integration
npm run build       # tsc -p tsconfig.build.json - the release build must compile
```

Install the pre-commit hook (husky + lint-staged, wired by `setup.sh`) and lint/format run on
staged files at commit time, so the gate rarely fails in CI.

## Testing strategy

Test what has logic or can silently break; do not chase coverage on trivial glue.

- **Unit (vitest):** services, `lib/` helpers, validation and mapping logic - the code that holds
  business rules. Pure functions where possible; inject dependencies so they are trivial to test.
- **Integration (vitest + supertest):** exercise routes through the Express app (`createApp()`)
  without binding a port - assert status codes, JSON shape and the error contract. Cover the happy
  path plus at least one rejected-input and one not-found case per route.
- **Boundaries:** assert that invalid input is rejected with the right 4xx and a copy-layer
  message, and that internal errors never leak stack traces to the client.
- Keep tests deterministic: no real network or clock; stub external services and time.

Target meaningful coverage of services, `lib/` and the route contracts - not a global percentage.

## Tooling

- **TypeScript** - `strict` (+ `noUncheckedIndexedAccess`). `tsc --noEmit` typechecks src + tests;
  `tsc -p tsconfig.build.json` emits the `dist/` build.
- **ESLint** - flat config with typescript-eslint type-checked rules; `eslint-config-prettier`
  disables stylistic rules so Prettier owns formatting.
- **Prettier** - the single formatter; `format:check` gates it.
- **Vitest** - unit + integration specs in `tests/`; **supertest** drives the Express app in-process.
- **husky + lint-staged** - pre-commit hook runs Prettier + ESLint on staged files.
- **CI** - `.github/workflows/ci.yml` runs the full gate on every PR into `develop`/`master`;
  `.github/dependabot.yml` keeps npm + Actions deps current.

## Definition of done

1. It works, endpoints behave to contract, and inputs are validated at the edge.
2. ESLint, tsc, vitest and the build are green; no secrets or stack traces leak.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR.
