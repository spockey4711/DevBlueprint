## Stack notes (generic)

- Worktrees: `./scripts/wt.sh new <type>/<slug>`.
- The quality gate is `make check` - wire the `lint` / `typecheck` / `test` / `build` targets in
  the `Makefile` to your stack's real commands, and drop any that do not apply.
- Set the worktree post-create hook in `scripts/wt.conf` if the project needs a setup step.
