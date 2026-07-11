# Getting started

New to the terminal, git, or programming in general? Start here. This guide takes you from
nothing installed to your first green pull request, explaining each step in plain language and
*why* it looks the way it does. No prior experience assumed.

If you are already fluent with a terminal, git and package managers, you can skip this guide
and go straight to the [README](README.md) - it covers the same ground faster.

> This guide is being written in stages. Sections marked _(coming soon)_ are placeholders that
> will be filled in shortly; the headings show what is planned so you know what to expect.

## Prerequisites

What you need installed before you begin - a terminal, git, Node and a code editor - with
copy-paste install steps for macOS, Windows and Linux and a way to confirm each one worked.

_(coming soon)_

## Choosing a folder for your project

Where on your computer the project should live, how to pick a good path (and avoid a bad one),
what `~` means, and how to open that folder in both the terminal and your editor.

_(coming soon)_

## Your first run

Time to scaffold a real project. We will build one called `hello-world` from nothing to its
first pull request, running every command in order. Copy each block, run it, and check that
what you see matches the output shown. If a step looks different, stop there and compare - it is
easier to fix one step than ten.

Every command uses `devblueprint`, the tool you installed in
[Prerequisites](#prerequisites). If you skipped the install and only have Node, replace
`devblueprint` with `npx devblueprint` everywhere - it downloads and runs the same tool on
demand.

We will use the `generic` variant. A *variant* is the stack-specific layer (Next.js, Python,
Swift, ...); `generic` adds no language toolchain, so nothing extra to install and the quality
gate runs out of the box. Once you are comfortable, `devblueprint list` shows the real-stack
variants - swap `--variant generic` for any of them later.

### 1. Scaffold the project

This is the one command that creates everything. `--target` is where the project folder goes
(see [Choosing a folder](#choosing-a-folder-for-your-project) for why `~/Projects/...`),
`--name` is what it is called, and `--variant` is the stack.

```bash
devblueprint init --target ~/Projects/hello-world --name hello-world --variant generic
```

You should see it list every file as it writes them, then a "Next steps" block:

```
Scaffolding 'hello-world' (Generic (language-agnostic)) into ~/Projects/hello-world
  branches: develop -> master   gate: make check
  agents: claude

  wrote docs/engineering/git-workflow.md
  ...
  wrote docs/project/backlog.md

Done. Next steps:
  1. cd ~/Projects/hello-world
  2. ./setup.sh   (wires configs + pre-commit hook + installs the toolchain)
  3. git init && git branch -M master && git switch -c develop
  4. Start a task in its own worktree:  ./scripts/wt.sh new feat/first-task
```

> **Tip:** want to see what a command will do before it touches your disk? Run `devblueprint
> plan ...` with the same flags first. It prints exactly what `init` would write and changes
> nothing. `init` is also safe to re-run - it never overwrites a file you already have.

The next steps are your checklist. We will walk through each one.

### 2. Move into the folder and wire the toolchain

```bash
cd ~/Projects/hello-world
./setup.sh
```

`setup.sh` sets up the local checks that run automatically before each commit. You should see:

```
Wiring the generic toolchain...
  wrote .githooks/pre-commit
  not a git repo yet - after 'git init' run: git config core.hooksPath .githooks

Toolchain wired.
```

It is reminding you that the pre-commit hook only activates once the folder is a git
repository - which is the very next step.

### 3. Put it under version control

Three things happen here: `git init` turns the folder into a repository, the `config` line
switches on the pre-commit hook `setup.sh` just wrote, and the first commit records everything
the scaffold created.

```bash
git init
git config core.hooksPath .githooks
git add -A
git commit -m "chore: scaffold project with DevBlueprint"
```

Now create the two long-lived branches. `master` is the stable, always-working branch;
`develop` is where day-to-day work is integrated first. You will spend your time on `develop`
and branches off it.

```bash
git branch -M master
git switch -c develop
```

You should now be on `develop` with one commit:

```
Switched to a new branch 'develop'
```

### 4. Verify the foundation is sound

`doctor` checks that every file the scaffold should have produced is present and the hook is
wired. This is your "if it worked" confirmation for the whole run.

```bash
devblueprint doctor --target .
```

Every line should read `ok`, ending with an all-clear:

```
  ok    CLAUDE.md
  ok    CONTRIBUTING.md
  ...
  ok    pre-commit hook wired

doctor: all foundation files present (scaffolded from DevBlueprint 0.1.0; current 0.1.0)
```

### 5. Create the remote and push

The workflow creates each task in its own *worktree* (next section), and that needs a copy of
your repository on GitHub to branch from. The `gh` command below creates the GitHub repository
and pushes both branches in one step (`gh` is GitHub's official command-line tool; if you do not
have it, create an empty repository on github.com and follow its "push an existing repository"
lines instead).

```bash
gh repo create hello-world --private --source=. --remote=origin --push
git push -u origin develop
```

That is your first run complete: a fully scaffolded project, under git, with both branches on
GitHub. Next we make an actual change.

## Your first task

Every piece of work - a fix, a new feature, a docs tweak - follows the same short loop: branch,
change, check, commit, push, pull request. Doing it once here makes every future change
muscle memory. Our task: add a `README.md` to the project.

### 1. Start the task in its own worktree

A *worktree* is a separate folder holding one branch, so each task stays isolated and your main
folder never changes underneath you. `wt.sh new` creates one, branched off `develop`. The name
is `<type>/<short-slug>` - here `docs` because we are adding documentation.

```bash
./scripts/wt.sh new docs/add-readme
```

It prints the path to work in - copy that `cd` line and run it:

```
Worktree ready for 'docs/add-readme':
  cd /path/to/.worktrees/hello-world/docs-add-readme
Do all work there. The hello-world clone stays on master.
```

```bash
cd /path/to/.worktrees/hello-world/docs-add-readme
```

### 2. Make the change

Create a `README.md` however you like - your editor, or this one-liner:

```bash
printf '# hello-world\n\nMy first project, scaffolded with DevBlueprint.\n' > README.md
```

### 3. Run the quality gate

Before committing anything, run the gate. It is the same set of checks CI will run, so passing
it locally means no surprises later. For the `generic` variant it is:

```bash
make check
```

On a fresh generic project the checks are placeholders (they print `TODO: wire the ...`) and the
command finishes without an error - that is a passing, "green" gate. In a real-stack variant the
same command runs the linter, type checker, tests and build for you.

```
check-env: environment configuration is valid
TODO: wire the linter for this project
TODO: wire the type checker (or remove this target)
TODO: wire the test runner
TODO: wire the build/compile step
```

### 4. Commit

Record the change with a short, structured message. The `docs:` prefix is a
[Conventional Commit](CONTRIBUTING.md) type - it says *what kind* of change this is.

```bash
git add README.md
git commit -m "docs: add project README"
```

### 5. Push and open a pull request

Push the branch to GitHub, then open a *pull request* (PR) - a request to merge your change into
`develop`, where it can be reviewed before it lands.

```bash
git push -u origin docs/add-readme
gh pr create --base develop --fill
```

`gh` prints the URL of the new pull request:

```
https://github.com/<you>/hello-world/pull/1
```

That is your first green PR. On a real project someone reviews it and merges it into `develop`;
on your own project you can merge it yourself from that page.

### 6. Clean up after it merges

Once the PR is merged, remove the finished worktree and its branch in one command (run it from
your main project folder):

```bash
cd ~/Projects/hello-world
./scripts/wt.sh gc
```

Then start the next task with `./scripts/wt.sh new ...` again. That loop - branch, change,
check, commit, push, PR, clean up - is the whole everyday workflow. Everything else in these
docs is detail on top of it.

## Where to go next

- [README](README.md) - the fast overview and full command reference.
- [`CONTRIBUTING.md`](CONTRIBUTING.md) - the day-to-day process in detail.
- [`docs/`](docs/) - the engineering standards, conventions and quality bar behind the workflow.
