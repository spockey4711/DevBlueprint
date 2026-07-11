
---

## Stack-specific conventions (SvelteKit + TypeScript)

### Language & tooling

- **One pinned Node + pnpm.** Pin them in `.tool-versions`, mirror the Node major in `.nvmrc`
  (read by CI) and the pnpm version in the `packageManager` field; install through pnpm so
  everyone shares one lockfile (`pnpm-lock.yaml` is committed).
- **Prettier** (with `prettier-plugin-svelte`) owns formatting - do not hand-format, run
  `pnpm format` to fix and `pnpm lint` to gate. **ESLint** (typescript-eslint +
  eslint-plugin-svelte) owns linting and **`svelte-check`** owns type-checking across `.svelte`
  and `.ts` (`pnpm check`); a reported error fails the build. Zero warnings in CI.
- **TypeScript strict.** Keep `strict` on in `tsconfig.json`; type props, `load` return values,
  actions and endpoint payloads. Prefer a discriminated result or `error()`/`fail()` over
  returning `null` for an expected miss, and fail fast on invalid input.

### Structure & SvelteKit idioms

- Routing is filesystem-based under `src/routes/`: `+page.svelte`, `+page.ts` (universal load),
  `+page.server.ts` (server load + form actions), `+server.ts` (endpoints), `+layout.*` for
  shared shells. Keep components thin - fetch in `load`, pass data down as props.
- Shared code lives in `src/lib/` (import via `$lib`). Anything that must never reach the browser
  (DB clients, secrets, privileged calls) lives in `src/lib/server/` (`$lib/server`) - the
  bundler enforces the boundary.
- Choose the load layer deliberately: **server** `load`/actions for secrets, DB and privileged
  APIs; **universal** `load` only for code safe to run on the client too. Mutations go through
  form actions (progressively enhanced with `use:enhance`), not ad-hoc client fetches.
- Use Svelte 5 runes for reactivity (`$state`, `$derived`, `$effect`, `$props`); avoid stuffing
  business logic into `$effect`. Push reusable logic into `$lib` modules so it is testable without
  mounting a component.

### Data & security

- **Validate at the boundary** with a schema (Zod/Valibot or equivalent) in every `load`, action
  and endpoint; never trust params, query, body or form input. Enforce authorization in server
  `load`/actions/`hooks.server.ts`, not in the UI.
- Templates escape by default - reserve `{@html}` for values you have deliberately sanitized. Keep
  SvelteKit's built-in CSRF protection on for form actions.
- Read secrets through `$env/static/private` / `$env/dynamic/private`, importable only from server
  code; public values use the `PUBLIC_` prefix via `$env/static/public`. No secrets in code, logs
  or committed config - ship a `.env.example` with safe placeholders.

### Naming

- Route directories and files follow SvelteKit's conventions (`+page.svelte`, `+layout.server.ts`,
  `[slug]`, `(group)`); dynamic segments in `[brackets]`. Components are `PascalCase.svelte`.
- `$lib` modules and helpers are `camelCase.ts` (or `kebab-case.ts` for multi-word files, matching
  the surrounding code); exported functions/variables `camelCase`, types/classes `PascalCase`,
  constants `UPPER_SNAKE_CASE`. Store instances end in `store`/`Store` where it aids reading.
