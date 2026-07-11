# Quality and testing

**Purpose:** the quality bar and how it is enforced for this .NET service. Concrete overlay of
the blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing (`make check`); CI runs the identical set on every PR:

```bash
dotnet format --verify-no-changes    # formatting + code style + analyzers are canonical
dotnet build --configuration Release  # compiles clean; warnings are errors (Directory.Build.props)
dotnet test                           # unit + integration tests (xUnit)
```

Everything runs on the SDK pinned in `global.json` so local, CI and teammates use the same
toolchain. Install the pre-commit hook (`setup.sh` wires it via `core.hooksPath`) and
`dotnet format --verify-no-changes` runs on every commit.

## Testing strategy

Test behavior, not the framework. Favor fast tests that do not spin up the whole host.

- **Unit (xUnit + Moq/FluentAssertions):** service logic, mappers, validators, domain rules -
  constructor-inject collaborators and build them directly, no host or DI container.
- **Integration (`WebApplicationFactory<T>`):** exercise the real request pipeline in-memory
  (routing, model binding, middleware, DI) without a network hop. Cheaper and sharper than
  standing up the full app against external services.
- **End-to-end / data:** reserve for paths that genuinely need a running database or broker; back
  them with Testcontainers or the EF Core in-memory/SQLite provider so the test owns its data.
- **Web contract:** assert status codes, the JSON body shape and `ProblemDetails` error responses,
  not just the happy path. Cover validation failures and the central exception handler.

Target meaningful coverage of the service and domain layers and the API contract - not a global
percentage, and not auto-properties or framework glue.

## Tooling

- **dotnet CLI (SDK pinned in `global.json`)** - build, restore, test and format; used everywhere.
- **dotnet format** - the single formatter and code-style fixer; `dotnet format` fixes,
  `--verify-no-changes` gates. No hand-formatting.
- **Roslyn analyzers** - lint via `EnableNETAnalyzers` + `AnalysisLevel`, severities driven by
  `.editorconfig` and enforced in the build (`EnforceCodeStyleInBuild`, `TreatWarningsAsErrors`).
- **xUnit** - the test framework, with FluentAssertions + Moq and the Microsoft test SDK adapters.
- **WebApplicationFactory + Testcontainers** - integration tests against the real pipeline and
  real dependencies.
- **pre-commit hook** - `.githooks/pre-commit` runs `dotnet format --verify-no-changes` on commit.
- **CI** - `.github/workflows/ci.yml` runs the full gate on every PR into `develop`/`master`.

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

## Definition of done

1. It works, the endpoint/behavior does what the task asked, and errors are handled deliberately.
2. `dotnet format`, the Release build and the tests are green; new logic is covered at the right
   layer.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR.
