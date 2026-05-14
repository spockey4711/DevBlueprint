import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";

export const baseRequiredFiles = [
  "AGENTS.md",
  "docs/00-inbox/questions.md",
  "docs/00-inbox/raw-ideas.md",
  "docs/00-inbox/decisions-needed.md",
  "docs/01-product/PRD.md",
  "docs/01-product/MVP-FREEZE.md",
  "docs/01-product/USER-STORIES.md",
  "docs/01-product/NON-GOALS.md",
  "docs/01-product/ROADMAP.md",
  "docs/02-architecture/ARCHITECTURE.md",
  "docs/02-architecture/TECH-STACK.md",
  "docs/02-architecture/FILETREE.md",
  "docs/02-architecture/DATA-MODEL.md",
  "docs/02-architecture/API-CONTRACTS.md",
  "docs/02-architecture/SECURITY.md",
  "docs/03-features/_feature-template.md",
  "docs/04-tasks/NOW.md",
  "docs/04-tasks/NEXT.md",
  "docs/04-tasks/BACKLOG.md",
  "docs/04-tasks/BLOCKED.md",
  "docs/04-tasks/DONE.md",
  "docs/05-quality/ACCEPTANCE-CRITERIA.md",
  "docs/05-quality/TEST-PLAN.md",
  "docs/05-quality/REVIEW-CHECKLIST.md",
  "docs/05-quality/RELEASE-CHECKLIST.md",
  "docs/06-agent-context/CODING-RULES.md",
  "docs/06-agent-context/OUTPUT-RULES.md",
  "docs/06-agent-context/CONTEXT-RULES.md",
  "docs/06-agent-context/PROMPTS.md",
];

export const projectTypeStructures = {
  "web-app": [
    "src/app",
    "src/components",
    "src/features",
    "src/lib",
    "src/server",
    "src/styles",
    "tests/unit",
    "tests/integration",
    "tests/e2e",
  ],
  "api-backend": [
    "app/routes",
    "app/services",
    "app/repositories",
    "app/models",
    "app/schemas",
    "app/core",
    "tests/unit",
    "tests/integration",
  ],
  "ios-app": [
    "Sources/App",
    "Sources/Features",
    "Sources/Shared",
    "Sources/Core",
    "Sources/DesignSystem",
    "Tests/UnitTests",
    "Tests/UITests",
  ],
  portfolio: [
    "src/components",
    "src/content",
    "src/pages",
    "src/styles",
    "tests/unit",
  ],
  custom: [],
};

const projectTypeFiles = {
  "web-app": [
    ["docs/02-architecture/ROUTES.md", "# Routes\n\nDocument application routes here.\n"],
    ["docs/02-architecture/AUTH.md", "# Auth\n\nDocument authentication choices here.\n"],
  ],
  "api-backend": [
    ["docs/02-architecture/DATABASE.md", "# Database\n\nDocument database choices here.\n"],
  ],
  "ios-app": [
    ["docs/02-architecture/NAVIGATION.md", "# Navigation\n\nDocument navigation flows here.\n"],
    [
      "docs/02-architecture/STATE-MANAGEMENT.md",
      "# State Management\n\nDocument state ownership and data flow here.\n",
    ],
    [
      "docs/05-quality/ACCESSIBILITY-CHECKLIST.md",
      "# Accessibility Checklist\n\n- [ ] Dynamic Type reviewed.\n- [ ] VoiceOver labels reviewed.\n",
    ],
    [
      "docs/05-quality/APP-STORE-READINESS.md",
      "# App Store Readiness\n\n- [ ] Privacy details reviewed.\n- [ ] Release metadata prepared.\n",
    ],
  ],
  portfolio: [
    [
      "docs/01-product/PERSONAL-BRANDING.md",
      "# Personal Branding\n\nDocument positioning, audience, and proof points here.\n",
    ],
    ["docs/01-product/CONTENT-PLAN.md", "# Content Plan\n\nDocument portfolio content here.\n"],
  ],
  custom: [],
};

export async function initProject(config) {
  const normalized = normalizeConfig(config);
  const files = [
    ...baseRequiredFiles.map((file) => [file, renderBaseFile(file, normalized)]),
    ...(projectTypeFiles[normalized.projectType] ?? []),
  ];

  const result = { created: [], skipped: [] };

  await mkdir(normalized.targetDir, { recursive: true });

  for (const [relativePath, content] of files) {
    const status = await writeProjectFile(normalized.targetDir, relativePath, content, {
      force: normalized.force,
    });
    result[status].push(relativePath);
  }

  for (const folder of projectTypeStructures[normalized.projectType] ?? []) {
    await mkdir(path.join(normalized.targetDir, folder), { recursive: true });
    const status = await writeProjectFile(normalized.targetDir, path.join(folder, ".gitkeep"), "", {
      force: normalized.force,
    });
    result[status].push(path.join(folder, ".gitkeep"));
  }

  return result;
}

export async function doctorProject({ targetDir }) {
  const missing = [];

  for (const relativePath of baseRequiredFiles) {
    try {
      await readFile(path.join(targetDir, relativePath));
    } catch (error) {
      if (error.code === "ENOENT") {
        missing.push(relativePath);
      } else {
        throw error;
      }
    }
  }

  return {
    ok: missing.length === 0,
    missing,
  };
}

function normalizeConfig(config) {
  const projectType = config.projectType ?? "custom";

  if (!Object.hasOwn(projectTypeStructures, projectType)) {
    throw new Error(`Unsupported project type: ${projectType}`);
  }

  return {
    targetDir: path.resolve(config.targetDir ?? "."),
    projectName: config.projectName ?? path.basename(path.resolve(config.targetDir ?? ".")),
    projectType,
    framework: config.framework ?? "other",
    aiTool: config.aiTool ?? "generic-llm",
    mode: config.mode ?? "balanced",
    force: config.force ?? false,
  };
}

async function writeProjectFile(targetDir, relativePath, content, options) {
  const destination = path.join(targetDir, relativePath);
  await mkdir(path.dirname(destination), { recursive: true });

  if (!options.force) {
    try {
      await readFile(destination);
      return "skipped";
    } catch (error) {
      if (error.code !== "ENOENT") {
        throw error;
      }
    }
  }

  await writeFile(destination, content, "utf8");
  return "created";
}

function renderBaseFile(relativePath, config) {
  const title = titleFromPath(relativePath);

  if (relativePath === "AGENTS.md") {
    return `# AGENTS.md

## Project

- Name: ${config.projectName}
- Type: ${config.projectType}
- Framework: ${config.framework}
- AI tool: ${config.aiTool}
- Mode: ${config.mode}

## Rules

- Read \`docs/01-product/MVP-FREEZE.md\` before suggesting new scope.
- Every new feature must have a feature spec in \`docs/03-features/\`.
- Do not change architecture decisions without updating \`docs/02-architecture/ARCHITECTURE.md\`.
- After implementation, update relevant task files.
- Prefer small, reviewable changes.
- Do not add dependencies without explaining why.
`;
  }

  if (relativePath === "docs/01-product/PRD.md") {
    return `# PRD: ${config.projectName}

## Problem

Describe the user problem.

## Goal

Describe the product goal.

## MVP Scope

List the smallest useful scope.
`;
  }

  if (relativePath === "docs/01-product/MVP-FREEZE.md") {
    return `# MVP Freeze

## MVP Goal

Build the smallest version that validates the core product value.

## Allowed in MVP

- Project initialization
- Base documentation generation
- AGENTS.md generation

## Not Allowed in MVP

- Cloud sync
- User accounts
- Web dashboard

## Rule

If a feature does not directly support the MVP goal, move it to BACKLOG.md.
`;
  }

  if (relativePath === "docs/03-features/_feature-template.md") {
    return `# Feature Spec: <Name>

## Status

Draft

## Problem

## Goal

## Non-Goals

## User Stories

## Acceptance Criteria

## Open Questions
`;
  }

  return `# ${title}

TBD.
`;
}

function titleFromPath(relativePath) {
  return path
    .basename(relativePath, path.extname(relativePath))
    .toLowerCase()
    .split(/[-_]/)
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}
