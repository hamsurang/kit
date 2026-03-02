#!/usr/bin/env node
// Usage: node validate-marketplace.js <manifest-path>
import { readFileSync } from 'fs';

const [manifestPath] = process.argv.slice(2);

if (!manifestPath) {
  console.error('Usage: validate-marketplace.js <manifest-path>');
  process.exit(1);
}

let data;
try {
  data = JSON.parse(readFileSync(manifestPath, 'utf-8'));
} catch (err) {
  console.error('Failed to parse manifest: ' + err.message);
  process.exit(1);
}

let failed = false;

// name: required
if (!data.name) {
  console.error('Missing required field: name');
  failed = true;
}

// owner: required object with name
if (!data.owner || typeof data.owner !== 'object') {
  console.error('Missing required field: owner (must be an object)');
  failed = true;
} else if (!data.owner.name) {
  console.error('Missing required field: owner.name');
  failed = true;
}

// plugins: required array
if (!Array.isArray(data.plugins)) {
  console.error('Missing required field: plugins (must be an array)');
  failed = true;
} else {
  data.plugins.forEach((p, i) => {
    if (!p.name) { console.error(`plugins[${i}] missing name`); failed = true; }
    if (!p.source) { console.error(`plugins[${i}] missing source`); failed = true; }
  });
}

if (failed) process.exit(1);
console.log('OK: marketplace ' + data.name + ' with ' + (data.plugins?.length ?? 0) + ' plugin(s)');
