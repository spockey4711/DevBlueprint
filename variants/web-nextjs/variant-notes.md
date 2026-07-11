## Stack notes (Next.js)

- `pnpm wt` is wired as a package script; use it for worktrees.
- Server Components by default; `'use client'` only at interactive leaves. Never fetch live
  data from client components - go through `app/api/*` route handlers.
- Tailwind + design tokens only, no raw hex in components. No business logic in JSX; extract to
  `lib/` and test it.
- No secrets in the client bundle or `NEXT_PUBLIC_*`.
- Ops artifacts ship as fillable skeletons: a multi-stage `Dockerfile` (Next.js `output:
  "standalone"` built on `node:22-slim` -> a slim non-root runtime running `node server.js`) +
  `.dockerignore` + `docker-compose.yml` for self-hosting, and `deploy/` for a hosted target
  (`vercel.json`, `render.yaml`, `fly.toml`, `terraform/`). Vercel is the primary managed target and
  needs no Dockerfile; the Dockerfile is for self-hosting the standalone output. Keep the one target
  you deploy to and delete the rest.
- The environment is a validated contract: `.env.schema` declares each variable (required/optional,
  optional `pattern=`), separating build-time `NEXT_PUBLIC_*` values from server-only secrets, and
  the quality gate (plus CI) runs `scripts/check-env.sh` to keep `.env.example` in lockstep with it
  and enforce required keys in any real `.env`. Declare new variables in both the schema and
  `.env.example`, or the gate fails.
