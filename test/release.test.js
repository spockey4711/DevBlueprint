import assert from "node:assert/strict";
import { access, readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";

const rootDir = path.resolve(".");

test("package metadata supports npm CLI distribution", async () => {
  const packageJson = JSON.parse(
    await readFile(path.join(rootDir, "package.json"), "utf8"),
  );

  assert.equal(packageJson.name, "agent-project-kit");
  assert.equal(packageJson.type, "module");
  assert.equal(packageJson.bin.apkit, "./bin/apkit.js");
  assert.equal(packageJson.bin["agent-project-kit"], "./bin/apkit.js");
  assert.equal(packageJson.scripts.test, "node --test");
  assert.equal(packageJson.repository.type, "git");
  assert.equal(packageJson.repository.url, "git+https://github.com/spockey4711/DevBlueprint.git");
  assert.equal(packageJson.bugs.url, "https://github.com/spockey4711/DevBlueprint/issues");
  assert.equal(packageJson.homepage, "https://github.com/spockey4711/DevBlueprint#readme");
  assert.equal(packageJson.publishConfig.access, "public");
  assert.deepEqual(packageJson.files, [
    "bin",
    "src",
    "docs",
    "examples",
    "prompts",
    "README.md",
    "GUIDE.md",
    "STANDARDS.md",
    "LICENSE",
    "CHANGELOG.md",
  ]);
  await access(path.join(rootDir, "bin", "apkit.js"));
});

test("release checklist covers version 0.1 readiness", async () => {
  const checklist = await readFile(
    path.join(rootDir, "docs", "05-quality", "RELEASE-READINESS.md"),
    "utf8",
  );

  assert.match(checklist, /Version 0\.1/);
  assert.match(checklist, /npm test/);
  assert.match(checklist, /npm run test:coverage/);
  assert.match(checklist, /examples/);
  assert.match(checklist, /MVP-FREEZE/);
});

test("release documentation includes license, changelog, and publishing notes", async () => {
  const license = await readFile(path.join(rootDir, "LICENSE"), "utf8");
  const changelog = await readFile(path.join(rootDir, "CHANGELOG.md"), "utf8");
  const publishing = await readFile(path.join(rootDir, "docs", "05-quality", "PUBLISHING.md"), "utf8");

  assert.match(license, /MIT License/);
  assert.match(changelog, /0\.1\.0/);
  assert.match(changelog, /Agent Project Kit foundation/);
  assert.match(publishing, /npm publish/);
  assert.match(publishing, /npm pack --dry-run/);
});
