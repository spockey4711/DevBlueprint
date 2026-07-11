# Concept notes - why we work this way

This directory holds the project's *concept notes*: short essays on the **why** behind the
rules you meet on day one. They are not reference docs. A reference doc tells you *how* - the
exact command, the precise rule; a concept note explains the problem that rule solves, so the
habit makes sense instead of being something to memorise. When the two overlap, each note links
out to its reference for the mechanics.

The audience is someone learning to be a good engineer. The specific rules are about this repo,
but every note ends on the instinct underneath - the part that generalises to work far beyond
this codebase.

## Reading order

Start here, in this order:

1. [Why one directory per branch](worktrees.md) - the very first rule you will follow: never
   `git checkout` a feature branch in the main clone; give every branch its own directory. The
   note is really about *isolating units of work so they cannot interfere*, which is why it comes
   first.
2. [Why Conventional Commits and the quality gate](commits-and-gate.md) - once you are working
   inside a worktree, these are the two habits that shape every commit you make: a structured
   message that records the *why*, and a green `make check` before every push. Both trade a little
   discipline now for far less guessing later.

Read alongside them, whenever a term is unfamiliar:

- [Glossary](../glossary.md) - one-sentence, plain-language definitions of branch, repo,
  worktree, commit, PR, CI, lint, and the rest. The concept notes link into it on first use.

## Where to go next

The concept notes give you the *why*. When you need the exact *how*, follow these:

- [Git workflow](../engineering/git-workflow.md) - the concrete branching, worktree, commit, and
  release commands.
- [Quality and testing](../engineering/quality-and-testing.md) - what the quality gate runs and
  the definition of done.
- [Contributing](../../CONTRIBUTING.md) - the commit and PR rules in short form.
- [Engineering standards](../engineering/engineering-standards.md) - the wider mindset every one
  of these habits is one instance of.
