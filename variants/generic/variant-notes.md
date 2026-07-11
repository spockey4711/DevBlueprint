## Stack notes (generic)

- Worktrees: `./scripts/wt.sh new <type>/<slug>`.
- The quality gate is `make check` - wire the `lint` / `typecheck` / `test` / `build` targets in
  the `Makefile` to your stack's real commands, and drop any that do not apply.
- Set the worktree post-create hook in `scripts/wt.conf` if the project needs a setup step.
- Dependency automation ships in `.github/dependabot.yml` (github-actions enabled; uncomment your
  language's ecosystem) and the toolchain is pinned in `.tool-versions` (asdf/mise) - fill in the
  tools your stack uses and keep the versions in sync with the CI workflow.
- Ops artifacts ship as skeletons to fill in: `Dockerfile` + `.dockerignore` + `docker-compose.yml`
  for containers, and `deploy/` for a hosted target (`fly.toml`, `render.yaml`, `terraform/`). Keep
  the one target you deploy to and delete the rest.
- The environment is a validated contract: `.env.schema` declares each variable (required/optional,
  optional `pattern=`), and `make check` runs `scripts/check-env.sh` to keep `.env.example` in
  lockstep with it and enforce required keys in any real `.env`. Declare new variables in both the
  schema and `.env.example`, or the gate fails.
