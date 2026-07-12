# DevBlueprint

Guidance for AI assistants (and humans) working in this repo. Keep it short; the detail lives
in [`docs/`](docs/). Start there before non-trivial work.

## Always

- **Commit after every small fix or task.** One logical change per commit,
  [Conventional Commits](CONTRIBUTING.md), imperative summary. Small commits beat big ones.
- **Two long-lived branches.** Feature work integrates on `develop`; `develop`
  is promoted to the always-deployable `master` via a periodic release PR. Never merge
  a feature branch straight into `master`. See
  [`docs/engineering/git-workflow.md`](docs/engineering/git-workflow.md).
- **One directory per branch (worktrees).** Never commit directly to `develop` or
  `master`. Create each task's branch as its own worktree with
  `./scripts/wt.sh new <type>/<slug>` (e.g. `./scripts/wt.sh new fix/scroll-jitter`), which branches off
  `develop`, and do all work inside the printed worktree path. The main clone stays on
  `master` - never `git checkout` a feature branch in it, so parallel sessions never
  collide. Clean up merged worktrees with `./scripts/wt.sh gc`.
- **Follow the task lifecycle.** A request like "do task X from the backlog" means: fetch,
  create the worktree (off `develop`), work in small commits, run the quality gate,
  push, open a PR into `develop` (referencing the task), then hand the PR off to be
  reviewed and merged. Never self-merge.
- **Fetch before starting work.** `git fetch` at the start of a session and before creating a
  new branch, so you have the latest state from remote.
- **English** in code, comments, docs, commits. Localize user-facing copy in a dedicated layer
  ([`i18n/`](i18n/README.md)), never as scattered string literals.
- **No emojis, no fancy dashes** anywhere. Regular hyphen `-` only.
- **Docs + `CHANGELOG.md` change in the same PR** as the code they describe. Update only the
  docs relevant to your change.

## Before pushing

```bash
make check
```

## Engineering standards

Treat this like production code at a serious software company. The concrete rules live in the
docs below; the mindset behind them is in
[`docs/engineering/engineering-standards.md`](docs/engineering/engineering-standards.md).

- Read before you write; match the surrounding style.
- Small, reversible steps; keep the tree green at every step.
- Make it work, then right, then fast. Prefer boring, obvious solutions.
- Strict types, deliberate error handling, zero warnings in CI.
- Never trust input; never leak secrets. OWASP mindset.
- Every change goes through a PR - self-review the full diff first.

## Stack notes (generic)

- Worktrees: `./scripts/wt.sh new <type>/<slug>`.
- The quality gate is `make check` - wire the `lint` / `typecheck` / `test` / `build` targets in
  the `Makefile` to your stack's real commands, and drop any that do not apply.
- Set the worktree post-create hook in `scripts/wt.conf` if the project needs a setup step.

## Where things are

- Full process: [`CONTRIBUTING.md`](CONTRIBUTING.md) ·
  [`docs/engineering/git-workflow.md`](docs/engineering/git-workflow.md)
- Code style: [`docs/engineering/conventions.md`](docs/engineering/conventions.md)
- Quality bar & tests: [`docs/engineering/quality-and-testing.md`](docs/engineering/quality-and-testing.md)
- What to build next: `docs/project/backlog.md`
