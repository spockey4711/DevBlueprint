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
- `.gitignore` for Xcode/Swift.
- `Sources/` and `Tests/` skeleton.

## After init (wire the toolchain)

1. Create the Xcode project or `Package.swift`.
2. Add `.swiftlint.yml` and a SwiftFormat config; install both (`brew install swiftlint
   swiftformat`).
3. Add a `pre-commit` git hook that runs SwiftFormat + SwiftLint on staged files.
4. If it is an app target, adjust the CI build/test steps to `xcodebuild` with a simulator
   destination.
