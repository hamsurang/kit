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
| `partial` | Learned, passed quiz this session |
| `understood` | Passed quiz in a later session without hints |

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
Agenda: 1–2 new concepts + 1 review
  ↓
Teaching: explain → Socratic Q&A → check understanding
  ↓
Quiz: Feynman / Apply / Analyze (rotate)
  ↓
Archive: update graph + session log + confirm learner profile update
```

### Applied Learning Science

| Principle | Where applied |
|-----------|--------------|
| Bloom's Taxonomy | Node depth tracking |
| Zone of Proximal Development | Prerequisites gate concept unlock |
| Retrieval Practice | Quiz required every session |
| Feynman Technique | One of three quiz formats |
| Spaced Repetition | Two-session validation for `understood` |
| Cognitive Load Theory | Max 2 new concepts per session |

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
