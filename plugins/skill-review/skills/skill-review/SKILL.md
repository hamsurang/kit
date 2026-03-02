---
name: skill-review
description: >
  Use when reviewing a skill file for quality before publishing, merging, or deploying to
  a marketplace. Triggers on "review this skill", "skill review", "check my SKILL.md",
  "review the skill at [path]", or when the user wants structured feedback on whether a
  skill meets best practices.
---

# Skill Review

Reviews a `SKILL.md` against established best practices and outputs a structured pass/fail report with prioritized recommendations.

## Locating the Target Skill

**With explicit path:** Use the provided path directly (supports both `SKILL.md` files and plugin directories).

**Without path — search in this order:**

1. Current directory: `./SKILL.md`
2. Plugin skill dirs: `./plugins/*/skills/*/SKILL.md`
3. Prompt the user if multiple matches found

## Review Workflow

1. Read `SKILL.md` and any files in `references/` that it links to
2. Run each check in `references/checklist.md` — assign PASS ✅, WARNING ⚠️, or ERROR ❌
3. Output the structured report below

Be educational, not just a linter — include a brief explanation of *why* each finding matters.

## Output Format

~~~markdown
## Skill Review: [skill-name]

### Summary
**Status:** PASS / NEEDS WORK / FAIL
**Score:** N/N checks passed | N warnings | N errors

### ✅ Passed (N)
- [Check description]
- ...

### ⚠️ Warnings (N)
- **[Check name]**: [finding] — [brief explanation of why it matters]
- ...

### ❌ Errors (N)
- **[Check name]**: [finding] — [why it must be fixed before publishing]
- ...

### 📋 Prioritized Recommendations
1. [Most critical fix first]
2. ...
~~~

## Severity Definitions

| Severity | Meaning |
|---|---|
| ❌ Error | Violates a spec requirement. Must fix before publishing. |
| ⚠️ Warning | Best practice violation. Should fix for quality. |
| ✅ Pass | Meets the standard. |

## Full Rubric

See `references/checklist.md` for all checks organized by category (frontmatter, description quality, naming, content, structure, scripts, plugin manifest).
