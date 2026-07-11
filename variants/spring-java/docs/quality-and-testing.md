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

## Definition of done

1. It works, the endpoint/behavior does what the task asked, and errors are handled deliberately.
2. Spotless, Checkstyle and the tests are green; new logic is covered at the right layer.
3. Docs are updated and `CHANGELOG.md` has an entry.
4. It is merged via a reviewed PR.
