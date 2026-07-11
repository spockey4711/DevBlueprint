# FAQ

The "why did this happen, and what do I do now?" moments that trip up almost everyone at the
start. Each entry names the symptom, explains why it happens, and tells you the one thing to do
next. If a word here is new, check the [glossary](glossary.md) first.

## "The directory already exists" (or a file was skipped)

**What you see.** Scaffolding into a folder that already has files, you get lines like
`skip README.md (exists; --force to overwrite)`, or `wt.sh` refuses with
`worktree folder already exists: <path>`.

**Why.** This is a safety net, not a bug. The tools never overwrite existing files unless you
explicitly ask, so you cannot lose work by running a command twice. A `skip` line means that one
file was already there and was left untouched; everything else was still written.

**What to do.** Pick one:

- If those files are the ones you want, you are done - the skips are expected.
- If you meant to start fresh in an empty folder, choose a new, empty [path](glossary.md#path) (see
  [Choosing a folder](../GETTING-STARTED.md#choosing-a-folder-for-your-project)) and run again.
- If you really do want to replace what is there, re-run with `--force` - but only once you are
  sure nothing in that folder matters.

## "Not a git repository"

**What you see.** A git command, or `devblueprint doctor`, reports
`not a git repository - run git init`. Plain `git status` says
`fatal: not a git repository (or any of the parent directories)`.

**Why.** Git only tracks folders that have been turned into a **[repo](glossary.md#repo)** (a folder with a hidden
`.git` history inside it). The folder you are standing in was never initialized, or you are one
level above the project and need to step into it.

**What to do.**

- If you are in the wrong folder, `cd` into the project directory and try again - run `pwd` to
  see where you actually are.
- If this folder really is a new project with no history yet, run `git init` once to create the
  repo, then carry on.

## "The quality gate is red" (`make check` failed)

**What you see.** `make check` stops with an error, or `doctor --run-gate` reports
`quality gate failed`. The output scrolls past with a [lint](glossary.md#lint) complaint, a failing test, or a type
error.

**Why.** The [quality gate](glossary.md#quality-gate) bundles the project's lint, typecheck, test and build
steps into one command, and it is *supposed* to fail when any of them find a problem - that is
its whole job. A red gate is the check working, catching something before it reaches [CI](glossary.md#ci).

**What to do.** Do not push yet - fix it locally first.

- Read the output from the *top*, not the bottom: the first failure is usually the real cause,
  and later lines are often knock-on noise.
- Many lint and formatting problems fix themselves - re-run the gate after saving, and check
  whether the tool offers an auto-fix.
- Fix one thing, then run `make check` again. Repeat until it passes. Only then push.

## "I'm on the wrong branch" (or committed to `develop`/`master`)

**What you see.** `git status` shows `On branch develop` (or `master`) when you expected a
feature [branch](glossary.md#branch), or you realize a [commit](glossary.md#commit) landed somewhere it should not have.

**Why.** In this repo you never work directly on the long-lived branches: `master` stays
deployable and `develop` is the shared integration branch. Every task gets its **own** [worktree](glossary.md#worktree)
and branch, created with `scripts/wt.sh new <type>/<slug>`, so parallel work never collides.
Landing on `develop` usually means the worktree step was skipped.

**What to do.**

- If you have **not committed anything yet**, just make the worktree you should have started in:
  `scripts/wt.sh new <type>/<slug>` branches off the latest `develop` and prints a path - do all
  your work there.
- If you **already committed to the wrong branch**, stop before pushing and ask for help moving
  the commit rather than guessing - the fix (a branch plus a reset) is easy but easy to get
  wrong. See [the git workflow](engineering/git-workflow.md) for how the branches fit together.

---

Still stuck, or hit something not listed here? Open an issue or ask in your team's channel -
a missing entry is worth adding.
