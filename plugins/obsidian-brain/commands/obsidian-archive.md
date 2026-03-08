---
name: obsidian-archive
description: >
  Extract learnings from the current Claude Code session and archive them
  as Zettelkasten notes in Obsidian vault. Use when the user wants to save
  what they learned during a coding session.
---

# /obsidian-archive — Session Learning Archival

Archive learnings from the current conversation to Obsidian vault.

## Prerequisites

1. Load `references/vault-setup.md` and resolve vault path
2. Verify vault structure exists (create if needed with user approval)

## Execution

Load `references/archive-workflow.md` and follow steps 1–5:

1. **Session Analysis** — scan conversation for learnings using Progressive Summarization
2. **MOC Scan** — Grep `2-maps/*.md` for related topics (15,000 char budget)
3. **Duplicate Detection** — check `0-inbox/` and `1-zettelkasten/` for existing notes
4. **Draft Generation** — present drafts for user approval (load `references/templates.md`)
5. **Save & Update MOC** — write to `0-inbox/`, update or create MOC in `2-maps/`

## Important

- Never auto-save — always get user approval first
- If no learnings found, say: "이 세션에서 아카이빙할 학습 내용을 찾지 못했습니다."
- Support modification loop: user can edit title, tags, connections, content before saving
