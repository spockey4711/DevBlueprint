#!/usr/bin/env node
import {
  addDecision,
  addFeature,
  buildContextPack,
  doctorProject,
  initProject,
} from "../src/core.js";

const [, , command, subcommand, ...args] = process.argv;

try {
  if (command === "init") {
    const options = parseOptions([subcommand, ...args].filter(Boolean));
    const result = await initProject({
      targetDir: options.target ?? ".",
      projectName: options.name,
      projectType: options.type ?? "custom",
      framework: options.framework ?? "other",
      aiTool: options["ai-tool"] ?? "generic-llm",
      mode: options.mode ?? "balanced",
      force: options.force === true,
    });

    print(`Created ${result.created.length} files/folders.`);
    if (result.skipped.length > 0) {
      print(`Skipped ${result.skipped.length} existing files.`);
    }
  } else if (command === "add" && subcommand === "feature") {
    const options = parseOptions(args);
    const result = await addFeature({
      targetDir: options.target ?? ".",
      name: options.name,
      problem: options.problem,
      goal: options.goal,
      users: options.users,
      mvpRelevance: options["mvp-relevance"],
      force: options.force === true,
    });

    print(`${capitalize(result.status)} feature spec: ${result.file}`);
  } else if (command === "add" && subcommand === "decision") {
    const options = parseOptions(args);
    const result = await addDecision({
      targetDir: options.target ?? ".",
      title: options.title,
      status: options.status,
      context: options.context,
      decision: options.decision,
      force: options.force === true,
    });

    print(`${capitalize(result.status)} decision record: ${result.file}`);
  } else if (command === "doctor") {
    const options = parseOptions([subcommand, ...args].filter(Boolean));
    const report = await doctorProject({ targetDir: options.target ?? "." });

    if (report.ok) {
      print("Project structure looks complete.");
    } else {
      print("Missing required files:");
      for (const file of report.missing) {
        print(`- ${file}`);
      }
      process.exitCode = 1;
    }
  } else if (command === "context") {
    const options = parseOptions(args);
    const pack = await buildContextPack({
      targetDir: options.target ?? ".",
      topic: subcommand,
    });

    print(pack.toString().trimEnd());
  } else {
    printHelp();
    process.exitCode = command ? 1 : 0;
  }
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}

function parseOptions(args) {
  const options = {};

  for (let index = 0; index < args.length; index += 1) {
    const arg = args[index];

    if (!arg.startsWith("--")) {
      continue;
    }

    const key = arg.slice(2);
    const next = args[index + 1];

    if (!next || next.startsWith("--")) {
      options[key] = true;
    } else {
      options[key] = next;
      index += 1;
    }
  }

  return options;
}

function printHelp() {
  print(`Agent Project Kit

Usage:
  apkit init --target <dir> --name <name> --type <type> --framework <framework> --ai-tool <tool> --mode <mode>
  apkit add feature --target <dir> --name <name>
  apkit add decision --target <dir> --title <title>
  apkit context <topic> --target <dir>
  apkit doctor --target <dir>
`);
}

function print(message) {
  process.stdout.write(`${message}\n`);
}

function capitalize(value) {
  return value.charAt(0).toUpperCase() + value.slice(1);
}
