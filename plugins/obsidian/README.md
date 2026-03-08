# obsidian

Work with Obsidian vaults — search, create, edit, organize notes and manage frontmatter.

## Install

```bash
claude plugin add minsoo-web/hamkit/plugins/obsidian
```

## Prerequisites

- [obsidian-cli](https://github.com/yakitrak/obsidian-cli) — `brew install yakitrak/yakitrak/obsidian-cli`
- [Obsidian](https://obsidian.md) — desktop app (for URI-based note opening)

## What it does

This skill teaches Claude Code how to work with Obsidian vaults efficiently:

- **Direct file access** for reading and editing notes (Read/Edit/Write tools)
- **obsidian-cli** for search, link-aware move/rename, frontmatter, and daily notes
- **Vault discovery** from Obsidian's config file
- **Multi-vault** support via `--vault` flag

## Usage examples

- "Find my notes about API design"
- "Create a new note in Projects/backend-refactor"
- "Move my meeting notes to Archive"
- "Update the frontmatter status to done"
- "Open today's daily note"
- "Search for all TODOs in my vault"
