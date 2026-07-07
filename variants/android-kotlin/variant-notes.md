## Stack notes (Android / Kotlin)

- Worktrees: `./scripts/wt.sh new <type>/<slug>` (post-create warms the Gradle wrapper). Everything
  builds through `./gradlew`, so local, CI and teammates share the pinned Gradle.
- Feature-first under `app/src/main/kotlin`: `feature/<name>/` owns its screens (Composables) and
  `ViewModel`; `core/` for cross-cutting services and DI, `designsystem/` for theme + shared UI,
  `data/` for repositories behind interfaces.
- Keep Composables thin - no business logic or IO in a `@Composable`; hoist state and push work into
  a `ViewModel` exposing `StateFlow`. Inject dependencies (Hilt/manual), never a global singleton.
- User-facing strings go in `res/values/strings.xml` via `stringResource`, never literals in views.
  Secrets in the Android Keystore / `local.properties` (gitignored), never in source or committed
  resources.
- ktlint owns lint + format, detekt is the static-analysis gate, Android Lint catches
  platform/resource issues; all warnings fail CI. Unit tests run on the JVM (`testDebugUnitTest`).
