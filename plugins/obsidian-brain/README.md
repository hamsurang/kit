# obsidian-brain

Archive learnings from Claude Code sessions to Obsidian vault as Zettelkasten notes and use vault knowledge as conversational context.

## Install

```bash
claude install-plugin hamsurang/kit --plugin obsidian-brain
```

## Features

### `/obsidian-archive` — Session Learning Archival

Extract learnings from the current conversation and save them as atomic Zettelkasten notes.

```
/obsidian-archive
```

- Scans conversation for concepts, patterns, models, and observations
- Checks for duplicate notes before creating
- Presents drafts for approval — never auto-saves
- Saves to `0-inbox/` and updates MOC in `2-maps/`

### `/brain` — Load Vault Knowledge

Load notes from your vault into the current conversation context.

```
/brain rust ownership
/brain react hooks
```

- Searches MOCs by topic keywords
- Reads up to 5 linked notes within a 15,000 char budget
- Answers questions using your personal knowledge base

### Auto-invoked Skill

The `obsidian-brain` skill auto-activates when you reference your notes:

- "내 노트 참고해서 답해줘"
- "이전에 정리한 거 있어?"
- "check my notes about X"

## Vault Structure

```
vault/
├── 0-inbox/          # New notes land here
├── 1-zettelkasten/   # Reviewed atomic notes
├── 2-maps/           # MOC (Map of Contents) index notes
└── templates/        # Note templates
```

On first run, the plugin offers to create missing directories.

## Note Format

Notes use Zettelkasten conventions:

- **Title**: Declarative English phrase (e.g., "useTransition defers low-priority state updates")
- **Tags**: English, lowercase
- **Content**: Korean
- **Filename**: `YYYYMMDDHHmmss-kebab-title.md`

## Requirements

- [obsidian-cli](https://github.com/minsoo-web/obsidian-cli) (recommended for vault path resolution)
- An Obsidian vault

## Companion Plugin

Use with the [obsidian](../obsidian) plugin for vault CRUD operations (create, edit, move, search notes).
