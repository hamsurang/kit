# obsidian-cli Command Reference

Install: `brew install yakitrak/yakitrak/obsidian-cli`

All commands accept `--vault <name>` to target a specific vault. If omitted, uses the default vault set via `set-default`.

---

## set-default / sd

Set the default vault so you don't need `--vault` on every command.

```bash
obsidian-cli set-default "<vault-folder-name>"
```

## print-default

Show the default vault name and path.

```bash
obsidian-cli print-default              # name + path
obsidian-cli print-default --path-only  # path only (for scripting)
```

## search / s

Fuzzy search notes by name.

```bash
obsidian-cli search "query"
obsidian-cli search "query" --vault "Work"
obsidian-cli search "query" --editor     # open in $EDITOR instead of Obsidian
```

## search-content / sc

Search inside note content. Returns matching snippets with line numbers.

```bash
obsidian-cli search-content "query"
obsidian-cli search-content "query" --vault "Work"
obsidian-cli search-content "query" --editor
```

## create / c

Create a new note. Note path is relative to vault root, without `.md` extension.

```bash
obsidian-cli create "Folder/Note Name" --content "# Title\n\nBody"
obsidian-cli create "Folder/Note Name" --content "text" --open       # open in Obsidian
obsidian-cli create "Folder/Note Name" --content "text" --append     # append to existing
obsidian-cli create "Folder/Note Name" --content "text" --overwrite  # overwrite existing
obsidian-cli create "Note" --content "text" --open --editor          # open in $EDITOR
```

| Flag | Description |
|------|-------------|
| `-c, --content` | Text content for the note |
| `--open` | Open note after creation |
| `-a, --append` | Append to existing note |
| `-o, --overwrite` | Overwrite existing note |
| `-e, --editor` | Open in $EDITOR (requires `--open`) |

## daily / d

Create or open today's daily note.

```bash
obsidian-cli daily
obsidian-cli daily --vault "Personal"
```

## open / o

Open a note in Obsidian by name.

```bash
obsidian-cli open "Folder/Note Name"
obsidian-cli open "Note" --section "Heading Text"   # jump to heading
```

| Flag | Description |
|------|-------------|
| `-s, --section` | Heading text to jump to (case-sensitive) |

## print / p

Print note contents to stdout.

```bash
obsidian-cli print "Folder/Note Name"
obsidian-cli print "Note" --mentions    # include backlinks at end
```

| Flag | Description |
|------|-------------|
| `-m, --mentions` | Include linked mentions |

## list / ls

List files and folders in vault.

```bash
obsidian-cli list                  # vault root
obsidian-cli list "Projects"       # specific folder
```

## move / m

Move or rename a note. Updates `[[wikilinks]]` and Markdown links across the vault.

```bash
obsidian-cli move "Old/Path/Note" "New/Path/Note"
obsidian-cli move "Old Name" "New Name"              # rename in place
obsidian-cli move "Old" "New" --open                  # open after move
```

| Flag | Description |
|------|-------------|
| `-o, --open` | Open note after moving |
| `-e, --editor` | Open in $EDITOR (requires `--open`) |

## delete

Delete a note from the vault.

```bash
obsidian-cli delete "Folder/Note Name"
```

## frontmatter / fm

View or modify YAML frontmatter in a note.

```bash
# View
obsidian-cli frontmatter "Note" --print

# Edit a key
obsidian-cli frontmatter "Note" --edit --key "status" --value "done"

# Delete a key
obsidian-cli frontmatter "Note" --delete --key "draft"
```

| Flag | Description |
|------|-------------|
| `-p, --print` | Print frontmatter |
| `-e, --edit` | Edit a key (requires `--key` and `--value`) |
| `-d, --delete` | Delete a key (requires `--key`) |
| `-k, --key` | Frontmatter key name |
| `--value` | Value to set |

## completion

Generate shell autocompletion scripts.

```bash
obsidian-cli completion bash
obsidian-cli completion zsh
obsidian-cli completion fish
```

---

# Obsidian Headless (`ob`) Command Reference

Install: `npm install -g obsidian-headless` | Requires: Node.js 22+

Obsidian Headless is a standalone CLI for Obsidian Sync — syncs vaults without the desktop app.

## login

Log in to Obsidian account. Running without flags triggers interactive prompts.

```bash
ob login
ob login --email user@example.com
ob login --email user@example.com --password "pass" --mfa 123456
```

| Flag | Description |
|------|-------------|
| `--email <email>` | Account email |
| `--password <password>` | Account password |
| `--mfa <code>` | Two-factor auth code |

## logout

Clear stored credentials.

```bash
ob logout
```

## sync-list-remote

List available remote vaults on Obsidian Sync.

```bash
ob sync-list-remote
```

## sync-list-local

List locally configured vaults.

```bash
ob sync-list-local
```

## sync-create-remote

Create a new remote vault.

```bash
ob sync-create-remote --name "My Vault"
```

| Flag | Description |
|------|-------------|
| `--name <name>` | Name for the new remote vault |

## sync-setup

Link a local path to a remote vault for syncing.

```bash
ob sync-setup --path /path/to/vault
```

| Flag | Description |
|------|-------------|
| `--path <path>` | Local vault path |

## sync-config

Change sync configuration for a vault.

```bash
ob sync-config
```

## sync-status

Show sync status for a vault (pending changes, last sync time).

```bash
ob sync-status
```

## sync

Sync a vault. Pulls remote changes and pushes local changes.

```bash
ob sync
```

## sync-unlink

Disconnect a vault from sync and remove stored credentials.

```bash
ob sync-unlink
```
