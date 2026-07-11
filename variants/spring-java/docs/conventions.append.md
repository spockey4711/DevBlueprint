
---

## Stack-specific conventions (Java / Spring Boot)

### Language & tooling

- **Java 21 (LTS), Gradle wrapper.** Pin the version in `.java-version`, `.tool-versions` and the
  Gradle `java { toolchain }` block; build only through `./gradlew` so everyone shares one Gradle.
- **Spotless (google-java-format)** owns formatting - do not hand-format, run `./gradlew
  spotlessApply`. **Checkstyle** owns lint over main + test sources. Zero warnings in CI.
- Prefer `Optional<T>` over returning `null`; annotate nullable boundaries (`@Nullable`) and fail
  fast on invalid input rather than letting a `NullPointerException` surface deep in a call.

### Structure & Spring idioms

- Layer by responsibility: `controller` (HTTP) -> `service` (business logic) -> `repository`
  (persistence). Controllers stay thin - validate, delegate, map to a response; no business rules.
- **Constructor injection only** - no field `@Autowired`. Components stay immutable and unit-
  testable without the Spring context. Mark injected collaborators `private final`.
- Return DTOs / records from controllers, never JPA entities - keep the persistence model from
  leaking into the API contract. Validate request bodies with Bean Validation (`@Valid`).
- Handle errors centrally with `@ControllerAdvice` / `@ExceptionHandler` and a consistent error
  body; do not let stack traces or framework messages reach the client.

### Configuration & data

- Read config from `application.yml` / environment (12-factor); keep profile overrides in
  `application-<profile>.yml`. No secrets in code, logs or committed config.
- Use constructor-bound `@ConfigurationProperties` records for grouped settings instead of
  scattered `@Value` lookups.
- Manage schema with versioned migrations (Flyway or Liquibase); never rely on
  `spring.jpa.hibernate.ddl-auto` outside local development.

### Naming

- Packages `lowercase` (`com.example.app.order`); classes `PascalCase`; methods and fields
  `camelCase`; constants `UPPER_SNAKE_CASE`. Name a class by its role suffix
  (`OrderController`, `OrderService`, `OrderRepository`).
