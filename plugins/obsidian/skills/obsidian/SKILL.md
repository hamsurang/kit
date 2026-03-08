---
name: obsidian
description: >
  Use when the user mentions Obsidian, vault, daily notes, wikilinks,
  frontmatter, backlinks, graph view, PKM, Zettelkasten, or obsidian-cli.
  Activates for searching, creating, editing, moving notes in an Obsidian
  vault, managing YAML frontmatter, or syncing vaults via Obsidian Headless
  (ob CLI). Also trigger on Korean phrases like "내 노트에서 찾아줘" or
  "vault 동기화". Do NOT trigger for generic Markdown editing (README, docs)
  or other note apps (Notion, Bear).
---

# Obsidian Vault Skill

## Contents

- [Tool Selection Guide](#tool-selection-guide)
- [Find the Vault](#find-the-vault)
- [Working with Notes](#working-with-notes)
- [Multi-Vault Usage](#multi-vault-usage)
- [Common Patterns](#common-patterns)
- [When NOT to Use](#when-not-to-use)
- [Error Handling](#error-handling)
- [Obsidian Headless](#obsidian-headless)
- [CLI Reference](#cli-reference)

Obsidian vault = a normal folder of Markdown files on disk. Use `obsidian-cli` only when its features add real value (search, link-aware move/rename, frontmatter ops, opening in Obsidian).

## Tool Selection Guide

| Task | Best tool |
|------|-----------|
| Read note content | `Read` tool |
| Edit note content | `Edit` tool |
| Create new note | `Write` tool |
| Create note + open in Obsidian | `obsidian-cli create --open` |
| Search note names | `obsidian-cli search "query"` |
| Search inside notes | `obsidian-cli search-content "query"` |
| Broad content search / regex | `Grep` tool on vault path |
| Find notes by name pattern | `Glob` tool on vault path |
| Move/rename note (updates wikilinks) | `obsidian-cli move` |
| View/edit frontmatter | `obsidian-cli frontmatter` |
| Open daily note | `obsidian-cli daily` |
| List vault contents | `obsidian-cli list` |
| Delete note | `obsidian-cli delete` |
| Sync vault (no desktop) | `ob sync` |

## Find the Vault

Never hardcode paths. Resolve the vault path first:

```bash
obsidian-cli print-default --path-only   # if default vault is set
cat ~/Library/Application\ Support/obsidian/obsidian.json  # otherwise
```

The config JSON has a `vaults` object; use the entry with `"open": true`. If multiple vaults exist, ask the user which to use, then: `obsidian-cli set-default "<vault-folder-name>"`

## Working with Notes

**Read**: Use `Read` tool on the `.md` file directly. For backlink context: `obsidian-cli print "Note" --mentions`

**Create**: Use `Write` tool for simple creation. To also open in Obsidian: `obsidian-cli create "Folder/Note" --content "..." --open`. To append: add `--append`.

**Edit**: Use `Edit` tool — precise diffs, preserves formatting. Prefer over obsidian-cli for content changes.

**Search by name**: `obsidian-cli search "query"` — fuzzy match across vault.
**Search content**: `obsidian-cli search-content "query"` — snippets + line numbers.
**Regex search**: Use `Grep` on vault path (faster, supports regex).
**Filename pattern**: Use `Glob` on vault path (e.g., `**/daily/**/*.md`).

**Move/rename**: Always use `obsidian-cli move "Old/note" "New/note"` — updates `[[wikilinks]]` across vault. Plain `mv` cannot do this.

**Frontmatter**:
```bash
obsidian-cli frontmatter "Note" --print
obsidian-cli frontmatter "Note" --edit --key "status" --value "done"
obsidian-cli frontmatter "Note" --delete --key "draft"
```
For bulk frontmatter ops across many notes, use `Read` + `Edit` directly — more efficient.

**Daily note**: `obsidian-cli daily` — creates if needed, opens in Obsidian.

**List vault**: `obsidian-cli list` or `obsidian-cli list "Projects"` for a subfolder.

**Delete**: `obsidian-cli delete "Folder/note-to-delete"`

## Multi-Vault Usage

All obsidian-cli commands accept `--vault <name>`:

```bash
obsidian-cli search "query" --vault "Work"
obsidian-cli create "Note" --content "..." --vault "Personal"
```

## Common Patterns

**Batch note updates**: Use `Glob` to find files, then `Read` + `Edit` per file — faster than calling obsidian-cli repeatedly.

**Linked notes**: Use `Write` with `[[wikilinks]]` in content; Obsidian resolves them on open.

**Template-based creation**: `Read` the template, substitute placeholders, `Write` the new note.

## When NOT to Use

- Generic Markdown editing (README.md, CHANGELOG.md, docs/) — use Read/Edit tools directly
- Other note-taking apps (Notion, Bear, Apple Notes) — this skill is Obsidian-specific
- Code documentation or inline comments

## Error Handling

If `obsidian-cli` is not installed:
- Fall back to direct file operations: use Glob to find notes, Read/Edit/Write to modify them
- Wikilink-aware move/rename won't work without obsidian-cli — warn the user

OS-specific Obsidian config paths:
- **macOS**: `~/Library/Application Support/obsidian/obsidian.json`
- **Linux**: `~/.config/obsidian/obsidian.json`
- **Windows**: `%APPDATA%/obsidian/obsidian.json`

## Obsidian Headless

For headless sync (CI/servers), see the Headless section in `references/commands.md`.

## CLI Reference

For detailed flag options, see [`references/commands.md`](references/commands.md).

## References Loading Guide

| Situation | Load |
|-----------|------|
| CLI command options, headless usage | `references/commands.md` |
