# Getting started

New to the terminal, git, or programming in general? Start here. This guide takes you from
nothing installed to your first green pull request, explaining each step in plain language and
*why* it looks the way it does. No prior experience assumed.

If you are already fluent with a terminal, git and package managers, you can skip this guide
and go straight to the [README](README.md) - it covers the same ground faster.

> This guide is being written in stages. Sections marked _(coming soon)_ are placeholders that
> will be filled in shortly; the headings show what is planned so you know what to expect.

## Prerequisites

Before you scaffold your first project you need four things installed:

- a **terminal** - the window where you type commands instead of clicking,
- **git** - the tool that records the history of your changes,
- **Node** - the runtime that lets the `devblueprint` command run, and
- a **code editor** - where you read and write the project's files.

You install them once and every future project reuses them. Work through the four in order.
Each block below is safe to copy and paste exactly as written - just pick the lines for your
operating system. After every install there is a check command and the output you should see
if it worked. If the output looks close to the example (version numbers will differ, that is
fine) you are done; if you get `command not found`, the install did not finish - re-run it or
open a fresh terminal so it picks up the new command.

> **macOS: install Homebrew first.** The macOS steps below use [Homebrew](https://brew.sh), the
> standard package manager for the Mac. Install it once by pasting this into your terminal and
> following the prompts (it will ask for your password):
>
> ```bash
> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
> ```
>
> When it finishes it prints two `Next steps` lines starting with `echo` and `eval` - run those
> so `brew` is on your PATH, then confirm with `brew --version` (you should see `Homebrew 4.x.x`).

### 1. A terminal

You almost certainly already have one - you just need to find it and open it:

- **macOS** - press Cmd+Space, type `Terminal`, press Enter.
- **Windows** - press the Start key, type `Terminal`, press Enter. (On older Windows without it,
  install *Windows Terminal* from the Microsoft Store first, then reopen it this way.)
- **Linux** - press Ctrl+Alt+T, or open your applications menu and search for `Terminal`.

Type this and press Enter to confirm the terminal responds:

```bash
echo "hello"
```

You should see:

```text
hello
```

Keep this window open - you will run every command below in it.

### 2. git

Install it:

- **macOS**
  ```bash
  brew install git
  ```
- **Windows**
  ```powershell
  winget install --id Git.Git -e
  ```
- **Linux** (Debian / Ubuntu; use your distro's package manager on others)
  ```bash
  sudo apt update && sudo apt install -y git
  ```

Then close and reopen the terminal so it sees the new command, and check:

```bash
git --version
```

You should see a line like this (the numbers will differ):

```text
git version 2.43.0
```

### 3. Node

Node comes bundled with `npm`, which is what actually fetches and runs `devblueprint`.

- **macOS**
  ```bash
  brew install node
  ```
- **Windows**
  ```powershell
  winget install --id OpenJS.NodeJS.LTS -e
  ```
- **Linux** (Debian / Ubuntu; installs the current LTS from NodeSource)
  ```bash
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt install -y nodejs
  ```

Reopen the terminal, then check both commands:

```bash
node --version
npm --version
```

You should see two version lines like these (again, the numbers will differ):

```text
v22.14.0
10.9.2
```

### 4. A code editor

We use [Visual Studio Code](https://code.visualstudio.com) (VS Code) throughout this guide - it
is free, runs on all three systems, and DevBlueprint ships settings that make it work nicely.

- **macOS**
  ```bash
  brew install --cask visual-studio-code
  ```
- **Windows**
  ```powershell
  winget install --id Microsoft.VisualStudioCode -e
  ```
- **Linux** - download the `.deb` / `.rpm` from
  [code.visualstudio.com/download](https://code.visualstudio.com/download) and open it with your
  software installer, or use your distro's store.

All three installers add a `code` command to your terminal. Reopen the terminal and check:

```bash
code --version
```

You should see three lines - a version number, a long commit hash, and your architecture:

```text
1.96.4
cd4ee3b1c348a13bafd8f9ad8060705f6d4b9cba
arm64
```

> If `code` reports `command not found` on macOS, open VS Code once, press
> Cmd+Shift+P, run *Shell Command: Install 'code' command in PATH*, then reopen the terminal.

With all four checks passing, you have everything you need. Once you have DevBlueprint itself,
you can confirm the essentials in one step instead of checking each command by hand:

```bash
bin/devblueprint doctor --env
```

It checks that git, Node and a working shell are present and, if any is missing, prints the exact
copy-paste command to install it on your system. When it says *all prerequisites present*, you are
ready. Next, decide [where the project should live](#choosing-a-folder-for-your-project).

## Choosing a folder for your project

Before you scaffold anything, you need to decide *where on your computer* the project's files
will live. That place is just a folder (also called a directory). Picking a sensible one now
keeps things tidy, and a couple of the rules below head off errors that trip up almost everyone
at the start.

### What a path is

A **path** is the address of a file or folder on your computer, the same way a street address
points to a house. `~/Projects/myapp` is a path; so is `/Users/you/Documents`. The terminal
always has one folder it is "in" right now - your **working directory** - and many commands act
on that folder unless you tell them otherwise.

### Absolute vs. relative paths

There are two ways to write a path, and the difference matters:

- An **absolute path** spells out the full location from the very top of your drive, so it means
  the same place no matter where your terminal currently is. On macOS and Linux it starts with a
  slash (`/Users/you/Projects/myapp`) or the `~` shortcut below; on Windows it starts with a
  drive letter (`C:\Users\you\Projects\myapp`).
- A **relative path** is read starting from your current working directory. `myapp` means "a
  folder called `myapp` inside wherever I am right now", `./myapp` means the same thing
  explicitly, and `../myapp` means "up one level, then into `myapp`".

Rule of thumb for this guide: when you tell DevBlueprint where to put a project (the `--target`
option you will see later), use an **absolute path**. Then the command does the same thing no
matter which folder your terminal happens to be sitting in.

### What `~` means

`~` (a "tilde") is shorthand for your **home folder** - `/Users/you` on macOS, `/home/you` on
Linux, `C:\Users\you` on Windows. So `~/Projects/myapp` is an absolute path that expands to
`/Users/you/Projects/myapp`. Writing `~` keeps commands short and lets the same command work on
a different machine or user account.

One catch: `~` is expanded by the terminal, so it only works when you type it in the terminal.
Do not paste a `~` path into a graphical "open folder" dialog - there it is just a literal
character, not your home folder.

### Keep spaces (and odd characters) out of the path

Name folders with **lowercase letters, digits, and hyphens** - `my-app`, `side-project-2`.
Avoid spaces and punctuation. A space is how the terminal separates one argument from the next,
so a path like `~/My Projects/app` is read as two separate things and the command fails; you
would have to wrap it in quotes every single time. Accented letters and symbols cause similar
surprises. Prefer `~/Projects/my-app` over `~/My Projects/My App` and you will never think about
it again.

### A good default: `~/Projects/<name>`

When in doubt, keep all your code under a single `~/Projects` folder, with one subfolder per
project. A project called `myapp` then lives at `~/Projects/myapp`. It is easy to remember, it
is out of the way of your Desktop and Downloads, and every project sits next to its siblings.

Create the `Projects` folder once (you do not need to create the project folder itself - the
`devblueprint init` command in the next section does that for you):

```bash
mkdir -p ~/Projects
```

`mkdir` makes a directory; the `-p` flag creates any missing parent folders and stays quiet if
the folder already exists, so the command is safe to run more than once.

### Opening the folder in the terminal

To "go into" a folder in the terminal, use `cd` ("change directory"), then confirm where you
landed with `pwd` ("print working directory"):

```bash
cd ~/Projects/myapp
pwd
```

You should see the full absolute path printed back, e.g. `/Users/you/Projects/myapp`. That is
how you check you are in the right place before running a command that acts on the current
folder.

### Opening the folder in your editor

Open the **whole folder**, not a single file - that is what lets the editor see the entire
project (all the files, the git history, the quality gate) at once. In VS Code, from the
terminal:

```bash
code ~/Projects/myapp
```

If your shell reports `command not found: code`, open VS Code once, press `Cmd+Shift+P` (macOS)
or `Ctrl+Shift+P` (Windows/Linux) to open the Command Palette, and run **Shell Command: Install
'code' command in PATH**. After that the `code` command works.

No terminal shortcut? You can always open the editor first and use **File > Open Folder...**,
then pick the folder you created. Either way, open the folder rather than a lone file.

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

Prefer a button to a memorised command? Every project ships a `.vscode/tasks.json`, so in VS
Code you can press `Cmd+Shift+B` (macOS) or `Ctrl+Shift+B` (Windows/Linux) to run the whole gate,
or open **Terminal > Run Task...** to pick a single step (lint, tests, build). The task runs your
variant's real gate - the same one CI runs - so it stays honest as you wire the checks in.

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
