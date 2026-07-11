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

With all four checks passing, you have everything you need. Next, decide
[where the project should live](#choosing-a-folder-for-your-project).

## Choosing a folder for your project

Where on your computer the project should live, how to pick a good path (and avoid a bad one),
what `~` means, and how to open that folder in both the terminal and your editor.

_(coming soon)_

## Your first run

Scaffolding your first project with DevBlueprint: the single command that sets everything up,
and what you should see when it works.

_(coming soon)_

## Your first task

Taking one small change from a fresh branch through commits, the quality gate and a pull request
- the everyday loop you will repeat for every piece of work.

_(coming soon)_

## Where to go next

- [README](README.md) - the fast overview and full command reference.
- [`CONTRIBUTING.md`](CONTRIBUTING.md) - the day-to-day process in detail.
- [`docs/`](docs/) - the engineering standards, conventions and quality bar behind the workflow.
