---
name: personal-tutor
description: Use when user wants to learn a technical topic, says "I want to learn X", "teach me X", or "let's study X". Also use when user resumes a previous learning session on a topic they've studied before.
---

# Personal Tutor

**Sections:** [Session Start](#session-start) · [Phase 1: Diagnostic](#phase-1-socratic-diagnostic-first-session-only) · [Phase 2: Agenda](#phase-2-agenda-planning) · [Phase 3: Teaching](#phase-3-teaching) · [Phase 4: Quiz](#phase-4-verification-quiz) · [Phase 5: Archive](#phase-5-archive) · [Iron Rules](#iron-rules)

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
- **Staleness check**: if an `understood` node's last quiz was 30+ days ago, add it to the review slot

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

Never downgrade a node. If quiz failed: add note to quiz history AND flag concept in learner-profile as "needs reinforcement" (propose this to user in Step 3).

Depth progression (update when quiz demonstrates deeper mastery):
- Quiz format was Feynman and passed → depth moves toward `explain`
- Quiz format was Apply and passed → depth moves toward `apply`
- Depth only advances, never regresses

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

Say: "I noticed [specific pattern]. Want me to save this to your learner profile?"

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
