# Quality and testing

**Purpose:** the quality bar for this project. Concrete overlay of the blueprint's
[shared quality shape](engineering-standards.md). Fill the `make` targets in the `Makefile`
with your stack's real commands.

## The quality gate (must be green to merge)

Run locally before pushing; CI runs the identical set on every PR:

```bash
make check   # chains: make lint && make typecheck && make test && make build
```

Wire each target in the `Makefile`. If a gate does not apply (e.g. no separate typecheck for a
dynamically typed language with no type checker), remove that target rather than leaving a stub.

## Testing strategy

Test what has logic or can silently break; do not chase coverage on trivial glue.

- **Unit tests** for pure logic: calculations, parsers, data transforms, adapter fallback
  behavior.
- **A few smoke tests** for the critical happy path.
- Write the smallest relevant test first, then broaden when shared behavior changes.

Target: meaningful coverage of the logic layer, not a global percentage.

## Security and commit gates

Every PR also runs the security-gate baseline in `.github/workflows/` (shared
across variants), complementing the quality gate above:

- **`security.yml`** - gitleaks secret scanning, semgrep SAST, and (on PRs)
  `dependency-review` against the GitHub Advisory Database.
- **`commit-checks.yml`** - commitlint on every commit plus a Conventional-Commits
  check on the PR title (the squash-merge subject).

## Release automation

On every push to `master`, `release.yml` runs
[release-please](https://github.com/googleapis/release-please), turning the
Conventional-Commits history into releases and closing the loop on the changelog
discipline above:

- It maintains a standing **release PR** whose diff is the next SemVer bump plus
  the generated `CHANGELOG.md` entries (`feat` -> minor, `fix`/`perf` -> patch,
  `BREAKING CHANGE` -> major). Merging that PR tags the release and publishes a
  GitHub Release.
- `release-please-config.json` pins the release strategy to `simple` - release-please has no native updater for this stack, so the
  version lives in `release-please-manifest.json` alone. Add your build's
  version file (e.g. `gradle.properties`, `*.csproj`, `Info.plist`) to
  `extra-files` in the config to have that bumped in the same PR.
- This automates the manual "move `[Unreleased]`, tag, publish" steps in the git
  workflow: let the merged commits drive `CHANGELOG.md` instead of hand-editing it.

## Provider-agnostic CI (GitLab)

The kit is not GitHub-only. Each project also ships a `.gitlab-ci.yml` that mirrors
the same gates, so it can live on either forge:

- **`quality`** stage - runs the quality gate above.
- **`security`** stage - GitLab's managed SAST, secret detection and dependency
  scanning, the GitLab-native counterpart to the GitHub security gate.
- **`deploy`** stage - the `deploy:preview` job (below).

`workflow:` rules run the pipeline on merge requests and the protected branches
without spawning duplicate pipelines. Delete `.gitlab-ci.yml` if the project is
hosted on GitHub only.

## Preview deploy

A provider-neutral preview environment ships for both forges - `preview-deploy.yml`
on GitHub and the `deploy:preview` job on GitLab. On every PR/MR it stands up an
ephemeral environment and comments its URL, then tears it down when the PR/MR
closes. The plumbing is wired; only the deploy step is a TODO, so point it at your
host (Vercel, Netlify, GitHub/GitLab Pages, Fly, ...).

## Definition of done

1. It works and matches the spec.
2. `make check` is green.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR and is deployable (or deployed).
