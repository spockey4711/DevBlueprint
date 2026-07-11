## Stack notes (Java / Spring Boot)

- Worktrees: `./scripts/wt.sh new <type>/<slug>` (post-create warms the Gradle wrapper). Every
  Gradle task goes through `./gradlew` so local, CI and teammates build with the pinned Gradle.
- Layered by responsibility: `controller` (HTTP boundary) -> `service` (business logic) ->
  `repository` (persistence). Controllers stay thin; keep logic testable in services, not in the
  web layer.
- Constructor injection only - no field `@Autowired`. It keeps components immutable, makes
  dependencies explicit, and lets you build them in a plain unit test without the Spring context.
- Spotless (google-java-format) owns formatting - do not hand-format. Checkstyle owns lint and
  runs over main + test sources. Zero warnings in CI.
- Configuration and secrets come from `application.properties`/`application.yml` and the
  environment (12-factor), never hard-coded. Keep profile-specific overrides in
  `application-<profile>.yml`; never commit real credentials.
- Prefer slice tests (`@WebMvcTest`, `@DataJpaTest`) over booting the whole context, and reach
  for Testcontainers when a test genuinely needs a real database or broker.
