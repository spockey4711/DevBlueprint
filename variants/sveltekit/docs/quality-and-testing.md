# Quality and testing

**Purpose:** the quality bar and how it is enforced for this SvelteKit app. Concrete overlay of
the blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing (`make check`); CI runs the identical set on every PR:

```bash
pnpm lint     # prettier --check + eslint (formatting, style, lint rules)
pnpm check    # svelte-kit sync && svelte-check (types across .svelte + .ts)
pnpm test     # unit + component tests (Vitest)
pnpm build    # vite build - the production build must succeed
```

Everything runs through the pnpm-installed toolchain, pinned by `pnpm-lock.yaml`, so local, CI and
teammates use the same tool versions. Install the pre-commit hook (`setup.sh` wires husky +
lint-staged) and Prettier + ESLint run on staged files at every commit. Playwright e2e
(`pnpm test:e2e`) runs as a separate CI job against the production preview server.

## Testing strategy

Test behavior, not the framework. Favor fast tests; only boot what a test genuinely needs.

- **Unit (Vitest):** `$lib` logic - load helpers, form/schema validation, stores, pure functions -
  constructed directly and asserted on, no browser or component mount.
- **Component (Vitest + jsdom + Testing Library):** render a component with props, assert on the
  rendered output and user interactions. Keep components prop-driven so they mount in isolation.
- **Server load / actions / endpoints:** call the exported `load` / `actions` / request handlers
  directly with a faked event and assert on the returned data, redirects and `fail()`/`error()`
  responses - including validation and authorization failures, not just the happy path.
- **e2e (Playwright):** a handful of critical user journeys against the production `preview`
  server. Reserve these for flows that truly need a real browser; they are slower than Vitest.
- **External services:** fake them (mock the `fetch` passed into `load`, stub the module) instead
  of hitting the network.

Target meaningful coverage of `$lib` logic, server load/actions and the component contract - not a
global percentage, and not framework glue or generated `.svelte-kit/` code.

## Tooling

- **Node + pnpm (versions pinned in `.tool-versions`, `.nvmrc` and `packageManager`)** - the
  runtime and package manager; `pnpm-lock.yaml` is committed so installs are reproducible.
- **Prettier + prettier-plugin-svelte** - the single formatter; `pnpm format` fixes,
  `prettier --check` (inside `pnpm lint`) gates. No hand-formatting.
- **ESLint (typescript-eslint + eslint-plugin-svelte)** - linting for `.ts` and `.svelte`; a
  reported error fails the gate.
- **svelte-check** - type-checking across `.svelte` + `.ts` (`pnpm check`), using the generated
  `$types`; treat a reported error as a build failure.
- **Vitest (+ jsdom, Testing Library)** - unit and component tests.
- **Playwright** - e2e/browser tests against the preview server.
- **pre-commit hook** - husky + lint-staged run Prettier + ESLint on staged files.
- **CI** - `.github/workflows/ci.yml` runs the full gate + Playwright on every PR into
  `develop`/`master`.

## Definition of done

1. It works, the route/behavior does what the task asked, and errors are handled deliberately
   (`error()`/`fail()`, not swallowed).
2. Prettier, ESLint, svelte-check and the tests are green, and `pnpm build` succeeds; new logic is
   covered at the right layer.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR.
