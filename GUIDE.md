# Guide

## Two-minute start

```bash
# 1. Pick a variant
bin/devblueprint list

# 2. Scaffold the engineering setup into a target directory
bin/devblueprint init --target ~/Projects/myapp --name myapp --variant web-nextjs

# 3. Turn the target into a repo with the two long-lived branches
cd ~/Projects/myapp
git init
git add -A && git commit -m "chore: scaffold engineering setup from DevBlueprint"
git branch -M master
git switch -c develop

# 4. Wire the toolchain for your stack (see variants/<variant>/README.md, "After init")

# 5. Start the first task in its own worktree
wt new feat/first-task     # after adding a `wt` alias/script for scripts/wt.sh
```

## What `init` produces

Into the target directory:

```
CLAUDE.md                          workflow + standards for AI assistants (and you)
CONTRIBUTING.md                    the short contributor guide
CHANGELOG.md                       fresh, Keep-a-Changelog format
.gitignore                         stack-appropriate
.github/workflows/ci.yml           the quality gate in CI
Makefile                           (generic variant only) gate targets to fill in
scripts/wt.sh                      the worktree manager
scripts/wt.conf                    branches + post-create install hook for the stack
docs/engineering/
  git-workflow.md                  branching, worktrees, commits, PRs, releases
  engineering-standards.md         the mindset
  conventions.md                   shared baseline + the stack overlay
  quality-and-testing.md           the concrete gate + testing strategy
docs/project/backlog.md            a stub task list
src/... tests/...                  the source/test skeleton for the stack
```

Everything is a plain file you own. Edit freely - DevBlueprint is not a dependency.

## The workflow in one page

1. **One worktree per task.** `wt new feat/thing` branches off `develop` into its own
   directory. The main clone stays on `master`, so parallel sessions never collide.
2. **Small commits**, Conventional Commits, each building green.
3. **Quality gate** before pushing (the four commands in your quality-and-testing doc).
4. **PR into `develop`**, reviewed, merged with a merge commit. `wt gc` cleans the worktree.
5. **Release** by promoting `develop` -> `master` via a PR every few days.

Full detail lands in the target project's `docs/engineering/git-workflow.md`.

## Adapting

- **Solo / lightweight:** run `init --base master` for a single-branch trunk workflow (still
  worktrees, still PRs, still the gate). Or keep both branches but skip the dev auto-deploy.
- **Add a stack:** copy an existing folder under `variants/`, adjust `manifest.env`, `wt.conf`,
  `docs/quality-and-testing.md`, `docs/conventions.append.md`, `variant-notes.md`, the CI
  workflow and `.gitignore`. It shows up in `devblueprint list` automatically.
- **Change the shared workflow once, everywhere:** edit `core/`. New projects pick it up at
  their next `init`.
