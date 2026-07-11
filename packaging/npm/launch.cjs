#!/usr/bin/env node
// npm/npx launcher for devblueprint.
//
// npm installs the `bin` entry as a symlink (in node_modules/.bin, or the npx
// cache). The real CLI, bin/devblueprint, resolves its kit root from
// ${BASH_SOURCE[0]} WITHOUT following symlinks, so linking it directly would make
// it look for core/ and variants/ next to the symlink and fail. Node, by
// contrast, resolves this module's realpath by default, so __dirname is the real
// packaging/npm/ directory. We compute the kit root from there and exec the real
// bin/devblueprint by its absolute path, which lets it find the kit next to it.
//
// This launcher is the only piece of JavaScript in DevBlueprint and lives solely
// in the npm distribution channel; the kit itself stays runtime-free.

'use strict';

const { spawnSync } = require('child_process');
const path = require('path');

// __dirname == <kit root>/packaging/npm, so the kit root is two levels up.
const root = path.resolve(__dirname, '..', '..');
const cli = path.join(root, 'bin', 'devblueprint');

const result = spawnSync(cli, process.argv.slice(2), { stdio: 'inherit' });

if (result.error) {
  console.error('devblueprint: failed to launch ' + cli + ': ' + result.error.message);
  process.exit(1);
}

// Mirror the child's exit: forward its signal, else its status.
if (result.signal) {
  process.kill(process.pid, result.signal);
} else {
  process.exit(result.status === null ? 1 : result.status);
}
