# Quality and testing

**Purpose:** the quality bar and how it is enforced for this Spring Boot service. Concrete
overlay of the blueprint's [shared quality shape](engineering-standards.md).

## The quality gate (must be green to merge)

Run locally before pushing (`make check`); CI runs the identical set on every PR:

```bash
./gradlew spotlessCheck       # formatting is canonical (google-java-format)
./gradlew checkstyleMain      # static analysis on main sources - zero warnings
./gradlew checkstyleTest      # static analysis on test sources - zero warnings
./gradlew test                # unit + slice tests (JUnit 5)
```

Everything runs through the Gradle wrapper so local, CI and teammates use the pinned Gradle and
JDK. Install the pre-commit hook (`setup.sh` wires it via `core.hooksPath`) and Spotless +
Checkstyle run on every commit.

## Testing strategy

Test behavior, not the framework. Favor fast tests that do not boot the whole context.

- **Unit (JUnit 5 + Mockito/AssertJ):** service logic, mappers, validators, domain rules -
  constructor-inject collaborators and build them directly, no Spring context.
- **Slice tests:** `@WebMvcTest` for controllers (MockMvc, mocked services), `@DataJpaTest` for
  repositories against an in-memory or Testcontainers database. Cheaper and sharper than a full
  `@SpringBootTest`.
- **Integration (`@SpringBootTest`):** reserve for wiring and end-to-end paths that genuinely
  need the running context; back them with Testcontainers when a real database or broker matters.
- **Web contract:** assert status codes, the JSON body shape and error responses, not just the
  happy path. Cover validation failures and the `@ControllerAdvice` error mapping.

Target meaningful coverage of the service and domain layers and the API contract - not a global
percentage, and not getters/setters or framework glue.

## Tooling

- **Gradle (wrapper)** - build, dependency management and task runner; `./gradlew` everywhere.
- **Spotless** - google-java-format as the single formatter; `spotlessApply` fixes, `spotlessCheck`
  gates. No hand-formatting.
- **Checkstyle** - lint over main + test sources; config in `config/checkstyle/checkstyle.xml`.
- **JUnit 5** - the test platform (`test { useJUnitPlatform() }`), with AssertJ + Mockito.
- **Spring Boot Test + Testcontainers** - slice and integration tests against real dependencies.
- **pre-commit hook** - `.githooks/pre-commit` runs Spotless + Checkstyle on staged changes.
- **CI** - `.github/workflows/ci.yml` runs the full gate on every PR into `develop`/`master`.

## Security and commit gates

Every PR also runs the security-gate baseline in `.github/workflows/` (shared
across variants), complementing the quality gate above:

- **`security.yml`** - gitleaks secret scanning, semgrep SAST, and (on PRs)
  `dependency-review` against the GitHub Advisory Database.
- **`codeql.yml`** - GitHub CodeQL semantic analysis; findings surface under
  Security > Code scanning.
- **`commit-checks.yml`** - commitlint on every commit plus a Conventional-Commits
  check on the PR title (the squash-merge subject).
- **`coverage.yml`** - reports line coverage and enforces a soft floor read from
  the `COVERAGE_MIN` repository variable (default `0`, i.e. report-only), so the
  threshold is opt-in and never reddens a fresh scaffold.

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

1. It works, the endpoint/behavior does what the task asked, and errors are handled deliberately.
2. Spotless, Checkstyle and the tests are green; new logic is covered at the right layer.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR.
