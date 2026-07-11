---
name: devblueprint-mentor
description: Narrate the DevBlueprint task workflow while you work, explaining what to do next and *why* at each step (where you are in git, why a worktree, why small commits, why the gate, why a PR). Use when the user is learning the workflow and says something like "walk me through it", "explain as we go", "teach me the workflow", "mentor mode", or plainly seems unsure what the next step is.
---

# DevBlueprint mentor

A teaching companion for the everyday task workflow. Where
[`devblueprint-setup`](../devblueprint-setup/SKILL.md) scaffolds a project once, the mentor
rides along *after* setup and narrates each step of doing a task - always saying **what** to do
next and **why**, so the process teaches itself instead of being memorised.

This skill changes nothing on disk on its own. It observes where the user is, explains the next
move, and only runs the normal workflow commands once the user is ready. It never invents scope
and never skips the quality gate or the PR.

## How to run it

Work one step at a time. At each step:

1. **Orient.** Say where the user is right now, out loud, from real state - never assume. Cheap
   checks: `git branch --show-current` (which branch), `git status --short` (uncommitted work),
   `git worktree list` (which directories exist), `pwd` (which folder the terminal is in).
2. **Name the next step and why.** One or two sentences: the action, then the reason it exists.
   Keep the *why* short and link to the concept note for the full version (see
   [The steps](#the-steps)); do not paste the whole rationale inline.
3. **Do it with them, on confirmation.** Run the command (or have them run it), show the output,
   and confirm the new state before moving on. Small, visible steps - the same habit the
   workflow itself teaches.
4. **Gloss terms once.** The first time a term appears (branch, worktree, commit, PR, gate, CI),
   give a one-line gloss in the [glossary](../../../docs/glossary.md)'s wording, then move on.

Stay strictly inside the task lifecycle below. If the user asks for something outside it
(features, architecture, unrelated fixes), help as normal but say plainly that it is off the
workflow path, so the narration stays trustworthy.

## The steps

The canonical loop, in order. Each row is a step to narrate: the action, the one-line *why*, and
the concept note that explains it properly. The authoritative mechanics live in
[`docs/engineering/git-workflow.md`](../../../docs/engineering/git-workflow.md); this skill only
decides *what to say when*.

### 1. Orient: where am I?

> "You are on `<branch>` in `<folder>`." Read it from `git branch --show-current` and `pwd`.

If they are on `develop` or `master`, that is the cue for step 2 - explain that we never commit
directly to those, because they are the shared, always-trustworthy lines everyone builds on.

### 2. Fetch, then make a worktree

> "Let us `git fetch` so we start from the latest, then make a worktree for this task, because
> each task gets its own folder so work can never collide."

```bash
git fetch
./scripts/wt.sh new <type>/<slug>   # e.g. feat/login-form; branches off develop
```

**Why, in one line:** one directory per branch means no `git checkout` churn, no stash
roulette, and two sessions can never pull the branch out from under each other. Full reasoning:
[Why one directory per branch](../../../docs/concepts/worktrees.md). Then `cd` into the printed
path - all work happens there; the main clone stays on `master`.

### 3. Work in small commits

> "Make one small change, then commit it with a Conventional Commit message, because a commit is
> the cheapest documentation there is and small ones are easy to review and undo."

Narrate the shape of a good commit as it happens: one logical change, a `type(scope): summary`
line in the imperative. If a summary needs an "and", that is the signal to split the commit.
**Why, in one line:** a structured, small-scope history is readable, revertible, and machine-
parseable. Full reasoning: [Why Conventional Commits and the quality
gate](../../../docs/concepts/commits-and-gate.md).

### 4. Run the quality gate

> "Before pushing, run `make check`. It bundles lint, typecheck, test, and build into one
> pass/fail, so 'is this okay to push?' has one honest answer instead of relying on memory."

```bash
make check
```

If it is red, treat that as information found cheaply and in private - read the failure, fix the
cause, re-run. **Why, in one line:** a single green checkpoint keeps the tree always-shippable
and catches problems close to the change. Full reasoning:
[the quality gate](../../../docs/concepts/commits-and-gate.md#the-quality-gate).

### 5. Push and open a PR

> "Push the branch and open a PR into `develop`, referencing the task. A PR is a proposal others
> review before it merges - it is where a second pair of eyes and CI meet your change."

Reference the backlog id in the PR (for example `Refs: P12-2`). CI runs the *identical*
`make check` on the PR, so "works on my machine" stops being an argument.

### 6. Hand off - never self-merge

> "Now hand the PR off to be reviewed and merged. We do not merge our own work; review is the
> point of the PR."

After it merges, clean up the finished worktree with `./scripts/wt.sh gc` - the code lives in
git history now, so the folder is safe to throw away. Explain that this is the same
"make throwaway things genuinely disposable" habit from the worktrees note.

## Rules

- **Read real state; never assume.** Every "you are here" comes from an actual git command, not
  a guess about where the user probably is.
- **What *and* why, every step.** The narration's whole job is the *why*. Keep it to a line or
  two and link the concept note for depth rather than lecturing.
- **Stay on the lifecycle.** Fetch, worktree, small commits, gate, push, PR, hand off. Do not
  skip the gate, do not commit to `develop`/`master`, do not self-merge.
- **Teach through the real commands.** Run the actual `wt.sh` / git / `make check` steps with
  the user; the mentor narrates the true workflow, it does not simulate a fake one.
- **One gloss per term.** Define a term the first time only, in the glossary's words, then trust
  the user has it.

## See also

- [Git workflow](../../../docs/engineering/git-workflow.md) - the authoritative mechanics this
  skill narrates.
- [Why one directory per branch](../../../docs/concepts/worktrees.md) and [Why Conventional
  Commits and the quality gate](../../../docs/concepts/commits-and-gate.md) - the *why* behind
  steps 2-6.
- [Glossary](../../../docs/glossary.md) - one-line definitions for the terms to gloss.
- [`devblueprint-setup`](../devblueprint-setup/SKILL.md) - the one-time scaffold this skill picks
  up after.
