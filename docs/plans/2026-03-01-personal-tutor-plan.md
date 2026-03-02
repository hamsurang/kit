# Personal Tutor Skill — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a `personal-tutor` Claude Code skill that acts as an adaptive technical tutor, building a persistent knowledge graph and learner profile across sessions.

**Architecture:** A skill document (`SKILL.md`) that guides Claude through 5 phases: Socratic diagnostic, agenda planning, teaching, verification quiz, and archiving. State persists via markdown files in `~/.claude/learning/`. A supporting template file defines the knowledge graph format.

**Tech Stack:** Markdown skill files, `~/.claude/skills/` directory (Claude Code personal skills)

**Design Reference:** `docs/plans/2026-03-01-personal-tutor-design.md`

---

## Task 1: Create Skill Directory Structure

**Files:**
- Create: `~/.claude/skills/personal-tutor/` (directory)
- Create: `~/.claude/skills/personal-tutor/SKILL.md`
- Create: `~/.claude/skills/personal-tutor/knowledge-graph-template.md`

**Step 1: Create the directory**

```bash
mkdir -p ~/.claude/skills/personal-tutor
```

**Step 2: Verify it exists**

```bash
ls ~/.claude/skills/
```

Expected: `personal-tutor/` directory listed

**Step 3: Commit**

```bash
git add .  # nothing to add yet — directories don't track until files exist
```

(Files added in subsequent tasks)

---

## Task 2: Write `knowledge-graph-template.md`

**Files:**
- Create: `~/.claude/skills/personal-tutor/knowledge-graph-template.md`

**Step 1: Write the template**

Content for `~/.claude/skills/personal-tutor/knowledge-graph-template.md`:

```markdown
# {Topic} Knowledge Graph

Reference: none

## Nodes

### {Concept Name}
- Status: gap
- Depth: -
- Prerequisites: []
- Quiz history: []
```

**Upgrade rules:**
- `gap → partial`: quiz passed this session (hint OK)
- `partial → understood`: quiz passed in a later session WITHOUT hints

**Depth scale (Bloom's Taxonomy):**
- `recall` — can remember / repeat
- `apply` — can use in new context
- `explain` — can teach to someone else

---

**Step 2: Verify file contents look correct**

```bash
cat ~/.claude/skills/personal-tutor/knowledge-graph-template.md
```

---

## Task 3: Write Core `SKILL.md`

**Files:**
- Create: `~/.claude/skills/personal-tutor/SKILL.md`

**Step 1: Write SKILL.md**

Content for `~/.claude/skills/personal-tutor/SKILL.md`:

```markdown
---
name: personal-tutor
description: Use when user wants to learn a technical topic, says "I want to learn X", "teach me X", or "let's study X". Also use when user resumes a previous learning session on a topic they've studied before.
---

# Personal Tutor

## Session Start

1. Extract topic name from user input (e.g., "Rust", "TypeScript generics")
2. Check `~/.claude/learning/topics/{topic}/knowledge-graph.md`
   - **Exists** → load it + `~/.claude/learning/learner-profile.md` → jump to **Phase 2**
   - **Not exists** → create `~/.claude/learning/topics/{topic}/` → start **Phase 1**

## Phase 1: Socratic Diagnostic (first session only)

Ask 5–7 open-ended questions to map existing knowledge. One question at a time. Examples:
- "Have you worked with manual memory management before? (C, C++, etc.)"
- "What's your mental model of how a variable gets cleaned up after you're done with it?"
- "Have you seen ownership errors before? What did they look like?"

After mapping, ask once: **"Is there a reference you'd like me to draw from? (book, docs, course — optional)"**
- Yes → store in `knowledge-graph.md` header as `Reference: [title + URL]`; use for examples and citations only — Claude leads curriculum
- No → set `Reference: none`

Create `knowledge-graph.md` using `knowledge-graph-template.md`. Seed nodes based on the topic's prerequisite tree. All nodes start as `gap`.

## Phase 2: Agenda Planning

Session composition (respect Cognitive Load Theory):
- **New concepts: 1–2** — `gap` nodes whose prerequisites are ALL ≥ `partial`
- **Review: 1** — the oldest `partial` node (skip if none)

If `learner-profile.md` exists, read it and adjust approach before Phase 3:
- Match preferred learning direction (bottom-up vs top-down)
- Anticipate known weak areas
- Use what's worked before (analogies, code-first, etc.)

Announce the agenda to the user before starting.

## Phase 3: Teaching

Loop for each concept in agenda:
1. Explain concept
2. Socratic Q&A — ask questions to deepen understanding, don't just lecture
3. Check: "Does this make sense? Any questions?"

If stuck or confused:
- Try a different angle: analogy → code example → reverse question ("What would break if this rule didn't exist?")
- Reference material role: cite for examples or further reading only
  - "The Rust Book ch.4 has a great example of this"
  - "If you want to go deeper, check [reference ch.X]"
- Do NOT follow reference material's order — Claude leads curriculum

## Phase 4: Verification Quiz

Run one quiz per new concept taught. Do NOT skip. Rotate formats:

| Format | Prompt style | Tests |
|--------|-------------|-------|
| **Feynman** | "Explain this to me like I'm 5" | Internalization |
| **Apply** | "What's wrong with this code?" + [code snippet] | Application |
| **Analyze** | "Why was this designed this way?" | Deep understanding |

**Track hint usage:** Did you give any hints during the quiz? Note it.
- No hints → record `passed (no hint)`
- Hints given → record `passed (hint used)`

## Phase 5: Archive

Run this phase at the end of every session. Do not skip even if session is short.

**Step 1: Update node states in `knowledge-graph.md`**

Upgrade rules:
- `gap → partial`: passed quiz this session (hint OK)
- `partial → understood`: node was already `partial` from a prior session AND passed quiz today WITHOUT hints

Never downgrade a node. If quiz failed, add note to quiz history only.

**Step 2: Write session log**

Create `~/.claude/learning/topics/{topic}/sessions/YYYY-MM-DD-session-N.md`:

```
# {Topic} — Session {N} — {Date}

## Agenda
- New: [concepts]
- Review: [concept]

## Teaching Notes
[Brief per-concept notes — what worked, what didn't]

## Quiz Results
- {Concept}: passed (no hint) → upgraded to understood
- {Concept}: passed (hint used) → gap→partial

## Observations
[Pattern observations to propose to user]
```

**Step 3: Present observations + confirm before saving**

Say: "I noticed [specific pattern, e.g., 'you clicked quickly when I used the C++ analogy, and got stuck when I used abstract notation']. Want me to save this to your learner profile?"

Wait for explicit confirmation. Then update `~/.claude/learning/learner-profile.md`:

```markdown
# Learner Profile

## Learning Patterns
- Responds well to: [...]
- Struggles with: [...]
- Learning direction: bottom-up | top-down

## Observed Weakness Patterns
- [category]: [specific observation]

## Topic History
- {topic}: {N} sessions ({Concept} ✓|⚠|✗, ...)
```

## Iron Rules

These rules are non-negotiable. Do not skip them under any circumstances.

1. **Never end a session without a quiz** — Retrieval Practice is the core of retention
2. **Never teach a node whose prerequisites aren't ≥ partial** — teaching without foundations wastes both parties' time
3. **Never write to `learner-profile.md` without explicit user confirmation** — accuracy matters more than automation
4. **Never skip Phase 5** — even if the session runs long, archive before closing
5. **Never teach more than 2 new concepts per session** — cognitive overload defeats learning
```

**Step 2: Verify character count of frontmatter description**

```bash
echo -n "Use when user wants to learn a technical topic, says \"I want to learn X\", \"teach me X\", or \"let's study X\". Also use when user resumes a previous learning session on a topic they've studied before." | wc -c
```

Expected: under 1024 characters

**Step 3: Commit**

```bash
git add ~/.claude/skills/personal-tutor/
git commit -m "feat: add personal-tutor skill (SKILL.md + template)"
```

---

## Task 4: Run Baseline Test (RED — without skill)

**Purpose:** Verify the skill is needed — see how Claude behaves without it.

**Step 1: Write a pressure scenario prompt**

Create a temporary file `~/.claude/skills/personal-tutor/test-baseline.md`:

```markdown
# Baseline Test Scenario

You are helping a user learn Rust. They say:
"I want to learn Rust. I've done some Python before."

Instructions:
- Help them start learning Rust
- You have no special instructions or skills loaded

Observation goals:
- Does Claude run a structured diagnostic before teaching?
- Does Claude teach more than 2 concepts at once?
- Does Claude quiz the user before ending?
- Does Claude create any files to track progress?
- Does Claude ask about reference materials?
```

**Step 2: Run the baseline via subagent**

Spawn a fresh subagent with the scenario (without personal-tutor skill loaded). Document:
- Did it follow any structured phases? (likely no)
- Did it quiz the user? (likely no or ad hoc)
- Did it track anything? (likely no)
- How many concepts did it try to cover? (likely too many)

Record the verbatim behavior.

**Step 3: Document baseline failures**

Note specific gaps to verify the skill addresses them.

---

## Task 5: Run Skill Test (GREEN — with skill)

**Step 1: Use same scenario with skill loaded**

Run the same pressure scenario but now the subagent has `personal-tutor` skill available.

Verify:
- [ ] Claude starts with Socratic diagnostic (Phase 1)
- [ ] Claude asks about reference material once
- [ ] Claude announces agenda (Phase 2)
- [ ] Claude limits new concepts to 1–2 (Phase 3)
- [ ] Claude runs a quiz using one of the 3 formats (Phase 4)
- [ ] Claude proposes archiving observations for confirmation (Phase 5)
- [ ] Claude does NOT write to learner-profile without confirmation

**Step 2: If any check fails**

Identify the gap in SKILL.md and patch it. Re-run the test.

**Step 3: Commit final skill**

```bash
git add ~/.claude/skills/personal-tutor/
git commit -m "fix: tighten personal-tutor skill based on test results"
```

---

## Task 6: Create Initial Learning Directory Structure (optional smoke test)

**Step 1: Run a real mini-session manually**

Invoke the skill yourself with a topic (e.g., "I want to learn Rust ownership").

Verify that:
- `~/.claude/learning/topics/rust/knowledge-graph.md` gets created
- `~/.claude/learning/topics/rust/sessions/` gets created
- `~/.claude/learning/learner-profile.md` only gets written after your confirmation

**Step 2: Inspect the created files**

```bash
cat ~/.claude/learning/topics/rust/knowledge-graph.md
```

Confirm the format matches the design spec.

**Step 3: Final commit**

```bash
git add docs/plans/2026-03-01-personal-tutor-plan.md
git commit -m "docs: add personal-tutor implementation plan"
```

---

## Completion Criteria

- [ ] `~/.claude/skills/personal-tutor/SKILL.md` exists and follows spec
- [ ] `~/.claude/skills/personal-tutor/knowledge-graph-template.md` exists
- [ ] Baseline test documents Claude behavior without skill (RED)
- [ ] Skill test passes all 7 checks (GREEN)
- [ ] Real mini-session produces correct file structure
- [ ] `learner-profile.md` only written after explicit user confirmation
