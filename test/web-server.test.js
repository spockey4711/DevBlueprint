import assert from "node:assert/strict";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { handleWebRequest } from "../src/web-server.js";

async function withWebHandler(fn) {
  const targetDir = await mkdtemp(path.join(os.tmpdir(), "apkit-web-"));

  try {
    await fn({ targetDir });
  } finally {
    await rm(targetDir, { force: true, recursive: true });
  }
}

test("web server serves the onboarding interface", async () => {
  await withWebHandler(async ({ targetDir }) => {
    const response = await request({ defaultTargetDir: targetDir });
    const html = response.body;

    assert.equal(response.status, 200);
    assert.match(html, /Agent Project Kit/);
    assert.match(html, /Create Project/);
  });
});

test("web API initializes a project and lists editable files", async () => {
  await withWebHandler(async ({ targetDir }) => {
    const initResponse = await request({
      defaultTargetDir: targetDir,
      requestUrl: "/api/init",
      method: "POST",
      body: {
        targetDir,
        projectName: "local-ui-test",
        projectType: "web-app",
        framework: "nextjs",
        aiTool: "codex",
        mode: "balanced",
      },
    });
    const initResult = JSON.parse(initResponse.body);

    assert.equal(initResponse.status, 200);
    assert.equal(initResult.ok, true);
    assert.equal(initResult.result.created.includes("AGENTS.md"), true);

    const filesResponse = await request({
      defaultTargetDir: targetDir,
      requestUrl: `/api/files?target=${encodeURIComponent(targetDir)}`,
    });
    const filesResult = JSON.parse(filesResponse.body);

    assert.equal(filesResponse.status, 200);
    assert.equal(filesResult.files.includes("docs/01-product/PRD.md"), true);
    assert.equal(filesResult.files.includes("docs/03-features/_feature-template.md"), true);
  });
});

test("web API reads and writes project files inside the target", async () => {
  await withWebHandler(async ({ targetDir }) => {
    await request({
      defaultTargetDir: targetDir,
      requestUrl: "/api/init",
      method: "POST",
      body: { targetDir, projectName: "editable" },
    });

    const writeResponse = await request({
      defaultTargetDir: targetDir,
      requestUrl: "/api/file",
      method: "PUT",
      body: {
        targetDir,
        file: "docs/01-product/PRD.md",
        content: "# PRD: editable\n\nUpdated from the local interface.\n",
      },
    });

    assert.equal(writeResponse.status, 200);
    assert.equal(
      await readFile(path.join(targetDir, "docs", "01-product", "PRD.md"), "utf8"),
      "# PRD: editable\n\nUpdated from the local interface.\n",
    );

    const readResponse = await request({
      defaultTargetDir: targetDir,
      requestUrl: `/api/file?target=${encodeURIComponent(targetDir)}&file=${encodeURIComponent("docs/01-product/PRD.md")}`,
    });
    const readResult = JSON.parse(readResponse.body);

    assert.equal(readResult.content, "# PRD: editable\n\nUpdated from the local interface.\n");
  });
});

test("web API rejects path traversal outside the target", async () => {
  await withWebHandler(async ({ targetDir }) => {
    const response = await request({
      defaultTargetDir: targetDir,
      requestUrl: "/api/file",
      method: "PUT",
      body: {
        targetDir,
        file: "../escape.md",
        content: "nope",
      },
    });

    assert.equal(response.status, 400);
  });
});

test("web API creates features, decisions, and context packs", async () => {
  await withWebHandler(async ({ targetDir }) => {
    await request({
      defaultTargetDir: targetDir,
      requestUrl: "/api/init",
      method: "POST",
      body: { targetDir, projectName: "workflow" },
    });

    const featureResponse = await request({
      defaultTargetDir: targetDir,
      requestUrl: "/api/feature",
      method: "POST",
      body: {
        targetDir,
        name: "User Authentication",
        problem: "Users need access control.",
        goal: "Users can log in.",
      },
    });
    const featureResult = JSON.parse(featureResponse.body);

    const decisionResponse = await request({
      defaultTargetDir: targetDir,
      requestUrl: "/api/decision",
      method: "POST",
      body: {
        targetDir,
        title: "Use Next.js",
        status: "Accepted",
      },
    });
    const decisionResult = JSON.parse(decisionResponse.body);

    const contextResponse = await request({
      defaultTargetDir: targetDir,
      requestUrl: "/api/context",
      method: "POST",
      body: { targetDir, topic: "user-authentication" },
    });
    const contextResult = JSON.parse(contextResponse.body);

    assert.equal(featureResult.result.file, "docs/03-features/user-authentication.feature.md");
    assert.equal(decisionResult.result.file, "docs/02-architecture/decisions/0001-use-nextjs.md");
    assert.match(contextResult.output, /user-authentication/);
    assert.equal(contextResult.files.includes("docs/03-features/user-authentication.feature.md"), true);
  });
});

function request(options = {}) {
  return handleWebRequest(options);
}
