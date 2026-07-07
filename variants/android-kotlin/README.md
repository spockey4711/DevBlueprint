# Variant: Android app (Kotlin + Gradle)

A modern Android app stack: Kotlin + Jetpack Compose, feature-first layout, ktlint (lint + format),
detekt (static analysis), Android Lint, JUnit unit tests, all built through the Gradle wrapper with
GitHub Actions CI on JDK 17.

## Quality gate

```bash
./gradlew ktlintCheck detekt lintDebug testDebugUnitTest
```

Or, with the shipped Makefile: `make check`.

## What `devblueprint init --variant android-kotlin` adds

- `docs/engineering/` - git-workflow, conventions (+ Android/Kotlin overlay), quality-and-testing,
  engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create warms the Gradle wrapper).
- `Makefile` wiring the quality gate (`make check`).
- `.github/workflows/ci.yml` (ktlint + detekt + Android Lint + unit tests on JDK 17).
- `.github/dependabot.yml` (gradle + github-actions updates) and `.tool-versions` (toolchain pin).
- `.gitignore` for Android/Gradle/Android Studio artifacts (incl. `local.properties` + signing keys).
- `app/src/{main,test,androidTest}` and a `res/` scaffold.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. Run it once:

```bash
./setup.sh              # writes config/detekt/detekt.yml, appends a ktlint block to
                        # .editorconfig, installs a committable .githooks/pre-commit
                        # (core.hooksPath), and brew-installs ktlint + detekt
./setup.sh --no-install # config only, skip brew
```

Idempotent; never clobbers existing files. Two things it cannot do for you: create the
Gradle/Android Studio project, and add the ktlint + detekt Gradle plugins to `build.gradle.kts`
(the exact plugin block is printed at the end of `setup.sh`).
