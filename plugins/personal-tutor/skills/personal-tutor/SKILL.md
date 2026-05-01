---
name: personal-tutor
description: >
  Use when the user wants to learn a technical topic through structured,
  multi-session tutoring with prerequisite tracking and knowledge graphs.
  Activates on "I want to learn X", "teach me X", "let's study X", or
  resuming a previous learning session. Do NOT activate for quick reference
  lookups or one-off coding questions — only for sustained learning goals.
---

# Personal Tutor

**Sections:** [Session Start](#session-start) · [Phase 1: Diagnostic](#phase-1-socratic-diagnostic-first-session-only) · [Phase 2.0: Cold Quiz Sweep](#phase-20-cold-quiz-sweep) · [Phase 2: Agenda](#phase-2-agenda-planning) · [Phase 3: Teaching](#phase-3-teaching) · [Phase 4: Warm Quiz](#phase-4-warm-quiz) · [Phase 5: Archive](#phase-5-archive) · [Iron Rules](#iron-rules)

## Session Start

1. Extract topic name from user input (e.g., "Rust", "TypeScript generics")
   - Normalize the topic name: lowercase, replace spaces with hyphens, strip special characters
     - Example: "TypeScript Generics" → `typescript-generics`, "Rust" → `rust`
2. Check `~/.claude/learning/topics/{topic}/knowledge-graph.md`
   - **Exists** → load it + `~/.claude/learning/learner-profile.md`. Then:
     - If any node has `Cold quiz pending: yes`, jump to **Phase 2.0: Cold Quiz Sweep**.
     - Otherwise, jump directly to **Phase 2** (Phase 2.0 is skipped silently — no announcement).
   - **Not exists** → create `~/.claude/learning/topics/{topic}/` → start **Phase 1**.

## Phase 1: Socratic Diagnostic (first session only)

Ask 5–7 open-ended questions to map existing knowledge. One question at a time. Examples:
- "Have you worked with manual memory management before? (C, C++, etc.)"
- "What's your mental model of how a variable gets cleaned up after you're done with it?"
- "Have you seen ownership errors before? What did they look like?"

After mapping, ask once: **"Is there a reference you'd like me to draw from? (book, docs, course — optional)"**
- Yes → store in `knowledge-graph.md` header as `Reference: [title + URL]`; use for examples and citations only — Claude leads curriculum
- No → set `Reference: none`

Read `knowledge-graph-template.md` only when creating a new knowledge graph (first session for a topic). Create `knowledge-graph.md` using the template. Seed nodes based on the topic's prerequisite tree. All nodes start as `gap`.

Keep the initial knowledge graph to 10–15 nodes. If the topic is broad (e.g., "Rust"), scope to a subtopic first (e.g., "Rust ownership and borrowing"). Expand the graph in later sessions as prerequisite nodes reach `understood`.

## Phase 2.0: Cold Quiz Sweep

This phase fires only when at least one node has `Cold quiz pending: yes`. Otherwise it is skipped silently (Session Start handles the branching).

**Purpose**: cross-session retrieval verification — the only path to `partial → understood` (Iron Rule #6, Phase 5 path A). The "Verification" role moved here from Phase 4 (now "Warm Quiz") so retrieval happens *after* the answer has left the learner's working memory.

### Selection
- Eligible nodes: `partial` status AND `Cold quiz pending: yes`. (`gap` nodes are not swept; they re-enter via agenda re-pick.)
- Maximum **2 nodes per session** (R11). If pending count > 2, pick the oldest by Phase 4 timestamp; the rest carry over to next session.

### Format selection (deterministic, R6)
Read each eligible node's `Last quiz format`:

| Last quiz format | Cold quiz format |
|------------------|------------------|
| `feynman` | `apply` |
| `apply` | `analyze` |
| `analyze` | `apply` (fixed — never returns to feynman) |
| `none` (no prior pass) | `feynman` (default starting format) |

Format escalation only follows *passes*. Never escalate after a fail — Phase 5 keeps `Last quiz format` unchanged on cold-fail, so retry stays at the same level (or the learner falls back via downgrade streak).

### Execution rule (no re-teaching)
**Do NOT re-explain, summarize, or hint at the concept before the quiz prompt.** The point of cold quiz is retrieval *without* the answer in working memory. Open straight with the quiz prompt:

- Feynman: "Explain `<concept>` to me like I'm 5."
- Apply: "What's wrong with this code?" + [code snippet using the concept]
- Analyze: "Why was `<concept>` designed this way?"

If the learner says "remind me what this was?" — politely decline ("Try first; I'll remind you only if you can't recall any part of it after attempting"). One minimal-info nudge is the most you may give, and only after a genuine attempt.

### Pass / fail handling
See Phase 5 Step 1 (Upgrade rules + Cold-quiz pending update) for the canonical rules. Summary:
- Cold pass (no hint) → `partial → understood`, `Cold quiz pending: no`, `Last quiz format` updated, history `cold: passed (no hint)`.
- Cold pass (hint used) → status `partial`, `pending: yes` retained, `Last quiz format` updated, history `cold: passed (hint used)`. Counts toward 3-strike streak.
- Cold fail → status `partial`, `pending: yes` retained, **`Last quiz format` NOT updated**, history `cold: failed`. Counts toward both 2-fail and 3-strike streaks.

After Phase 2.0 completes (success, partial, or all fail), proceed to Phase 2 with knowledge of the remaining pending count for cap decisions.

### First session
First sessions have no prior session, so no node can have `Cold quiz pending: yes`. Phase 2.0 does not fire. New-concept warm-passes during the first session set `Cold quiz pending: yes` for the *next* session's Phase 2.0.

---

## Phase 2: Agenda Planning

Session composition (respect Cognitive Load Theory):

- **New concepts (cap depends on cold-quiz pending state at session start)**:
  - If 1+ nodes had `Cold quiz pending: yes` at session start (Phase 2.0 fired): cap = **1**. Lower bound prioritizes depth over breadth and balances the cognitive load of cold retrieval.
  - If zero pending: cap = **1–2** (default).
  - Selection rule: `gap` nodes whose prerequisites are ALL ≥ `partial`.
- **Review: 1** — the oldest `partial` node (skip if none). Independent of the new-concept cap; the review slot is a separate unit.
- **Staleness check**: if an `understood` node's last quiz was 30+ days ago, add it to the review slot.
- **Cold-quiz units (from Phase 2.0) are separate** and not counted in the new-concept cap. A session with 2 cold quizzes + 1 new concept + 1 review = 4 units total. This is the design intent, not overflow.

If `learner-profile.md` exists, read it and adjust approach before Phase 3:
- Match preferred learning direction (bottom-up vs top-down)
- Anticipate known weak areas
- Use what's worked before (analogies, code-first, etc.)

Announce the agenda to the user before starting. The announcement should reflect any cold quiz already completed in Phase 2.0. Example: "Today: cold(completed) 2 + new 1 + review 1 = 4 units."

## Phase 3: Teaching

Loop for **each new concept** in agenda (review nodes follow a separate flow — see below):

1. **Predict** (Generation Effect — required for new concepts). Ask the learner: "What do you think this concept does? A one-line guess is fine." Wait for their response.
   - Learner answers (right, wrong, partial — any guess counts): proceed to Explain and *cite their guess* ("you guessed X — close: X, but with Y…").
   - Learner answers "I don't know" / blank: give a **strategic hint** — minimum information only (a category cue, a one-word direction, a related keyword). Never reveal the answer's verbs, structure, or relations. Then ask them to guess again.
   - Still cannot guess after one strategic hint: proceed to Explain, opening with "the guess felt hard? that itself is a signal — this concept sits at the intersection of X and Y." Do not give a second hint; a second hint becomes the answer.
2. **Explain concept** — explicitly compare to the learner's prediction (confirm correct parts, correct wrong parts). The Explain is *anchored* on their guess, not a separate lecture.
3. **Socratic Q&A** — ask questions to deepen understanding, don't just lecture.
4. **Check**: "Does this make sense? Any questions?"

**Review nodes** (oldest partial revisit, see Phase 2): skip the Predict step. Re-teach with analogy or code example, then Socratic Q&A. The review slot's job is reinforcement and retrieval, not generation.

**Strategic hint definition**: minimum information that nudges the learner without disclosing the answer. Examples: "this keyword pairs with `borrow`" (✓ category cue), "starts with the letter L" (✓ tiny scaffold). Anti-examples: "the answer is lifetime" (✗ direct), "lifetimes track how long a reference is valid" (✗ too much structure).

If stuck or confused (any concept type):
- Try a different angle: analogy → code example → reverse question ("What would break if this rule didn't exist?")
- Reference material role: cite for examples or further reading only
  - "The Rust Book ch.4 has a great example of this"
  - "If you want to go deeper, check [reference ch.X]"
- Do NOT follow reference material's order — Claude leads curriculum

**Backward-compat (read-time)**: When loading a node sub-block, treat missing `Cold quiz pending` or `Last quiz format` lines as default (`no` / `none` respectively). Do not rewrite the node here — Phase 5 archive expands the format only when the node is next updated.

## Phase 4: Warm Quiz

This is the **same-session retrieval** step. Pass effect is capped at `gap → partial` — Phase 4 alone cannot upgrade a node to `understood`. The cross-session "verification" role lives in **Phase 2.0: Cold Quiz Sweep**.

Run one warm quiz per new concept taught this session. Do NOT skip. Choose format from the rotation table:

| Format | Prompt style | Tests |
|--------|-------------|-------|
| **Feynman** | "Explain this to me like I'm 5" | Internalization |
| **Apply** | "What's wrong with this code?" + [code snippet] | Application |
| **Analyze** | "Why was this designed this way?" | Deep understanding |

**Track hint usage:** Did you give any hints during the quiz? Note it.
- No hints → record `warm: passed (no hint)` in quiz history
- Hints given → record `warm: passed (hint used)` in quiz history
- Failed → record `warm: failed` in quiz history (status stays `gap`; agenda re-pick handles next session)

**Cold-quiz scheduling (R5 — sole scheduler).** On any warm-pass of a new concept (hint or no hint):
- Set `Cold quiz pending: yes` on the node.
- Set `Last quiz format` to the format used (e.g., `feynman`).
This schedules the node for next-session Phase 2.0 cold quiz, the only path to `understood`. R9 (hint-pass forcing rule) is automatically satisfied; no-hint passes are also scheduled because cold quiz is the sole upgrade gate.

**Warm-fail nodes do NOT get `Cold quiz pending: yes`** — they remain `gap` and re-enter via standard agenda re-pick.

## Phase 5: Archive

Run this phase at the end of every session. Do not skip even if session is short.

**Step 1: Update node states in `knowledge-graph.md`**

**Upgrade rules.** A node only advances along these paths:

- `gap → partial`: warm quiz passed this session (hint OK).
- `partial → understood` (path A — primary): cold quiz passed in **this session's Phase 2.0** with **no hint**. Node was taught in a prior session by definition (cold quiz only fires when `Cold quiz pending: yes`, set in a prior Phase 4).
- `partial → understood` (path B — review-slot escape valve): review-slot warm quiz passed this session with **no hint** AND the node has at least one prior `cold:` entry in its quiz history. This rescues nodes whose cold quiz was attempted-but-not-cleanly-passed and would otherwise be stranded.

Never advance to `understood` within the same session a node was first taught — Iron Rule #6. Both paths above are cross-session by construction.

**Self-audit (drift guard).** Before writing `knowledge-graph.md`, scan every node you are about to mark `understood` this session. Verify quiz history contains at least one of:
- (path A) a prior-session `cold: passed (no hint)` entry, OR
- (path B) a prior-session `cold:` entry (any outcome) AND today's review-slot `warm: passed (no hint)`.

If neither holds, revert the node to `partial`. This is the mechanical enforcement of Iron Rule #6.

**Downgrade rules (warm and cold combined).** Walk consecutive entries in quiz history (most recent first):
- `passed (no hint)` (warm or cold) → reset the streak counter.
- `failed` and `passed (hint used)` → count toward the streak.

Triggers:
- (a) 2 consecutive `failed` entries (warm or cold, any mix) → `partial → gap`, re-teach from a different angle next session.
- (b) 3 consecutive entries that are any mix of `failed` and `passed (hint used)` with NO `passed (no hint)` between them → `partial → gap` (3-strike rule, prevents indefinite hint-pass loops).

Either trigger demotes; otherwise status unchanged. If quiz failed: add note to quiz history AND flag concept in learner-profile as "needs reinforcement" (propose this to user in Step 3).

**Cold-quiz pending update on cold-quiz outcome:**
- Cold pass (no hint): `Cold quiz pending: no`. Update `Last quiz format`.
- Cold pass (hint used): keep `Cold quiz pending: yes` (next session retries). Update `Last quiz format`.
- Cold fail: keep `Cold quiz pending: yes`. **Do NOT update `Last quiz format`** — only *passes* update format, which prevents escalation into Bloom levels the learner just failed.

**Quiz history format on update**: append entries with `warm:` or `cold:` prefix per the template's convention. For nodes touched this session, expand the sub-block to the 6-line schema (`Status / Depth / Prerequisites / Cold quiz pending / Last quiz format / Quiz history`) — touched-node-only gradual migration. Untouched nodes retain their existing schema.

Depth progression (update when quiz demonstrates deeper mastery):
- Quiz format was Feynman and passed → depth moves toward `explain`
- Quiz format was Apply and passed → depth moves toward `apply`
- Depth only advances, never regresses.

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

## Early Session Exit

If the user needs to leave mid-session:

1. Save progress immediately — update any node states changed so far
2. Write a partial session log noting where the session stopped
3. On next session resume, pick up from the interrupted point (skip re-teaching completed concepts)

## Iron Rules

These rules are non-negotiable. Do not skip them under any circumstances.

1. **Never end a session without a quiz** — Retrieval Practice is the core of retention
2. **Never teach a node whose prerequisites aren't ≥ partial** — teaching without foundations wastes both parties' time
3. **Never write to `learner-profile.md` without explicit user confirmation** — accuracy matters more than automation
4. **Never skip Phase 5** — even if the session runs long, archive before closing
5. **Never teach more than 2 new concepts per session** — cognitive overload defeats learning
6. **Never advance a node to `understood` within the same session it was first taught** — desirable difficulty requires cross-session retrieval; Phase 5 self-audit enforces this mechanically
