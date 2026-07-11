# Variant: Backend service (Java + Spring Boot)

A typed JVM backend stack: Spring Boot on Java 21, the Gradle wrapper, Spotless
(google-java-format) for formatting, Checkstyle for static analysis, JUnit 5 for tests, and
GitHub Actions CI.

## Quality gate

```bash
./gradlew spotlessCheck checkstyleMain checkstyleTest test
```

Or, with the shipped Makefile: `make check`.

## What `devblueprint init --variant spring-java` adds

- `docs/engineering/` - git-workflow, conventions (+ Java/Spring overlay),
  quality-and-testing, engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create warms the Gradle wrapper).
- `Makefile` wiring the quality gate (`make check`).
- `.github/workflows/ci.yml` (Spotless + Checkstyle + tests).
- `.github/dependabot.yml` (gradle + github-actions updates) and `.tool-versions` (toolchain pin).
- `.gitignore` for Java / Gradle / Spring Boot artifacts.
- `src/main/java`, `src/main/resources`, `src/test/java`, `src/test/resources` scaffold.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. It cannot create the Spring Boot project for you -
generate that first with [Spring Initializr](https://start.spring.io) (Gradle + Java 21) or
`gradle init`, keeping the Gradle wrapper. Then run:

```bash
./setup.sh              # writes .java-version, config/checkstyle/checkstyle.xml,
                        # the pre-commit hook (via core.hooksPath), then warms ./gradlew
./setup.sh --no-install # config only
```

Finish by adding the Spotless + Checkstyle Gradle plugins (the exact block is printed at the end
of `setup.sh`) so `make check` and CI can resolve their tasks. Idempotent; never clobbers
existing files.
