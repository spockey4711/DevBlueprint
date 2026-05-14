import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";

const rootDir = path.resolve(".");

test("github actions workflow runs the project test suite", async () => {
  const workflow = await readFile(
    path.join(rootDir, ".github", "workflows", "ci.yml"),
    "utf8",
  );

  assert.match(workflow, /npm test/);
  assert.match(workflow, /npm run test:coverage/);
  assert.match(workflow, /node-version/);
});
