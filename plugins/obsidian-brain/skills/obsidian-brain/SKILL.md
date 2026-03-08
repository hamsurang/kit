---
name: obsidian-brain
description: >
  Use when the user explicitly requests their personal vault notes as
  conversational context. Activates on "이전에 정리한 거 있어?",
  "내 노트 참고해서 답해줘", "check my notes about", "I wrote something
  about this before", "what do my notes say about". Do NOT trigger for
  vault management (creating, moving, editing, searching notes) — those
  belong to the obsidian skill. Do NOT trigger for generic Obsidian or
  Zettelkasten questions.
---

# Obsidian Brain — Vault Knowledge as Context

Use vault notes as conversational context and archive session learnings as Zettelkasten notes.

## Skill Boundary

| Intent | Skill |
|--------|-------|
| Create, edit, move, search notes | `obsidian` |
| Use vault knowledge as context | `obsidian-brain` ✅ |
| Archive session learnings | `/obsidian-archive` command |
| Explicitly load vault context | `/brain` command |

## Vault Path Resolution

Resolve once per session, cache for reuse:

1. **User override**: `~/.claude/obsidian-brain/config.json` → `vaultPath`
2. **obsidian-cli**: `obsidian-cli print-default --path-only`
3. **Obsidian app config**: `~/Library/Application Support/obsidian/obsidian.json`
4. **Ask user**: "Obsidian vault 경로를 알려주세요"

If vault path is invalid, clear config and re-resolve. See `references/vault-setup.md` for details.

## Context Loading Workflow

When the user asks to reference their notes:

1. **Parse query** — extract topic keywords from the user's request
2. **MOC scan** — Grep `2-maps/*.md` for keywords, read top 3 matching MOCs
3. **Note retrieval** — extract `[[wikilinks]]` from MOCs, read up to 5 linked notes
4. **Fallback search** — if MOC scan finds nothing, Grep `1-zettelkasten/` and `0-inbox/` directly for keywords (catches orphan notes not linked to any MOC)
5. **Context budget** — stay within 15,000 characters total:
   - 3 MOCs × ~1,000 chars = ~3,000
   - 5 notes × ~2,000 chars = ~10,000
   - Remaining ~2,000 for relationship context
6. **Present** — summarize what was found, answer the user's question using note content

### If No Notes Found

```
이 주제에 대한 노트를 찾지 못했습니다.
관련 키워드: [searched terms]
```

### Cold Start (Empty Vault)

If `2-maps/` is empty or missing, inform the user:
```
vault에 아직 노트가 없습니다. /obsidian-archive 로 학습 내용을 저장해보세요.
```

## Archive Workflow

The `/obsidian-archive` command handles learning extraction. It follows:

1. **Session analysis** — Progressive Summarization으로 학습 추출
2. **MOC scan** — 기존 노트와 관련성 검색
3. **Duplicate detection** — 중복 노트 확인
4. **Draft generation** — 사용자 승인/수정 루프
5. **Save** — `0-inbox/`에 저장, MOC 업데이트

Full workflow details in `references/archive-workflow.md`.
Note and MOC templates in `references/templates.md`.

## Iron Rules

1. **Never auto-save** — always present drafts for user approval
2. **Respect context budget** — never exceed 15,000 chars in MOC scan
3. **Atomic notes only** — one idea per note, declarative English title
4. **Korean content** — note body is always in Korean
5. **No forced archival** — if no learnings found, say so honestly
6. **Vault path first** — resolve vault path before any file operation
7. **Grep over glob** — use Grep to search inside MOCs, not read-all

## References Loading Guide

| Situation | Load |
|-----------|------|
| First run, vault setup needed | `references/vault-setup.md` |
| Creating notes or MOCs | `references/templates.md` |
| Running /obsidian-archive | `references/archive-workflow.md` |
