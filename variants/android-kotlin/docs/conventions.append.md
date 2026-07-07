
---

## Stack-specific conventions (Android / Kotlin)

### Language & tooling

- **Kotlin, null-safe by design.** Avoid `!!` outside tests - model absence with nullable types and
  handle it deliberately. Prefer immutable `val`, data classes, and sealed hierarchies for state.
- **ktlint** owns lint + formatting (do not hand-format); **detekt** is the static-analysis gate;
  **Android Lint** catches platform, resource and manifest issues. Zero warnings in CI.
- Target one JDK (17) and pin Kotlin, AGP and Gradle; build only through the Gradle wrapper.

### Naming & structure

- Types `PascalCase`; functions/properties `camelCase`; constants `UPPER_SNAKE_CASE`; packages
  lowercase. One primary type per file; Composable functions are `PascalCase`.
- Feature-first under `app/src/main/kotlin`: `feature/<name>/` owns its Composables + `ViewModel`;
  `core/`, `data/`, `designsystem/` for cross-cutting code.
- Resources in `res/`: `snake_case` names, string keys grouped by feature.

### Compose & state

- Keep Composables thin and stateless where possible: hoist state, pass immutable data down and
  events up. No networking, DB or business logic in a `@Composable`.
- Expose UI state from a `ViewModel` as `StateFlow`/immutable snapshots; collect with
  `collectAsStateWithLifecycle`. Do async work in a coroutine scoped to the `ViewModel`.
- Inject dependencies via constructor injection (Hilt or manual DI), never a global singleton.

### Data & security

- Model networking and persistence behind interfaces (repositories) so they are fakeable and
  swappable. Keep Android framework types out of the domain layer.
- Secrets live in the Android Keystore or `local.properties` (gitignored) - never in source,
  committed resources, logs or version control. Do not commit `google-services.json` or signing keys.
- User-facing strings and formats come from `res/values/` (localizable), not literals in code.
