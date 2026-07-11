# Homebrew tap and release runbook

DevBlueprint installs three ways: `npx devblueprint`, the `curl | sh` installer
([`install.sh`](../../install.sh)), and Homebrew. This directory holds the Homebrew
formula ([`devblueprint.rb`](devblueprint.rb)) and the maintainer steps to publish it.

All three channels ship the **whole kit** (`bin/ core/ variants/ scripts/ VERSION`), because
`bin/devblueprint` resolves `core/` and `variants/` relative to its own real path and does not
follow symlinks. That is why the formula installs into `libexec` and exposes a wrapper (not a
symlink) in `bin`.

## Cutting a release

1. Make sure the version is consistent. The kit version lives in [`VERSION`](../../VERSION);
   the npm package mirrors it in [`package.json`](../../package.json) (`version`). Bump both
   together, then commit.
2. Tag and push a release, e.g. `v0.1.0`, and create a GitHub release for that tag. GitHub
   serves the source tarball at:
   `https://github.com/spockey4711/DevBlueprint/archive/refs/tags/v0.1.0.tar.gz`
3. Compute the tarball checksum:
   ```sh
   curl -fsSL https://github.com/spockey4711/DevBlueprint/archive/refs/tags/v0.1.0.tar.gz \
     | shasum -a 256
   ```
4. In [`devblueprint.rb`](devblueprint.rb), update `url` to the new tag and replace
   `REPLACE_WITH_RELEASE_TARBALL_SHA256` with the checksum from step 3.

## Publishing the tap

Homebrew taps are their own repositories named `homebrew-<tap>`.

1. Create a public repo `spockey4711/homebrew-devblueprint`.
2. Copy `devblueprint.rb` into it at `Formula/devblueprint.rb`.
3. Users then install with:
   ```sh
   brew install spockey4711/devblueprint/devblueprint
   ```
   (`brew tap spockey4711/devblueprint` first is optional; the fully-qualified name auto-taps.)
4. Verify locally before pushing:
   ```sh
   brew install --build-from-source ./Formula/devblueprint.rb
   brew test devblueprint
   brew audit --strict --new devblueprint
   ```

## Publishing to npm

From the repo root, with `package.json` `version` matching the tag:

```sh
npm publish
```

The `files` allowlist in `package.json` ensures the published tarball carries the whole kit and
the npm launcher (`packaging/npm/launch.cjs`), so `npx devblueprint` works without a clone.
