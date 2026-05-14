#!/usr/bin/env node
import path from "node:path";

import { createWebServer } from "../src/web-server.js";

const options = parseOptions(process.argv.slice(2));
const port = Number(options.port ?? process.env.PORT ?? 4317);
const host = options.host ?? "127.0.0.1";
const defaultTargetDir = path.resolve(options.target ?? process.cwd());
const server = createWebServer({ defaultTargetDir });

server.listen(port, host, () => {
  process.stdout.write(`Agent Project Kit UI running at http://${host}:${port}\n`);
  process.stdout.write(`Default target: ${defaultTargetDir}\n`);
});

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
