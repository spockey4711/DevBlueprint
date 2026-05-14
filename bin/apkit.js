#!/usr/bin/env node
import { doctorProject, initProject } from "../src/core.js";

const [, , command, ...args] = process.argv;

try {
  if (command === "init") {
    const options = parseOptions(args);
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
  } else if (command === "doctor") {
    const options = parseOptions(args);
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
  apkit doctor --target <dir>
`);
}

function print(message) {
  process.stdout.write(`${message}\n`);
}
