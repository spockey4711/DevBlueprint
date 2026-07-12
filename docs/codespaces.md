# Zero-install setup: Codespaces and Dev Containers

Do not want to install git, Node, a language toolchain and an editor on your own machine just
to try a project? You do not have to. Every DevBlueprint project ships a **Dev Container** - a
recipe for a ready-made, disposable Linux environment with the right tools already inside. Open
the project in one and you get a working editor, the toolchain, and the recommended extensions
without installing anything locally.

This is the fastest way in for a beginner: click a button, wait a couple of minutes, and start
editing. Nothing to set up, nothing to break, and nothing left on your computer afterwards.

> **New to all of this?** The full local-install walkthrough is in
> [`GETTING-STARTED.md`](../GETTING-STARTED.md). This page is the shortcut around the
> "Prerequisites" section of that guide - come back here whenever a local install feels like too
> much.

## What is a Dev Container?

A *container* is a lightweight, throwaway computer-inside-your-computer (or inside the cloud). A
*Dev Container* is one described by a small file, `.devcontainer/devcontainer.json`, that lives
in the project. The file names a base image (which language and version to start from), the
editor extensions to install, and a command to run on first start. Any tool that understands it
- GitHub Codespaces or VS Code - reads that file and builds you an identical environment every
time.

Because the recipe is committed to the [repo](glossary.md#repo), everyone who opens the project gets the *same*
setup. "Works on my machine" stops being a problem.

## Two ways to open it

### GitHub Codespaces (in your browser, nothing installed)

This is the true zero-install path - it runs in the cloud, so you only need a browser and a
GitHub account.

1. Push your project to GitHub (see
   [Create the remote and push](../GETTING-STARTED.md#5-create-the-remote-and-push)), or open
   any DevBlueprint project someone has shared with you.
2. On the repository page, click the green **Code** button.
3. Open the **Codespaces** tab and click **Create codespace on develop**.
4. Wait for it to build. On first start it installs the extensions and runs `setup.sh` to wire
   the toolchain and dependencies - a few minutes, once.
5. A full VS Code opens in your browser, already set up. Open a [terminal](glossary.md#terminal) and run the [quality
   gate](glossary.md#quality-gate): `make check` (or pick it from **Terminal > Run Task**, wired by the project's
   `.vscode/tasks.json`).

> **Cost:** GitHub gives every personal account a monthly amount of free Codespaces usage, which
> is plenty for learning. A codespace also stops itself when idle. Check GitHub's current free
> tier if you use it heavily.

### Local Dev Container (in VS Code, using Docker)

Prefer to stay on your own machine but still skip installing the language toolchain? Install
these three things once, then reuse them for every project:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) - runs the container,
- [VS Code](https://code.visualstudio.com/), and
- the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

Then open the project folder in VS Code. It notices the `.devcontainer` and offers
**Reopen in Container** (or run it from the command palette). VS Code builds the environment and
reopens inside it - same result as Codespaces, running locally.

## What you get inside

Every DevBlueprint Dev Container:

- **starts from the right image** for the stack (for example the official Node, Python, Go or
  .NET image, pinned to the version the [variant](glossary.md#variant) targets),
- **installs the recommended VS Code extensions** for the stack automatically - the same list
  as the project's `.vscode/extensions.json`, so linting and language support work on the first
  keystroke, and
- **runs `setup.sh` on create**, which wires the configs and installs the project's
  dependencies, so the quality gate is ready to run.

You still work exactly as the rest of the docs describe - [worktrees](glossary.md#worktree), small [commits](glossary.md#commit), `make check`
before you push. The container just removes the "install everything first" step.

## Which projects ship one

Every variant ships a Dev Container except **ios-swift**: building an iOS app needs macOS and
Xcode, which cannot run inside a Linux container, so a Dev Container would not help there. Use a
Mac with Xcode for that variant.

Two variants are usable but partial:

- **android-kotlin** and **flutter** give you the full editor and toolchain and run the parts of
  the quality gate that work headless, but a cloud Linux container has no phone screen - you
  cannot launch an emulator or see the app render. They are great for editing, linting and unit
  tests; reach for a local machine when you need to run the app on a device.

## When "zero install" applies

The container gives *anyone opening an existing project* a zero-install environment. To create
the **very first** project you run `devblueprint init`, which needs Node on the machine you run
it from. Two easy ways around that:

- run `devblueprint init` inside any Codespace or Dev Container (Node is already there), or
- do the one-time local install in [Prerequisites](../GETTING-STARTED.md#prerequisites) - you
  only need it once, and every project afterwards can use the container path.

Either way, once the project exists on GitHub, you and everyone you work with get the click-and-
go environment for free.
