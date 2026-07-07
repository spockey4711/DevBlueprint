## Stack notes (Node / Express / TypeScript)

- `npm run wt` is wired as a package script; use it for worktrees (post-create runs `npm install`).
- TypeScript `strict`; source lives in `src/`, compiled to `dist/` by `tsc` (never commit `dist/`).
  `tsx` runs the app in dev without a build step.
- Layered: thin `routes/` (HTTP in/out only) delegate to `services/` (business logic) and `lib/`
  (pure helpers). No business logic in route handlers - keep them testable.
- User-facing strings (error messages, response text) come from `src/lib/messages.ts`, never inline
  literals, so copy stays consistent and localizable.
- Validate every request body/query/param at the edge before it reaches a service; never trust
  input. Read config and secrets from the environment (`.env`, gitignored) - never hard-code them.
- ESLint (typescript-eslint, type-checked) is the lint gate; Prettier owns formatting. Vitest +
  supertest cover units and HTTP endpoints.
