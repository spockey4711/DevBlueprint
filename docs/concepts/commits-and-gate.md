# Why Conventional Commits and the quality gate

A concept note for someone learning to be a good engineer. It explains *why* this repo asks
for [Conventional Commits](../../CONTRIBUTING.md#commit-messages--conventional-commits) and a
green [quality gate](../engineering/quality-and-testing.md#the-quality-gate-must-be-green-to-merge)
before every push - not the exact rules, but what they buy you and why the habit is worth
building. For the mechanics, follow the links. For any word you do not recognise, check the
[glossary](../glossary.md) first.

Both habits share one idea: **do a little disciplined work now so future-you (and everyone
else) does far less guessing later.** They are cheap to follow and expensive to skip.

## Conventional Commits

### What it is, in one line

Every commit message starts with a *type* and a short summary in the imperative:

```
fix(auth): reject expired tokens before hitting the database

docs: explain why the quality gate exists
```

The type (`feat`, `fix`, `docs`, `refactor`, `chore`, ...) says what *kind* of change this is.
The summary says what it does, phrased as a command ("reject", "explain") - as if you are
telling the codebase what to do. The full grammar is in
[CONTRIBUTING.md](../../CONTRIBUTING.md#commit-messages--conventional-commits).

### Why it exists

A [commit](../glossary.md#commit)
is a snapshot of your work plus a message. The snapshot is for the computer; the message is for
a human - usually you, months later, trying to understand why a line of code is the way it is.
An unstructured message ("stuff", "fixes", "wip") throws that away. A structured one keeps it.

The convention buys you four concrete things:

- **A readable history you can scan.** `git log --oneline` becomes a table of contents for the
  project. You can see at a glance what was a feature, what was a bug fix, and what was
  housekeeping, without opening a single diff.
- **Small, honest scope.** Writing `feat(x): ...` forces you to notice when a commit is really
  *two* changes - a feature *and* an unrelated refactor. If the summary needs an "and", the
  commit probably needs splitting. This is the same discipline behind
  "[one logical change per commit](../../CONTRIBUTING.md)": the message is where the habit
  either holds or breaks.
- **Machines can read it too.** Because the type is in a fixed place, tooling can group changes,
  generate a changelog, or work out the next version number (a `fix` is a patch, a `feat` a
  minor release, a `BREAKING CHANGE` a major one). You get automation for free by writing the
  message you should write anyway.
- **Faster archaeology.** When something breaks, you go looking through history. Good messages
  turn "read forty diffs" into "read forty summaries and open the one that matters". This repo's
  own [git workflow](../engineering/git-workflow.md) leans on that when tracing a change back to
  its task (`Refs: P1-3`).

### The mindset

The message answers a question the diff cannot: **why**. The diff already shows *what* changed -
git computed it for you. Your job is to record the reasoning that will not be obvious later:
the bug you were fixing, the constraint you were working around, the thing you deliberately did
*not* do. A commit is the cheapest documentation you will ever write, and the only kind that
sits right next to the code it explains.

## The quality gate

### What it is, in one line

One command that must pass before you push:

```bash
make check   # bundles this project's lint, typecheck, test, and build
```

It runs the project's [lint](../glossary.md#lint),
type-check, tests, and build in sequence and fails if any step fails. The concrete commands come
from the variant you scaffolded; see
[quality & testing](../engineering/quality-and-testing.md).

### Why it exists

A gate is a single, boring checkpoint that everything passes through before it can move forward.
Without one, "is this okay to push?" is answered by memory and mood - you *usually* run the
tests, you *mostly* remember to lint. Under time pressure, "usually" and "mostly" quietly become
"not this time", and the broken change lands anyway.

Bundling every check behind one command removes the judgement call. There is nothing to
remember and nothing to skip: you either ran `make check` and it was green, or you did not. That
buys you:

- **A tree that is always green.** If every change had to pass the gate, then the tip of the
  branch is known-good. You can build on it, or ship it, without first checking whether someone
  left it broken.
- **Fast feedback, close to the cause.** A test failing on *your* machine, thirty seconds after
  *your* change, is a two-minute fix - you still have all the context. The same failure found a
  week later, by someone else, in [CI](../glossary.md#ci)
  or production, is an afternoon of archaeology. The gate pulls the discovery as early as it can
  go.
- **The same bar for everyone.** CI runs the *identical* `make check` on every
  [PR](../glossary.md#pr).
  "Works on my machine" stops being an argument, because the machine that decides is the same one
  for everybody. Running it locally first just means you find out before the PR does.
- **Freedom to change things.** A trustworthy gate is what makes refactoring safe. You can
  rename, restructure, and delete with confidence, because if you break something the gate tells
  you immediately. Without that safety net, code calcifies - nobody dares touch it.

### The mindset

The gate is not there to slow you down; it is there to let you go *fast without being reckless*.
Treat a red gate as information, not an obstacle - it just told you, cheaply and in private,
about a problem your users would otherwise have found expensively and in public. Zero warnings,
green every time. If a check is noise, fix the check (or remove it) rather than training yourself
to ignore it - a gate you routinely override is no gate at all.

## How the two fit together

They are the two ends of one small, safe step:

1. The **quality gate** proves the change is *correct* - it builds, it lints, the tests pass.
2. The **commit message** records what the change *is and why* - readable now, and searchable
   forever.

Together they keep every step of the work small, reversible, and honest: a green checkpoint
paired with a clear note about what just passed it. Do that consistently and the project stays
something you can move quickly in for years - which is the whole point.

## See also

- [Glossary](../glossary.md) - plain-language definitions of the terms above.
- [Contributing](../../CONTRIBUTING.md) - the commit and PR rules in short form.
- [Git workflow](../engineering/git-workflow.md) - the full branching, commit, and release
  process.
- [Quality and testing](../engineering/quality-and-testing.md) - what the gate runs and the
  definition of done.
- [Engineering standards](../engineering/engineering-standards.md) - the mindset these habits
  come from.
