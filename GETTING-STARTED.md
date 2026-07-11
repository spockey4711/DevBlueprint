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
