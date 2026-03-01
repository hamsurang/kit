# skill-review

> Slash-command skill that reviews any SKILL.md against best practices and outputs a structured pass/fail report

## Installation

```bash
claude plugin install skill-review@hamsurang/kit
```

## What This Plugin Does

The `skill-review` plugin adds a slash-command that reviews any `SKILL.md` against the Claude Agent Skills best practices. It produces a structured Markdown report with per-check pass/fail status, severity levels, and prioritized recommendations — so you can catch quality issues before merging a skill into the marketplace.

## Activation

Use the skill with an explicit path or let it auto-discover:

```
/skill-review plugins/my-skill/skills/my-skill/SKILL.md
/skill-review                   # auto-discovers SKILL.md in current dir
```

Also activates when you say:

- "review this skill"
- "skill review"
- "check my SKILL.md"
- "review the skill at ..."

## What Gets Checked

| Category                     | Examples                                                                       |
| ---------------------------- | ------------------------------------------------------------------------------ |
| Frontmatter                  | Name format, character limits, reserved words, no XML tags                     |
| Description quality          | Third-person, "Use when..." form, specific triggers, no workflow summary       |
| Naming conventions           | Gerund preferred, not vague generics                                           |
| Content quality              | ≤500 lines, imperative form, no explaining basics, runnable examples           |
| Progressive disclosure       | Heavy reference in `references/`, one-level nesting, ToC for large files       |
| Structure                    | Unix paths, no stale dates, descriptive file names                             |
| Scripts (if present)         | Error handling, no magic numbers, documented dependencies, qualified MCP names |
| Plugin manifest (if present) | Required fields in `plugin.json`                                               |

## Output Format

```markdown
## Skill Review: [skill-name]

### Summary

**Status:** PASS / NEEDS WORK / FAIL
**Score:** N/N checks passed | N warnings | N errors

### ✅ Passed (N)

...

### ⚠️ Warnings (N)

- **[Check name]**: [finding] — [why it matters]

### ❌ Errors (N)

- **[Check name]**: [finding] — [why it must be fixed]

### 📋 Prioritized Recommendations

1. Most critical fix first
   ...
```

## Plugin Structure

```
skill-review/
├── .claude-plugin/
│   └── plugin.json                  # Plugin manifest
├── skills/
│   └── skill-review/
│       ├── SKILL.md                 # Activation conditions + review workflow
│       └── references/
│           └── checklist.md         # Full review rubric (37 checks)
└── README.md
```

## License

MIT
