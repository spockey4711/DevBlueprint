
---

## Stack-specific conventions (Swift / SwiftUI)

### Language & tooling

- **Swift with strict concurrency** where the project can adopt it; no `@unchecked Sendable`
  without a reason. Avoid force-unwraps (`!`) and force-`try!` outside tests - handle `nil` and
  errors deliberately.
- **SwiftFormat** owns formatting; **SwiftLint `--strict`** is the lint gate. Zero warnings.
- Pin the SwiftFormat and SwiftLint versions in `.tool-versions` so local, CI and teammates run
  the same formatter/linter; keep them in step with what CI brew-installs.

### Naming & structure

- Types `PascalCase`; properties/functions `camelCase`; enum cases `camelCase`.
- Feature-first layout under `Sources/`: `Features/<Feature>/` owns its views, view model and
  models. `Core/` for cross-cutting services, `DesignSystem/` for tokens and shared UI,
  `Shared/` for small utilities.
- One primary type per file.

### SwiftUI & state

- Keep views thin: no business logic or networking in a `View` body - push it into an
  `@Observable` view model or a store.
- Inject dependencies via protocols (init injection or the environment), never reach for a
  global singleton.
- User-facing strings go through String Catalogs (`.xcstrings`), never string literals in views.

### Data & security

- Secrets in the Keychain, never in `UserDefaults`, source, or a plist committed to git.
- Model networking and persistence behind protocols so they are testable and swappable.
