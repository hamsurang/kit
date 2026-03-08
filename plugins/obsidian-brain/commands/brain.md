---
name: brain
description: >
  Explicitly load Obsidian vault knowledge into the current conversation
  context. Use when the user wants to reference their personal notes
  about a specific topic.
args: "[topic]"
---

# /brain — Load Vault Knowledge

Load notes from Obsidian vault as conversational context.

## Usage

```
/brain rust ownership
/brain react hooks
/brain 이전에 정리한 캐싱 전략
```

## Prerequisites

1. Load `references/vault-setup.md` and resolve vault path
2. Verify vault structure exists

## Execution

1. **Parse topic** — extract keywords from the argument (or ask if empty)
2. **MOC scan** — Grep `2-maps/*.md` for topic keywords
3. **Read top 3 MOCs** — extract `[[wikilinks]]` from matching MOCs
4. **Read up to 5 linked notes** — prioritize most relevant by keyword match
5. **Fallback search** — if no MOCs matched, Grep `1-zettelkasten/` and `0-inbox/` directly for keywords to find orphan notes not yet linked to any MOC
6. **Context budget** — stay within 15,000 characters total
7. **Present findings** — summarize loaded notes and answer in context

## Output Format

```
vault에서 [N]개 노트를 찾았습니다:
  - [[note-1-title]] (from MOC: topic-name)
  - [[note-2-title]] (from MOC: topic-name)

[Answer the user's question using the loaded note content]
```

## No Results

```
"[topic]"에 대한 노트를 찾지 못했습니다.
검색한 키워드: [terms]
```
