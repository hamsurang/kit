---
name: obsidian
description: >
  Work with Obsidian vaults — search, create, edit, move, and organize Markdown
  notes using obsidian-cli and direct file access. Trigger this skill when the user
  mentions Obsidian, vault (보관함), daily notes (데일리 노트), wikilinks ([[link]]),
  frontmatter, backlinks, graph view, canvas, knowledge base, PKM, Zettelkasten,
  or obsidian-cli. Also trigger when the user wants to search/create/edit/move notes
  in their Obsidian vault, manage YAML frontmatter (tags, status, metadata), open
  today's daily note, rename notes with link updates, explore vault structure,
  or sync vaults via Obsidian Headless (`ob` CLI) — even if they just say
  "내 노트에서 찾아줘", "메모 정리해줘", "vault 동기화", or reference a vault path.
  Do NOT trigger for generic Markdown file editing (README.md, docs/), code
  documentation, or other note-taking apps (Notion, Bear, Apple Notes).
metadata:
  openclaw:
    emoji: "💎"
    requires:
      bins: ["obsidian-cli"]
    install:
      - id: brew
        kind: brew
        formula: yakitrak/yakitrak/obsidian-cli
        bins: ["obsidian-cli"]
        label: "Install obsidian-cli (brew)"
---

# Obsidian Vault Skill

Obsidian vault = a normal folder of Markdown files on disk. Claude Code can read and edit these files directly — use `obsidian-cli` only when its features add real value (search, link-aware move/rename, frontmatter ops, opening in Obsidian).

## Tool Selection Guide

Pick the right tool for each task:

| Task | Best tool | Why |
|------|-----------|-----|
| Read note content | `Read` tool | Direct, fast, no overhead |
| Edit note content | `Edit` tool | Precise diffs, preserves formatting |
| Create new note (no need to open) | `Write` tool | Direct file creation |
| Create note + open in Obsidian | `obsidian-cli create --open` | Triggers Obsidian URI |
| Search note names | `obsidian-cli search "query"` | Fuzzy matching across vault |
| Search inside notes | `obsidian-cli search-content "query"` | Shows snippets + line numbers |
| Broad content search | `Grep` tool on vault path | Regex support, faster for patterns |
| Find notes by name pattern | `Glob` tool on vault path | Pattern matching (e.g., `**/*meeting*.md`) |
| Move/rename note | `obsidian-cli move` | Updates `[[wikilinks]]` across vault |
| View/edit frontmatter | `obsidian-cli frontmatter` | Structured YAML manipulation |
| Open daily note | `obsidian-cli daily` | Creates if needed, opens in Obsidian |
| List vault contents | `obsidian-cli list` | Tree view of vault structure |
| Delete note | `obsidian-cli delete` | Safe removal |
| Sync vault (no desktop) | `ob sync` | Headless sync without Obsidian app |
| Check sync status | `ob sync-status` | Show pending changes |

## Step 1: Find the Vault

Before any vault operation, resolve the vault path. Never hardcode paths.

```bash
# If default vault is set:
obsidian-cli print-default --path-only

# If no default is set, read the Obsidian config directly:
cat ~/Library/Application\ Support/obsidian/obsidian.json
```

The config JSON has a `vaults` object — each entry has a `path` and `open` field. Use the vault with `"open": true`. Multiple vaults are common (work/personal, iCloud/local).

If the user hasn't set a default and has multiple vaults, ask which one to use. Then set it:

```bash
obsidian-cli set-default "<vault-folder-name>"
```

## Step 2: Work with Notes

### Reading notes

Use the `Read` tool directly on the `.md` file — it's faster and keeps context lean:

```
Read: /path/to/vault/Projects/my-note.md
```

For reading with backlink context, use obsidian-cli:

```bash
obsidian-cli print "Projects/my-note" --mentions
```

### Creating notes

For simple note creation, use `Write` tool directly:

```
Write: /path/to/vault/Folder/New Note.md
Content: "# New Note\n\nContent here..."
```

To create AND open in Obsidian:

```bash
obsidian-cli create "Folder/New Note" --content "# New Note" --open
```

To append to an existing note:

```bash
obsidian-cli create "Folder/Existing Note" --content "Appended text" --append
```

### Editing notes

Use the `Edit` tool for precise content changes — it shows clear diffs and preserves formatting. This is almost always better than obsidian-cli for content modification.

### Searching

For finding notes by name:

```bash
obsidian-cli search "project plan"
```

For searching inside note content:

```bash
obsidian-cli search-content "API design"
```

For regex or pattern-based search, use `Grep` directly on the vault path — it's faster and supports regex:

```
Grep: pattern="TODO|FIXME" path="/path/to/vault"
```

For finding notes by filename pattern:

```
Glob: pattern="**/daily/**/*.md" path="/path/to/vault"
```

### Moving / Renaming

Always use `obsidian-cli move` — it updates `[[wikilinks]]` and Markdown links across the entire vault, which plain `mv` cannot do:

```bash
obsidian-cli move "Old Folder/note" "New Folder/note"
```

### Frontmatter

View frontmatter:

```bash
obsidian-cli frontmatter "My Note" --print
```

Edit a frontmatter key:

```bash
obsidian-cli frontmatter "My Note" --edit --key "status" --value "done"
```

Delete a frontmatter key:

```bash
obsidian-cli frontmatter "My Note" --delete --key "draft"
```

For bulk frontmatter operations across many notes, read files directly with `Read` and edit with `Edit` — it's more efficient than calling obsidian-cli per note.

### Daily Notes

```bash
obsidian-cli daily
```

Creates today's daily note if it doesn't exist, then opens it in Obsidian.

### Listing vault structure

```bash
# List root of vault
obsidian-cli list

# List a specific folder
obsidian-cli list "Projects"
```

### Deleting notes

```bash
obsidian-cli delete "Folder/note-to-delete"
```

## Multi-Vault Usage

All obsidian-cli commands accept `--vault <name>` to target a specific vault:

```bash
obsidian-cli search "query" --vault "Work"
obsidian-cli create "Note" --content "..." --vault "Personal"
```

## Vault Structure (typical)

```
My Vault/
├── .obsidian/          # Config + plugin settings (don't modify from scripts)
├── Daily Notes/        # Daily journal entries
├── Projects/           # Project-specific notes
├── Templates/          # Note templates
├── Attachments/        # Images, PDFs, etc.
└── *.md                # Individual notes
```

- Notes are plain `.md` files — any editor can read/write them
- `.obsidian/` contains workspace and plugin config — avoid modifying it
- `*.canvas` files are JSON-based Obsidian Canvas documents
- Attachments folder location is configured in Obsidian settings

## Common Patterns

### Batch operations on notes

When you need to update many notes (e.g., add a tag, fix links, update frontmatter), use `Glob` to find files, then `Read` + `Edit` for each — it's faster and more reliable than calling obsidian-cli repeatedly.

### Creating linked notes

When creating a set of related notes, use `Write` to create files and include `[[wikilinks]]` in the content. Obsidian will resolve the links automatically when the vault is opened.

### Template-based creation

If the vault has a Templates folder, read the template with `Read`, substitute placeholders, then write the new note with `Write`.

## Obsidian Headless (`ob`)

Obsidian Headless is a standalone CLI client for Obsidian Sync — no desktop app required. Useful for CI/CD, servers, automated backups, and agentic workflows.

> **Headless vs obsidian-cli**: `obsidian-cli` controls the Obsidian desktop app from the terminal. `ob` (Obsidian Headless) is an independent client that syncs vaults without the desktop app.

### Install

Requires Node.js 22+:

```bash
npm install -g obsidian-headless
```

### Authentication

```bash
ob login                                    # Interactive login
ob login --email user@example.com           # Non-interactive
ob login --email user@example.com --password "..." --mfa 123456
ob logout                                   # Clear credentials
```

### Vault Sync

```bash
# List available vaults
ob sync-list-remote                         # Remote vaults on Obsidian Sync
ob sync-list-local                          # Locally configured vaults

# Setup sync
ob sync-create-remote --name "My Vault"     # Create new remote vault
ob sync-setup --path /path/to/vault         # Link local path to remote vault
ob sync-config                              # Change sync configuration

# Sync operations
ob sync                                     # Sync the vault
ob sync-status                              # Show sync status (pending changes)
ob sync-unlink                              # Disconnect vault from sync
```

### When to use Headless

- **Automated backups**: sync vault on a schedule (cron, CI)
- **Agentic access**: give Claude Code access to a vault on a remote server
- **Team workflows**: sync shared vault to a server that feeds other tools
- **Scheduled automations**: aggregate daily notes, auto-tag, generate summaries

### Headless + Claude Code workflow

1. `ob sync` to pull latest vault changes
2. Use `Read`/`Edit`/`Write` tools to work with notes directly
3. `ob sync` to push changes back

This is especially useful on servers or in CI where Obsidian desktop isn't installed.

## CLI Reference

For detailed flag options, see [`references/commands.md`](references/commands.md).
