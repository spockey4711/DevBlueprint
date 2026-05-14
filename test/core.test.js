import assert from "node:assert/strict";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {
  addDecision,
  addFeature,
  buildContextPack,
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

test("addFeature creates a slugged feature spec with required sections", async () => {
  await withTempDir(async (targetDir) => {
    const result = await addFeature({
      targetDir,
      name: "User Authentication",
      problem: "Private project data needs controlled access.",
      goal: "Users can sign in and out securely.",
      users: "Solo builders",
      mvpRelevance: "Required for private projects.",
      acceptanceCriteria: [
        "User can log in with email and password.",
        "Invalid credentials show a clear error.",
      ],
      affectedFiles: ["src/features/auth"],
      dependencies: ["session storage"],
      openQuestions: ["Should email verification be required?"],
    });

    assert.equal(result.status, "created");
    assert.equal(result.file, "docs/03-features/user-authentication.feature.md");

    const feature = await readFile(path.join(targetDir, result.file), "utf8");
    assert.match(feature, /# Feature Spec: User Authentication/);
    assert.match(feature, /## Status\n\nDraft/);
    assert.match(feature, /## Problem/);
    assert.match(feature, /## Goal/);
    assert.match(feature, /## MVP Relevance/);
    assert.match(feature, /## Acceptance Criteria/);
    assert.match(feature, /User can log in with email and password/);
    assert.match(feature, /## Open Questions/);
  });
});

test("addFeature preserves duplicate feature specs by default", async () => {
  await withTempDir(async (targetDir) => {
    await addFeature({ targetDir, name: "Search" });

    const result = await addFeature({
      targetDir,
      name: "Search",
      problem: "This should not overwrite the original file.",
    });

    assert.equal(result.status, "skipped");
    assert.equal(result.file, "docs/03-features/search.feature.md");

    const feature = await readFile(path.join(targetDir, result.file), "utf8");
    assert.doesNotMatch(feature, /This should not overwrite/);
  });
});

test("addDecision creates numbered architecture decision records", async () => {
  await withTempDir(async (targetDir) => {
    const first = await addDecision({
      targetDir,
      title: "Use Next.js",
      status: "Accepted",
      context: "The project needs routing and server-rendering options.",
      decision: "Use Next.js as the web framework.",
      alternatives: ["Vite + React", "Astro"],
      positiveConsequences: ["Strong ecosystem"],
      negativeConsequences: ["More framework complexity"],
    });

    const second = await addDecision({
      targetDir,
      title: "Use SQLite",
    });

    assert.equal(first.file, "docs/02-architecture/decisions/0001-use-nextjs.md");
    assert.equal(second.file, "docs/02-architecture/decisions/0002-use-sqlite.md");

    const decision = await readFile(path.join(targetDir, first.file), "utf8");
    assert.match(decision, /# Decision: Use Next.js/);
    assert.match(decision, /## Status\n\nAccepted/);
    assert.match(decision, /## Context/);
    assert.match(decision, /## Decision/);
    assert.match(decision, /## Alternatives Considered/);
    assert.match(decision, /## Consequences/);
    assert.match(decision, /Positive:/);
    assert.match(decision, /Negative:/);
  });
});

test("buildContextPack includes baseline and topic-specific files", async () => {
  await withTempDir(async (targetDir) => {
    await initProject({
      targetDir,
      projectName: "meal-planner",
      projectType: "web-app",
      framework: "nextjs",
      aiTool: "codex",
      mode: "balanced",
    });
    await addFeature({ targetDir, name: "User Authentication" });

    const pack = await buildContextPack({
      targetDir,
      topic: "user-authentication",
    });

    assert.equal(pack.files.includes("AGENTS.md"), true);
    assert.equal(pack.files.includes("docs/01-product/PRD.md"), true);
    assert.equal(pack.files.includes("docs/01-product/MVP-FREEZE.md"), true);
    assert.equal(pack.files.includes("docs/05-quality/TEST-PLAN.md"), true);
    assert.equal(pack.files.includes("docs/03-features/user-authentication.feature.md"), true);
    assert.match(pack.instruction, /user-authentication/);
    assert.match(pack.instruction, /Do not modify unrelated features/);
  });
});

test("buildContextPack renders copyable terminal output", async () => {
  await withTempDir(async (targetDir) => {
    await initProject({
      targetDir,
      projectName: "api-kit",
      projectType: "api-backend",
      framework: "fastapi",
      aiTool: "generic-llm",
      mode: "balanced",
    });

    const pack = await buildContextPack({ targetDir, topic: "billing" });
    const output = pack.toString();

    assert.match(output, /For the next AI coding session, load these files:/);
    assert.match(output, /1\. AGENTS\.md/);
    assert.match(output, /Task instruction:/);
    assert.match(output, /billing/);
  });
});
