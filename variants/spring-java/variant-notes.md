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
- Ops artifacts ship as fillable skeletons: a multi-stage `Dockerfile` (a JDK build stage running
  `./gradlew bootJar` and extracting the layered jar -> a JRE non-root runtime) + `.dockerignore` +
  `docker-compose.yml` for containers, and `deploy/` for a hosted target (`fly.toml`, `render.yaml`,
  `terraform/`). Keep the one target you deploy to and delete the rest. Run database migrations
  (Flyway/Liquibase) as a deliberate release step, not on app boot.
- The environment is a validated contract: `.env.schema` declares each variable (required/optional,
  optional `pattern=`), and `make check` (plus CI) runs `scripts/check-env.sh` to keep `.env.example`
  in lockstep with it and enforce required keys in any real `.env`. Spring binds these to properties
  (`SPRING_DATASOURCE_URL` -> `spring.datasource.url`). Declare new variables in both the schema and
  `.env.example`, or the gate fails.
