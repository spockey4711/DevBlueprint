## Stack notes (SvelteKit + TypeScript)

- Worktrees: `./scripts/wt.sh new <type>/<slug>` (post-create runs `pnpm install` to warm the
  dependency cache). Node and pnpm are pinned in `.tool-versions` and the `packageManager` field
  so local, CI and teammates run one toolchain.
- Routing is filesystem-based under `src/routes/`: `+page.svelte` (UI), `+page.ts` (universal
  load), `+page.server.ts` (server-only load + form actions), `+server.ts` (API endpoints),
  `+layout.*` for shared shells. Shared code lives in `src/lib/` (import via `$lib`); anything
  that must never reach the browser goes in `src/lib/server/` (`$lib/server`, enforced by the
  bundler).
- Fetch data in `load` functions, not inside components. Use a server `load` / form action when
  the work needs secrets, a database or privileged APIs; use a universal `load` when the same
  code may run on client and server. Return typed data and let SvelteKit's generated `$types`
  flow it into the page.
- `prettier` (with `prettier-plugin-svelte`) owns formatting - do not hand-format, run
  `pnpm format`. `eslint` (typescript-eslint + eslint-plugin-svelte) owns linting and
  `svelte-check` owns type-checking across `.svelte` and `.ts`; a reported error fails the build.
  Zero warnings in CI.
- Use Svelte 5 runes for reactivity (`$state`, `$derived`, `$effect`, `$props`) and keep
  components small and prop-driven. Push shared logic into `$lib` modules so it is unit-testable
  without mounting a component.
- Never trust input: validate params and form/body data at the boundary of every `load`, action
  and endpoint (a schema validator like Zod/Valibot is the norm). Templates escape by default -
  reserve `{@html}` for values you have deliberately sanitized. SvelteKit's built-in CSRF check
  guards form actions; keep it on.
- Secrets come from `$env/static/private` / `$env/dynamic/private` and are only importable from
  server code - never import them into a component or universal `load`. Public values use the
  `PUBLIC_` prefix (`$env/static/public`). Ship a `.env.example` with safe placeholders; never
  commit real credentials.
- User-facing copy lives in a dedicated i18n/content layer (e.g. Paraglide or a messages module),
  resolved through a helper, not scattered string literals through the components.
- Prefer fast Vitest unit tests for `$lib` logic and components (jsdom + Testing Library); reserve
  Playwright e2e for the few critical user journeys, run against the production `preview` server.
