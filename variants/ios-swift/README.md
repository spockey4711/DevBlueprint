# Variant: iOS app (Swift + Xcode)

A Swift/SwiftUI app stack: feature-first layout, SwiftFormat + SwiftLint, XCTest/Swift Testing,
GitHub Actions CI on macOS.

## Quality gate

```bash
swiftformat --lint . && swiftlint --strict && swift build && swift test
```

(For an `.xcodeproj`/`.xcworkspace` app, use `xcodebuild ... build test` instead of the SPM
`swift build`/`swift test`.)

## What `devblueprint init --variant ios-swift` adds

- `docs/engineering/` - git-workflow, conventions (+ Swift/SwiftUI overlay),
  quality-and-testing, engineering-standards.
- `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md` filled in for this stack.
- `scripts/wt.sh` + `scripts/wt.conf` (post-create runs `swift package resolve`).
- `.github/workflows/ci.yml` (format + lint + build + test on macOS).
- `.github/dependabot.yml` (swift + github-actions updates) and `.tool-versions` (toolchain pin).
- `.gitignore` for Xcode/Swift.
- `Sources/` and `Tests/` skeleton.

## After init (wire the toolchain)

`init` drops a `setup.sh` in the project. Run it once:

```bash
./setup.sh              # writes .swiftlint.yml + .swiftformat, installs a committable
                        # .githooks/pre-commit (core.hooksPath), brew-installs the formatters
./setup.sh --no-install # config only, skip brew
```

Idempotent; never clobbers existing files. Two things it cannot do for you: create the Xcode
project / `Package.swift`, and (for an app target) switch the CI build/test steps to
`xcodebuild` with a simulator destination.
