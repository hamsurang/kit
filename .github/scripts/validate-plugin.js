#!/usr/bin/env node
// Usage: node validate-plugin.js <manifest-path> <dir-name>
import { readFileSync } from 'fs';

const [manifestPath, dirName] = process.argv.slice(2);

if (!manifestPath || !dirName) {
  console.error('Usage: validate-plugin.js <manifest-path> <dir-name>');
  process.exit(1);
}

let manifest;
try {
  manifest = JSON.parse(readFileSync(manifestPath, 'utf-8'));
} catch (err) {
  console.error('Failed to parse manifest: ' + err.message);
  process.exit(1);
}

let failed = false;

// Required top-level fields
const required = ['name', 'version', 'description', 'category', 'license'];
for (const field of required) {
  if (!manifest[field]) {
    console.error('Missing required field: ' + field);
    failed = true;
  }
}

// Required author fields
if (!manifest.author) {
  console.error('Missing required field: author');
  failed = true;
} else {
  for (const field of ['name', 'github']) {
    if (!manifest.author[field]) {
      console.error('Missing required field: author.' + field);
      failed = true;
    }
  }
}

// Category validation
const validCategories = [
  'productivity', 'git', 'code-quality', 'documentation',
  'ai-agents', 'integrations', 'learning', 'security', 'devops', 'data'
];
if (manifest.category && !validCategories.includes(manifest.category)) {
  console.error('Invalid category: ' + manifest.category + '. Must be one of: ' + validCategories.join(', '));
  failed = true;
}

// Name format: kebab-case only
const nameRegex = /^[a-z0-9-]+$/;
if (manifest.name && !nameRegex.test(manifest.name)) {
  console.error('Invalid name: ' + manifest.name + '. Must be kebab-case.');
  failed = true;
}

// Name length
if (manifest.name && manifest.name.length > 50) {
  console.error('Name exceeds 50 characters: ' + manifest.name);
  failed = true;
}

// Description length
if (manifest.description && manifest.description.length > 200) {
  console.error('Description exceeds 200 characters (' + manifest.description.length + ')');
  failed = true;
}

// Name must match directory name
if (manifest.name && manifest.name !== dirName) {
  console.error('Plugin name "' + manifest.name + '" does not match directory "' + dirName + '"');
  failed = true;
}

// Semver format
const semverRegex = /^\d+\.\d+\.\d+(-[a-zA-Z0-9.]+)?(\+[a-zA-Z0-9.]+)?$/;
if (manifest.version && !semverRegex.test(manifest.version)) {
  console.error('Invalid version: ' + manifest.version + '. Must follow semver (e.g. 1.0.0)');
  failed = true;
}

if (failed) process.exit(1);
console.log('OK: ' + manifest.name + '@' + manifest.version);
