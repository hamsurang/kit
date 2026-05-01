# personal-tutor

> Adaptive technical tutoring skill that builds a persistent knowledge graph and learner profile across sessions — your private tutor that knows you.

## Installation

```bash
claude plugin install personal-tutor@hamsurang/kit
```

## What This Plugin Does

The `personal-tutor` plugin turns Claude into an adaptive technical tutor. It tracks what you know, how you learn, and adapts every session based on your accumulated history — building a persistent knowledge graph per topic and a cross-topic learner profile over time.

Each session follows a structured 5-phase flow: Socratic diagnostic → agenda planning → teaching → verification quiz → archiving. The more sessions you do, the better Claude understands your learning patterns.

## Activation

Activates when you say:

- "I want to learn Rust"
- "Teach me TypeScript generics"
- "Let's study algorithms"
- "Resume my Rust session"

## How It Works

### Knowledge Graph

For each topic, Claude maintains a knowledge graph in `~/.claude/learning/topics/{topic}/knowledge-graph.md`. Every concept is tracked as a node:

| Status | Meaning |
|--------|---------|
| `gap` | Not yet learned |
| `partial` | Warm-quiz passed this session (working-memory echo possible) |
| `understood` | Cold-quiz passed in a later session without hints (true cross-session retrieval) |

Depth is tracked using Bloom's Taxonomy: `recall → apply → explain`

### Learner Profile

Cross-topic patterns are accumulated in `~/.claude/learning/learner-profile.md`:
- What analogies work for you
- Where you consistently get stuck
- Your preferred learning direction (bottom-up vs top-down)

Learner profile is **never written without your explicit confirmation**.

### Session Flow

```
Socratic Diagnostic (first session only)
  ↓
Cold Quiz Sweep (Phase 2.0 — only if cold-pending nodes exist)
  ↓
Agenda: 1–2 new concepts + 1 review (cap=1 when cold-pending exists)
  ↓
Teaching: predict → explain (compare to guess) → Socratic Q&A → check
  ↓
Warm Quiz: Feynman / Apply / Analyze (gap → partial only)
  ↓
Archive: update graph + session log + self-audit + confirm profile
```

`partial → understood` only via Phase 2.0 cold quiz (no-hint pass) or review-slot escape valve — never within the same session a concept was first taught (Iron Rule #6).

### Applied Learning Science

| Principle | Where applied |
|-----------|--------------|
| Bloom's Taxonomy | Node depth tracking; deterministic format rotation (Feynman → Apply → Analyze) |
| Zone of Proximal Development | Prerequisites gate concept unlock |
| Retrieval Practice | Cold quiz (Phase 2.0) gates `understood`; warm quiz seeds `partial` |
| Generation Effect | Phase 3 Predict step before Explain |
| Desirable Difficulty | Cold quiz across sessions; format rotation pass-only; no re-teaching before retrieval |
| Feynman Technique | One of three quiz formats |
| Spaced Repetition | Cold quiz next session + 30-day staleness check |
| Cognitive Load Theory | Max 2 new concepts per session; cap=1 when cold-pending exists |

## Storage Structure

```
~/.claude/learning/
  learner-profile.md
  topics/
    rust/
      knowledge-graph.md
      sessions/
        2026-03-01-session-1.md
```

## Plugin Structure

```
personal-tutor/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── personal-tutor/
│       ├── SKILL.md                     # 5-phase tutoring protocol
│       └── knowledge-graph-template.md  # Node template for new topics
└── README.md
```

## License

MIT
