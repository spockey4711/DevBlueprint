## Stack notes (Nuxt)

- `pnpm wt` is wired as a package script; use it for worktrees.
- Nuxt renders on the server by default; keep components isomorphic. Reach for `.client.vue`
  / `<ClientOnly>` only at interactive leaves that need browser APIs. Never fetch live data
  straight from a component - use `useFetch`/`useAsyncData` or a `server/api/*` route so it
  runs once on the server and hydrates.
- Tailwind + design tokens only, no raw hex in templates. No business logic in templates;
  extract to `composables/` or `utils/` and test it.
- Config is runtime, not build-time: expose values through `runtimeConfig` in `nuxt.config.ts`.
  `runtimeConfig.public.*` reaches the browser (override with `NUXT_PUBLIC_*`), so never a
  secret; top-level `runtimeConfig.*` is server-only (override with `NUXT_*`). Unlike a bundler
  inlining, these are read at server start, so the same build runs in every environment.
- Ops artifacts ship as fillable skeletons: a multi-stage `Dockerfile` (Nitro `nuxt build` output
  in `.output` built on `node:22-slim` -> a slim non-root runtime running
  `node .output/server/index.mjs`) + `.dockerignore` + `docker-compose.yml` for self-hosting, and
  `deploy/` for a hosted target (`vercel.json`, `render.yaml`, `fly.toml`, `terraform/`). Vercel is
  the primary managed target and needs no Dockerfile (Nitro auto-detects the Vercel preset); the
  Dockerfile is for self-hosting the node-server output. Keep the one target you deploy to and
  delete the rest.
- The environment is a validated contract: `.env.schema` declares each variable (required/optional,
  optional `pattern=`), separating public `NUXT_PUBLIC_*` values from server-only secrets, and the
  quality gate (plus CI) runs `scripts/check-env.sh` to keep `.env.example` in lockstep with it and
  enforce required keys in any real `.env`. Declare new variables in both the schema and
  `.env.example`, or the gate fails.
