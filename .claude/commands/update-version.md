---
description: Bump semver versions for changed plugins and marketplace based on main diff
allowed-tools: Bash(git diff:*), Bash(git log:*), Read, Edit
---

## Context

- Changed files vs main: !`git diff --name-only origin/main...HEAD`
- Current marketplace.json: !`cat .claude-plugin/marketplace.json`

## Your task

1. **Find changed plugins**
   Parse the changed files list. For each unique `plugins/<name>/` directory, that plugin needs a version bump.

2. **For each changed plugin**:
   - Read `plugins/<name>/.claude-plugin/plugin.json`
   - Get the diff for that plugin: `git diff origin/main...HEAD -- plugins/<name>/`
   - Determine bump type:
     - `major`: skill or command file removed/renamed, breaking behavior change
     - `minor`: new command, skill, or agent file added
     - `patch`: content edits, docs, bug fixes, refactoring
   - Bump `version` in `plugin.json` using semver (e.g. 1.0.0 → 1.0.1 for patch)

3. **Bump marketplace version** in `.claude-plugin/marketplace.json`:
   - Take the highest bump type across all changed plugins
   - Apply that bump to the current marketplace `version` field

4. **Report** all changes: list each plugin and old→new version, and marketplace old→new version.

Do NOT commit. Only update the JSON files.
