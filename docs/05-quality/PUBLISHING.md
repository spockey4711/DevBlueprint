# Publishing

## Decision

Version 0.1 is prepared for public npm distribution. Local usage remains supported through `node bin/apkit.js`, but the release target is:

```bash
npm publish
```

## Pre-Publish Checks

Run these commands before publishing:

```bash
npm test
npm run test:coverage
npm pack --dry-run
```

## Package Contents

The npm package should include:
- CLI entry points in `bin/`
- Runtime source in `src/`
- Local web interface assets in `public/`
- Product and quality docs in `docs/`
- Prompt library in `prompts/`
- Example projects in `examples/`
- README, guide, standards, changelog, and license files

## Release Notes

Use `CHANGELOG.md` as the source for version notes.
