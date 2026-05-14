import assert from "node:assert/strict";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {
  doctorProject,
  initProject,
  projectTypeStructures,
} from "../src/core.js";

async function withTempDir(fn) {
  const dir = await mkdtemp(path.join(os.tmpdir(), "apkit-"));

  try {
    await fn(dir);
  } finally {
    await rm(dir, { force: true, recursive: true });
  }
}

test("initProject creates the base documentation and AGENTS.md", async () => {
  await withTempDir(async (targetDir) => {
    const result = await initProject({
      targetDir,
      projectName: "meal-planner",
      projectType: "web-app",
      framework: "nextjs",
      aiTool: "codex",
      mode: "balanced",
    });

    assert.equal(result.created.includes("AGENTS.md"), true);
    assert.equal(result.skipped.length, 0);

    const agents = await readFile(path.join(targetDir, "AGENTS.md"), "utf8");
    assert.match(agents, /meal-planner/);
    assert.match(agents, /web-app/);
    assert.match(agents, /codex/);

    const prd = await readFile(
      path.join(targetDir, "docs", "01-product", "PRD.md"),
      "utf8",
    );
    assert.match(prd, /# PRD: meal-planner/);
  });
});

test("initProject creates project-type specific source and test folders", async () => {
  await withTempDir(async (targetDir) => {
    await initProject({
      targetDir,
      projectName: "habit-ios",
      projectType: "ios-app",
      framework: "swiftui",
      aiTool: "claude-code",
      mode: "strict",
    });

    for (const folder of projectTypeStructures["ios-app"]) {
      const marker = await readFile(path.join(targetDir, folder, ".gitkeep"), "utf8");
      assert.equal(marker, "");
    }

    const appStoreReadiness = await readFile(
      path.join(targetDir, "docs", "05-quality", "APP-STORE-READINESS.md"),
      "utf8",
    );
    assert.match(appStoreReadiness, /App Store Readiness/);
  });
});

test("initProject does not overwrite existing files by default", async () => {
  await withTempDir(async (targetDir) => {
    const agentsPath = path.join(targetDir, "AGENTS.md");
    await writeFile(agentsPath, "custom agent rules", "utf8");

    const result = await initProject({
      targetDir,
      projectName: "existing-project",
      projectType: "custom",
      framework: "other",
      aiTool: "generic-llm",
      mode: "lightweight",
    });

    assert.equal(result.skipped.includes("AGENTS.md"), true);
    assert.equal(await readFile(agentsPath, "utf8"), "custom agent rules");
  });
});

test("doctorProject reports missing required files", async () => {
  await withTempDir(async (targetDir) => {
    await initProject({
      targetDir,
      projectName: "api-kit",
      projectType: "api-backend",
      framework: "fastapi",
      aiTool: "cursor",
      mode: "balanced",
    });

    await rm(path.join(targetDir, "docs", "01-product", "MVP-FREEZE.md"));

    const report = await doctorProject({ targetDir });

    assert.equal(report.ok, false);
    assert.deepEqual(report.missing, ["docs/01-product/MVP-FREEZE.md"]);
  });
});
