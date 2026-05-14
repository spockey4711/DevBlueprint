import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";

const rootDir = path.resolve(".");
const exampleNames = ["web-saas", "fastapi-api", "ios-habit-app"];
const requiredExampleFiles = [
  "AGENTS.md",
  "docs/01-product/PRD.md",
  "docs/01-product/MVP-FREEZE.md",
  "docs/02-architecture/ARCHITECTURE.md",
  "docs/03-features/core-workflow.feature.md",
  "docs/04-tasks/NOW.md",
  "docs/05-quality/TEST-PLAN.md",
];

test("repository includes user-facing guide and standards docs", async () => {
  const guide = await readFile(path.join(rootDir, "GUIDE.md"), "utf8");
  const standards = await readFile(path.join(rootDir, "STANDARDS.md"), "utf8");

  assert.match(guide, /five-minute start/i);
  assert.match(guide, /lightweight/i);
  assert.match(guide, /balanced/i);
  assert.match(guide, /strict/i);
  assert.match(standards, /spec-first/i);
  assert.match(standards, /overwrite/i);
});

for (const exampleName of exampleNames) {
  test(`${exampleName} example contains complete foundation docs`, async () => {
    for (const relativeFile of requiredExampleFiles) {
      const content = await readFile(
        path.join(rootDir, "examples", exampleName, relativeFile),
        "utf8",
      );

      assert.notEqual(content.trim(), "");
    }
  });
}
