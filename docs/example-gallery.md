# Example gallery

The [first-project tutorial](../GETTING-STARTED.md#your-first-run) walks you through one
project, end to end. This page is the next step: a handful of small, real projects you can
build with the same loop. Each one names a stack [variant](glossary.md#variant), gives you the
exact command to scaffold it, and suggests a first task to copy from - so you can pick whichever
sounds fun and start with a working project instead of a blank folder.

> **Do the tutorial first.** Every project below assumes you have already done a full
> [scaffold -> commit -> pull request loop](../GETTING-STARTED.md#your-first-task) once. These
> are variations on that loop, not new instructions - so when a step here is terse, the
> [tutorial](../GETTING-STARTED.md) has the long version.

Run `devblueprint list` any time to see every variant, and open a variant's linked page below to
see exactly what its scaffold adds.

## How to read an entry

Each project gives you four things:

- **What you build** - the finished idea, in one line.
- **Variant** - which stack to scaffold, and why it fits.
- **Scaffold it** - the one command that creates the project. Copy it as-is; change only the
  name if you like.
- **A good first task** - a concrete, small first change to make in its own
  [worktree](glossary.md#worktree), so your first pull request has real content.

Pick the one closest to what you want to make. The four are ordered by how much toolchain they
install, lightest first.

## 1. A command-line greeting - `generic`

**What you build.** A tiny shell script that prints a friendly hello, plus a test that proves it
works. No language runtime to install - the perfect first project after the tutorial.

**Variant.** [`generic`](../variants/generic/README.md) - the language-agnostic overlay. The
quality gate is `make check` with stub targets you fill in, so nothing extra to set up.

**Scaffold it.**

```bash
devblueprint init --target ~/Projects/hello-cli --name hello-cli --variant generic
```

Then follow [Your first run](../GETTING-STARTED.md#your-first-run) to wire the toolchain, put it
under git, and push.

**A good first task.** Add the script and a check for it.

```bash
./scripts/wt.sh new feat/greet-script
```

In the worktree, create `src/greet.sh` that echoes `Hello from hello-cli`, make it executable,
and point the `test` target in the `Makefile` at it (run the script, confirm it prints the line).
Now `make check` tests something real. Commit, push, open the pull request - same six steps as
the tutorial.

## 2. A personal homepage - `web-nextjs`

**What you build.** A single web page about you or a project - a headline, a short bio, a couple
of links - that you can deploy to the internet for free.

**Variant.** [`web-nextjs`](../variants/web-nextjs/README.md) - Next.js, TypeScript and Tailwind,
the stack this blueprint was extracted from. `setup.sh` installs the toolchain with `pnpm`, and
Vercel deploys it with no server to run.

**Scaffold it.**

```bash
devblueprint init --target ~/Projects/my-homepage --name my-homepage --variant web-nextjs
```

**A good first task.** Replace the placeholder home page with your own.

```bash
./scripts/wt.sh new feat/home-page
```

Edit the main page component so it shows your name and a one-line intro, run `make check` (the
real linter, type checker and build now run), then commit and open the pull request. Once it
merges, connect the repository to [Vercel](https://vercel.com) and your page is live.

## 3. A tiny JSON API - `node-express`

**What you build.** A small web service with one endpoint - for example `GET /health` returning
`{ "status": "ok" }`, or a `/quote` route that returns a random line. The first half of every
backend you will ever write.

**Variant.** [`node-express`](../variants/node-express/README.md) - Node, Express and TypeScript
with tests wired in. `setup.sh` installs dependencies; the gate runs the linter, types and tests.

**Scaffold it.**

```bash
devblueprint init --target ~/Projects/mini-api --name mini-api --variant node-express
```

**A good first task.** Add one route and a test for it.

```bash
./scripts/wt.sh new feat/health-route
```

Add a `GET /health` handler that returns a small JSON object, write a test that calls it and
asserts the status code and body, and run `make check`. A passing test on a route you wrote is
the whole job of a backend engineer in miniature. Commit, push, pull request.

## 4. A first data exploration - `data-python`

**What you build.** A short script or notebook that loads a small CSV file, prints a few summary
numbers (row count, an average, the biggest value), and saves a chart. The starting shape of any
data project.

**Variant.** [`data-python`](../variants/data-python/README.md) - Python managed with `uv`, set
up for data work. `setup.sh` creates the environment and installs the tools; the gate runs the
linter and tests.

**Scaffold it.**

```bash
devblueprint init --target ~/Projects/first-data --name first-data --variant data-python
```

**A good first task.** Load a file and print a summary.

```bash
./scripts/wt.sh new feat/summary-script
```

Drop a small CSV into the project, write a script that reads it and prints a couple of summary
numbers, and add a test that checks one of them against a known value. Run `make check`, then
commit and open the pull request.

## What to do after your first one

The projects above are starting points, not finished apps - the point is to get a real repository
on the same rails as production code, then keep adding one small pull request at a time. When you
are ready for more:

- Try a second project from a different variant, to see how the same workflow adapts to a new
  stack. `devblueprint list` shows all of them.
- Read [Where to go next](../GETTING-STARTED.md#where-to-go-next) in the tutorial for the deeper
  process docs.
- Skim the [FAQ](faq.md) and [cheat sheet](cheatsheet.md) - they answer the "wait, why did that
  happen?" moments that come up in the first few projects.
