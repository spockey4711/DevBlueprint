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
- Ops artifacts ship as fillable skeletons: a multi-stage `Dockerfile` (`node:22-slim` build ->
  slim non-root runtime running the compiled `dist/server.js`) + `.dockerignore` +
  `docker-compose.yml` for containers, and `deploy/` for a hosted target (`fly.toml`, `render.yaml`,
  `terraform/`). Keep the one target you deploy to and delete the rest.
- The environment is a validated contract: `.env.schema` declares each variable (required/optional,
  optional `pattern=`), and `make check` (plus CI) runs `scripts/check-env.sh` to keep `.env.example`
  in lockstep with it and enforce required keys in any real `.env`. Declare new variables in both the
  schema and `.env.example`, or the gate fails.
