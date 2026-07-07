# Guide

## Two-minute start

```bash
# 1. Pick a variant
bin/devblueprint list

# 2. Scaffold the engineering setup into a target directory
bin/devblueprint init --target ~/Projects/myapp --name myapp --variant web-nextjs

# 3. Wire the toolchain in one command (configs, pre-commit hook, deps)
cd ~/Projects/myapp
./setup.sh

# 4. Turn the target into a repo with the two long-lived branches
git init
git add -A && git commit -m "chore: scaffold engineering setup from DevBlueprint"
git branch -M master
git switch -c develop

# 5. Start the first task in its own worktree
wt new feat/first-task
```

## What `init` produces

Into the target directory:

```
CLAUDE.md                          workflow + standards for AI assistants (and you)
CONTRIBUTING.md                    the short contributor guide
CHANGELOG.md                       fresh, Keep-a-Changelog format
.devblueprint                      scaffold stamp: kit version + variant (for `update`)
.gitignore                         stack-appropriate
.editorconfig                      stack-agnostic editor baseline (charset, LF, indent)
.gitattributes                     stack-agnostic line-ending normalization
.github/workflows/ci.yml           the quality gate in CI
Makefile                           (generic variant only) gate targets to fill in
setup.sh                           one-shot toolchain wiring (configs, hooks, deps)
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

The `setup.sh` is the automated version of each variant's "After init" checklist: it patches
the package manifest, writes the tool configs, installs a pre-commit hook and pulls the dev
toolchain. It is idempotent and never clobbers existing files, so it is safe to re-run. A few
things it deliberately leaves to you (they cannot be guessed): scaffolding the app framework
itself (`create-next-app`, the Xcode project), and filling the generic `Makefile` targets.

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
  their next `init`; existing projects pull it in with
  `devblueprint update --target <dir>` (add `--variant <name>` to also refresh the
  variant-overlaid `conventions.md` / `quality-and-testing.md`, `--dry-run` to preview).
  `update` only rewrites the core-owned files, so it never disturbs a project's `CLAUDE.md`,
  `wt.conf`, CI or code.
