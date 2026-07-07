# Quality and testing

**Purpose:** the quality bar and how it is enforced for this Next.js project. This is the
concrete overlay of the blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing; CI runs the identical set on every PR:

```bash
pnpm lint         # ESLint (incl. jsx-a11y) - zero warnings
pnpm typecheck    # tsc --noEmit - zero errors
pnpm test         # Vitest unit tests
pnpm build        # production build must succeed
```

CI additionally runs the Playwright smoke suite. Add a Lighthouse budget job if the project has
a performance bar worth enforcing.

## Testing strategy

Test what has logic or can silently break; do not chase coverage on presentational markup.

- **Unit (Vitest + Testing Library):** `lib/` logic (calculations, SEO/metadata builders,
  data adapters and their fallback behavior), and key component behavior (guards,
  reduced-motion branches, parsing).
- **E2E smoke (Playwright), a few only:** home page renders, primary nav works, a critical
  flow succeeds, a live widget renders its fallback when its API route is unavailable.
- **No snapshot tests of large DOM** - they rot and prove little.

Target: meaningful coverage of `lib/` and critical components, not a global percentage.

## Tooling

- **ESLint** - `eslint.config.mjs`: Next presets (`core-web-vitals` + `typescript`, which
  include `jsx-a11y`), an explicit `import/order` rule, and `eslint-config-prettier` last.
  Run: `pnpm lint`.
- **Prettier** - `prettier.config.mjs` with `prettier-plugin-tailwindcss`. Run: `pnpm format`.
- **Vitest + Testing Library** - `vitest.config.ts` (jsdom, `@/*` alias). Specs in
  `tests/unit`. Run: `pnpm test`.
- **Playwright** - `playwright.config.ts` boots the app via its `webServer` block. Specs in
  `tests/e2e`. Run: `pnpm test:e2e`.
- **lint-staged + husky** - a `pre-commit` hook formats and lints only staged files. Husky
  no-ops outside a git repo, so container and CI installs are unaffected.
- **CI** - `.github/workflows/ci.yml` runs the four gates plus the Playwright smoke suite on
  every PR into `develop`/`master`; `.github/dependabot.yml` keeps npm + Actions deps current.

## Definition of done

1. It works and matches the design/motion/a11y specs.
2. lint, typecheck, test, build are green.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR and is deployable (or deployed).
