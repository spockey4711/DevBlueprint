## Stack notes (Swift / SwiftUI)

- Worktrees: `./scripts/wt.sh new <type>/<slug>` (post-create runs `swift package resolve`).
- Feature-first under `Sources/`: `Features/<Feature>/` owns its views + view model; `Core/`,
  `DesignSystem/`, `Shared/` for cross-cutting code.
- Keep `View` bodies thin - logic and networking live in an `@Observable` view model or store,
  injected via protocols (no global singletons).
- User-facing strings via String Catalogs, never literals in views. Secrets in the Keychain.
- SwiftFormat + SwiftLint `--strict`; avoid force-unwraps outside tests.
