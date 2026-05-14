import { createServer } from "node:http";
import { mkdir, readdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  addDecision,
  addFeature,
  buildContextPack,
  doctorProject,
  initProject,
} from "./core.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const publicDir = path.resolve(__dirname, "..", "public");
const editableExtensions = new Set([".md", ".txt", ".json"]);

export function createWebServer(options = {}) {
  const defaultTargetDir = path.resolve(options.defaultTargetDir ?? process.cwd());

  return createServer(async (request, response) => {
    try {
      const result = await handleWebRequest({
        defaultTargetDir,
        method: request.method ?? "GET",
        requestUrl: request.url ?? "/",
        host: request.headers.host ?? "localhost",
        body: await readJson(request),
      });
      response.writeHead(result.status, { "content-type": result.contentType });
      response.end(result.body);
    } catch (error) {
      const status = error.statusCode ?? 500;
      await sendJson(response, { ok: false, error: error.message }, status);
    }
  });
}

export async function handleWebRequest({
  defaultTargetDir = process.cwd(),
  method = "GET",
  requestUrl = "/",
  host = "localhost",
  body = {},
} = {}) {
  try {
    const url = new URL(requestUrl, `http://${host}`);
    const targetRoot = path.resolve(defaultTargetDir);

    if (url.pathname === "/") {
      return await fileResponse(path.join(publicDir, "index.html"), "text/html; charset=utf-8");
    }

    if (url.pathname === "/app.css") {
      return await fileResponse(path.join(publicDir, "app.css"), "text/css; charset=utf-8");
    }

    if (url.pathname === "/app.js") {
      return await fileResponse(path.join(publicDir, "app.js"), "text/javascript; charset=utf-8");
    }

    if (url.pathname === "/api/state" && method === "GET") {
      const targetDir = targetFromQuery(url, targetRoot);
      const [doctor, files] = await Promise.all([
        doctorProject({ targetDir }),
        listEditableFiles(targetDir),
      ]);
      return jsonResponse({ ok: true, targetDir, doctor, files });
    }

    if (url.pathname === "/api/files" && method === "GET") {
      const targetDir = targetFromQuery(url, targetRoot);
      return jsonResponse({ ok: true, files: await listEditableFiles(targetDir) });
    }

    if (url.pathname === "/api/file" && method === "GET") {
      const targetDir = targetFromQuery(url, targetRoot);
      const file = url.searchParams.get("file") ?? "";
      const filePath = resolveProjectFile(targetDir, file);
      return jsonResponse({ ok: true, file, content: await readFile(filePath, "utf8") });
    }

    if (url.pathname === "/api/file" && method === "PUT") {
      const targetDir = path.resolve(body.targetDir ?? targetRoot);
      const file = body.file ?? "";
      const filePath = resolveProjectFile(targetDir, file);
      await mkdir(path.dirname(filePath), { recursive: true });
      await writeFile(filePath, String(body.content ?? ""), "utf8");
      return jsonResponse({ ok: true, file });
    }

    if (url.pathname === "/api/init" && method === "POST") {
      const result = await initProject({
        targetDir: body.targetDir ?? targetRoot,
        projectName: body.projectName,
        projectType: body.projectType,
        framework: body.framework,
        aiTool: body.aiTool,
        mode: body.mode,
        force: body.force === true,
      });
      return jsonResponse({ ok: true, result });
    }

    if (url.pathname === "/api/feature" && method === "POST") {
      const result = await addFeature({
        targetDir: body.targetDir ?? targetRoot,
        name: body.name,
        problem: body.problem,
        goal: body.goal,
        users: body.users,
        mvpRelevance: body.mvpRelevance,
        acceptanceCriteria: splitLines(body.acceptanceCriteria),
      });
      return jsonResponse({ ok: true, result });
    }

    if (url.pathname === "/api/decision" && method === "POST") {
      const result = await addDecision({
        targetDir: body.targetDir ?? targetRoot,
        title: body.title,
        status: body.status,
        context: body.context,
        decision: body.decision,
        alternatives: splitLines(body.alternatives),
        positiveConsequences: splitLines(body.positiveConsequences),
        negativeConsequences: splitLines(body.negativeConsequences),
      });
      return jsonResponse({ ok: true, result });
    }

    if (url.pathname === "/api/context" && method === "POST") {
      const pack = await buildContextPack({
        targetDir: body.targetDir ?? targetRoot,
        topic: body.topic,
      });
      return jsonResponse({
        ok: true,
        files: pack.files,
        instruction: pack.instruction,
        output: pack.toString(),
      });
    }

    return jsonResponse({ ok: false, error: "Not found" }, 404);
  } catch (error) {
    return jsonResponse({ ok: false, error: error.message }, error.statusCode ?? 500);
  }
}

export async function listEditableFiles(targetDir) {
  const root = path.resolve(targetDir);
  const files = [];

  await collectFiles(root, root, files);
  return files.sort((a, b) => a.localeCompare(b));
}

async function collectFiles(root, currentDir, files) {
  let entries = [];

  try {
    entries = await readdir(currentDir, { withFileTypes: true });
  } catch (error) {
    if (error.code === "ENOENT") {
      return;
    }

    throw error;
  }

  for (const entry of entries) {
    if (entry.name === ".git" || entry.name === "node_modules") {
      continue;
    }

    const absolutePath = path.join(currentDir, entry.name);
    if (entry.isDirectory()) {
      await collectFiles(root, absolutePath, files);
      continue;
    }

    if (entry.isFile() && editableExtensions.has(path.extname(entry.name))) {
      files.push(toPosix(path.relative(root, absolutePath)));
    }
  }
}

function resolveProjectFile(targetDir, relativeFile) {
  if (!relativeFile || path.isAbsolute(relativeFile)) {
    throw httpError(400, "File must be a relative project path.");
  }

  const root = path.resolve(targetDir);
  const filePath = path.resolve(root, relativeFile);
  const relative = path.relative(root, filePath);

  if (relative.startsWith("..") || path.isAbsolute(relative)) {
    throw httpError(400, "File path escapes the target project.");
  }

  if (!editableExtensions.has(path.extname(filePath))) {
    throw httpError(400, "Only Markdown, text, and JSON files are editable.");
  }

  return filePath;
}

function targetFromQuery(url, defaultTargetDir) {
  return path.resolve(url.searchParams.get("target") || defaultTargetDir);
}

async function sendFile(response, filePath, contentType) {
  const content = await readFile(filePath);
  response.writeHead(200, { "content-type": contentType });
  response.end(content);
}

async function fileResponse(filePath, contentType) {
  return {
    status: 200,
    contentType,
    body: await readFile(filePath, "utf8"),
  };
}

function jsonResponse(payload, status = 200) {
  return {
    status,
    contentType: "application/json; charset=utf-8",
    body: JSON.stringify(payload),
  };
}

async function sendJson(response, payload, status = 200) {
  response.writeHead(status, { "content-type": "application/json; charset=utf-8" });
  response.end(JSON.stringify(payload));
}

async function readJson(request) {
  const chunks = [];

  for await (const chunk of request) {
    chunks.push(chunk);
  }

  if (chunks.length === 0) {
    return {};
  }

  return JSON.parse(Buffer.concat(chunks).toString("utf8"));
}

function splitLines(value) {
  if (!value) {
    return [];
  }

  if (Array.isArray(value)) {
    return value;
  }

  return String(value)
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean);
}

function httpError(statusCode, message) {
  const error = new Error(message);
  error.statusCode = statusCode;
  return error;
}

function toPosix(value) {
  return value.split(path.sep).join("/");
}
