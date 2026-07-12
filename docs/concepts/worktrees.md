# Why one directory per branch

**Purpose:** the *why* behind a rule you will meet on day one - "never `git checkout` a
feature branch in the main clone; give every branch its own directory." This is a concept
note, not a reference. For the exact commands see
[the git workflow](../engineering/git-workflow.md#worktrees); for one-line definitions of the
terms used here (branch, repo, worktree, PR, CI) see the [glossary](../glossary.md).

Aimed at someone learning to be a good engineer: the point is not to memorise the rule but to
understand the problem it solves, because the same instinct shows up all over good engineering.

## The problem it solves

A [branch](../glossary.md#branch) is a parallel line of work. The obvious way to use branches is to
stay in one folder and switch between them: `git checkout feature-a`, work, `git checkout
feature-b`, work. It feels natural, and for a while it is fine. Then it bites you:

- **Switching is not free.** Checking out another branch rewrites the files in your one folder.
  Your editor reloads, your dev server restarts, your installed dependencies may no longer match
  what is on disk. A five-second `git checkout` costs you a minute of re-warming everything.
- **You cannot switch with unfinished work in the way.** Half-done changes block the checkout,
  so you `git stash`, switch, come back, `stash pop`, and hope you remember which stash was
  which. Stashes are where good work goes to be forgotten.
- **You can only be in one place at once.** Reviewing a colleague's [PR](../glossary.md#pr) while
  your own change builds means abandoning your change, checking out theirs, then clawing your way
  back. Two AI-assistant sessions working in the same folder is worse: each one silently pulls
  the branch out from under the other.

Every one of these is the same root cause: **one working directory is being time-shared between
many branches**, and the switching cost - in machine time and in your attention - is paid over
and over.

## The fix: give each branch its own room

A [worktree](../glossary.md#worktree) is git's built-in answer. One [repository](../glossary.md#repo), its full history stored
once, but *many* working directories - each checked out to its own branch. Instead of one desk
you keep clearing and resetting, every task gets its own desk with its own papers laid out.

In this blueprint that becomes a single, exception-free invariant:

> The main clone stays on `master`. Every feature branch lives in its own directory, branched
> off `develop`.

You never switch branches in the main clone at all. To start a task you create a new worktree;
when the task's PR merges, you delete that worktree. The branch and the directory are born and
die together.

## What this buys you

- **Cheap context switching.** Moving between tasks is `cd`, not `checkout`. Each directory
  keeps its own dependencies, its own running dev server, its own editor state. Nothing reloads
  because nothing changed underneath it.
- **Real parallelism.** Two tasks - two people, or two AI sessions, or you reviewing a PR while
  your own work compiles - run side by side in separate folders and cannot collide. This repo
  leans on exactly that: a whole wave of tasks worked at once, one worktree each.
- **A clean baseline that never moves.** Because the main clone is *always* on `master`, it is
  always a trustworthy reference. "What does the released version do?" has an answer that is one
  folder away and never mid-edit.
- **No stash roulette.** Unfinished work stays put in its own directory. You are never forced to
  hide changes just to look at something else, so nothing gets stashed and lost.

## The engineering habit underneath

The specific rule is about git, but the instinct generalises, and that is the part worth
keeping:

**Isolate units of work so they cannot interfere with each other.** A worktree does for your
branches what a function's local scope does for its variables, what a container does for a
service's dependencies, what a test's fixture does for its assumptions. In each case you draw a
boundary so that one thing changing cannot silently corrupt another. Bugs and confusion breed
in shared, mutable, time-shared state; the cure is almost always to stop sharing.

A second habit hides here too: **make the throwaway thing genuinely disposable.** A worktree
folder holds nothing precious - once its commits are pushed and merged, the code lives in git
history forever, and the folder is safe to delete. Good engineering keeps a bright line between
what is the source of truth (history, `master`, the merged PR) and what is a scratch workspace
you can recreate on demand. When that line is clear, "can I throw this away?" stops being a
scary question.

## When it feels like overkill

For a tiny solo change the ceremony can feel heavy, and that reaction is worth taking
seriously - process should earn its keep. But the cost of a worktree is close to zero (one
command to make, one to remove), and the moment a second task appears - a review, a quick fix,
a parallel session - the isolation pays for itself immediately. The blueprint keeps the rule
exception-free on purpose: a workflow you follow *every* time needs no judgement calls and
leaves no room for the one shortcut that pulls a branch out from under a running session.

## See also

- [Git workflow -> Worktrees](../engineering/git-workflow.md#worktrees) - the concrete
  `wt new` / `wt ls` / `wt gc` commands and where worktree folders live.
- [Glossary](../glossary.md) - one-sentence definitions of branch, repo, worktree, PR, CI.
- [Engineering standards](../engineering/engineering-standards.md) - the wider mindset this
  habit is one instance of.
