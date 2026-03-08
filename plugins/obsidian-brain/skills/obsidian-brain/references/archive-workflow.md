# Archive Workflow Reference

Load this reference when running `/obsidian-archive` to extract and save learnings.

## Step 1: Session Analysis — Learning Extraction

Apply Progressive Summarization to extract learnings from the current conversation:

1. **Scan**: Identify conversation segments where learning occurred (not operational segments like "rename this file")
2. **Extract**: From each segment, identify the core insight or concept
3. **Atomize**: Can each insight be expressed as a single declarative title? If not, split further

### What Qualifies as a Learning

Extract these knowledge atom types:

| Type | Description | Example |
|------|-------------|---------|
| **Concept** | New term or idea with defined boundaries | "useTransition is a hook for concurrent rendering" |
| **Pattern** | Reusable cause-solution discovered during debugging | "N+1 queries solved by eager loading with includes" |
| **Model** | Relationship between entities | "Ownership is prerequisite for understanding Borrowing" |
| **Observation** | Confirmed behavior of a library/framework | "Next.js App Router caches fetch by default" |

### What to Exclude

- Simple file operations (rename, move, delete)
- Configuration changes (env vars, settings)
- Repetitive tasks the user already knows
- Operational commands (git, npm, docker) unless a new pattern was discovered

### No Learnings Found

If the session contains no extractable learnings, respond:
"이 세션에서 아카이빙할 학습 내용을 찾지 못했습니다."

Do not force creation of low-quality notes.

## Step 2: MOC Scan — Find Related Notes

**Context budget: 15,000 characters total**

```
1. Use Grep to search inside 2-maps/*.md for the topic keywords
   - Grep pattern: key terms from the extracted learnings
   - This scales to thousands of MOCs (no need to read all)

2. Read the top 3 most relevant MOCs fully (~1,000 chars × 3 = ~3,000 chars)

3. Extract [[wikilink]] references from those MOCs

4. Read up to 5 linked notes (max 2,000 chars per note = ~10,000 chars)

5. Remaining budget ~2,000 chars for relationship judgment
```

If no MOCs exist (empty vault / cold start): skip this step entirely.

## Step 3: Duplicate Detection

Before generating drafts, check for existing notes that cover the same concept:

1. Use Grep to search `0-inbox/` and `1-zettelkasten/` for:
   - The proposed note title (or key phrases from it)
   - Core technical terms from the extracted learning
2. If a similar note is found, present options:

```
유사한 노트가 이미 있습니다:
  [[20260308-rust-ownership-ensures-memory-safety]]

어떻게 할까요?
1. 병합 — 기존 노트에 새 내용 추가
2. 별도 생성 — 새 노트를 만들고 기존 노트와 연결
3. 건너뛰기 — 이 학습은 아카이빙하지 않음
```

## Step 4: Draft Generation

For each extracted learning, generate a draft using the zettel template (see `references/templates.md`).

### Draft Presentation Format

**Single note:**
```
아카이빙 드래프트

제목: useTransition defers low-priority state updates
태그: #react, #hooks, #concurrent-rendering
연결:
  - [[20260309-react-hooks-overview]] — extends
  - [[20260308-concurrent-mode]] — related (concurrent rendering의 핵심 hook)

---
useTransition은 React의 concurrent rendering에서 낮은 우선순위의 상태
업데이트를 처리하기 위한 hook이다...
---

승인 / 수정 / 거절
```

**Multiple notes (batch):**
Present each note with a number, then offer "모두 승인" option:
```
3개의 노트를 생성하겠습니다:

[1/3] Rust lifetimes ensure references never outlive their data
      태그: #rust, #lifetimes, #memory-safety
      연결: [[20260308-rust-ownership]] — prerequisite

[2/3] Lifetime elision rules reduce annotation burden
      태그: #rust, #lifetimes, #compiler
      연결: [1/3] — extends

[3/3] Static lifetime means the reference lives for the entire program
      태그: #rust, #lifetimes, #static
      연결: [1/3] — extends

모두 승인 / 개별 검토 / 모두 거절
```

### Modification Loop

When user requests changes:
- "제목 바꿔줘" → regenerate title
- "태그 추가해줘" → add tags
- "연결 제거해줘" → remove wikilink
- "내용 수정해줘" → edit content
- For batch: "2번 수정" → modify only note #2

Re-present the modified draft for approval.

## Step 5: Save and Update MOC

After user approves:

1. **Save note** to `0-inbox/` — always `0-inbox/`, never directly to `1-zettelkasten/`
   - `1-zettelkasten/` is for reviewed notes that the user has manually promoted
   - Use Write tool to create the file
   - Verify the file was created successfully

2. **Update related MOC** — if a relevant MOC was found in Step 2:
   - Use Edit tool to append the new note's wikilink to the MOC's `## Notes` section
   - Format: `- [[filename]] — brief one-line description`

3. **Create new MOC** — if no relevant MOC exists:
   - Propose: "이 주제에 대한 MOC를 만들까요?"
   - If approved, create MOC in `2-maps/` using the MOC template
   - Add the new note's wikilink to the MOC

4. **MOC size check** — if the updated MOC has more than 25 items:
   - Suggest splitting: "이 MOC에 항목이 25개를 넘었습니다. 하위 MOC로 분리할까요?"

5. **Confirmation**:
```
저장 완료!
  파일: 0-inbox/20260309143022-usetransition-defers-low-priority-updates.md
  MOC 업데이트: 2-maps/react-hooks.md
```
