---
title: "Systematic quality fixes for 7 Claude Code skill plugins failing skill-review eval"
category: quality-maintenance
tags: [skill-plugins, code-review, linting, frontmatter, error-handling, lazy-loading, documentation]
module: skill-review
symptom: "2 plugins (obsidian, deepwiki-cli) FAIL with 5 errors; 5 plugins NEEDS WORK with 35 warnings; issues include wrong description format, oversized frontmatter, missing error handling, cheat-sheet style docs, version numbers in docs, missing lazy loading tables, vague descriptions"
root_cause: "Skill plugins were authored without consistent adherence to the skill-review checklist standards — description format, frontmatter size limits, error handling patterns, behavioral guide structure, and lazy loading conventions were not enforced during initial development"
date_solved: 2026-03-09
severity: medium
---

# Systematic Skill Plugin Quality Fixes (P1-P8)

## Root Cause

Seven Claude Code skill plugins failed quality review because they were authored without following the established best practices checklist. The specific violations fell into several categories:

- **Description format**: Descriptions didn't use the "Use when..." trigger format that Claude uses for activation decisions. Vague descriptions failed to specify trigger boundaries.
- **Invalid frontmatter**: Obsidian had an extra `metadata.openclaw` block (only `name` and `description` are allowed in skill frontmatter).
- **Oversized content**: gh-cli was a 299-line cheat sheet instead of an 80-150 line behavioral guide.
- **Missing operational sections**: No error handling or fallback strategies defined.
- **Hard-coded version numbers**: Time-sensitive information embedded directly rather than referenced dynamically.
- **Missing lazy loading**: Reference tables that should have been lazy-loaded were inlined.

## Solution

The fix followed a prerequisite-first execution order across four phases:

**Phase 1 — Update the review standard first.** Modified the skill-review checklist itself before touching any plugins. Added three new checks: YAML validity (Error severity), broken reference detection (Error severity), and a tool-wrapper naming exception (documented via blockquote). This ensured all subsequent fixes would be validated against the updated standard.

**Phase 2 — Pre-flight validation.** Ran CP0 (pre-flight) on all 7 plugins against the new checklist to confirm no unexpected errors and to baseline the known issues.

**Phase 3 — Fix all 6 plugins in parallel** (4 via delegated agents, 2 directly):

| Plugin | Key Changes |
|---|---|
| **deepwiki-cli** | Rewrote description to "Use when..." format, added "When NOT to Use" section, added Error Handling section, fixed plugin.json typo |
| **obsidian** | Cleaned frontmatter (removed `metadata.openclaw`), rewrote description (873 to ~474 chars), removed inline headless section (293 to 134 lines), added error handling with OS-specific paths |
| **gh-cli** | Full restructure (299 to 115 lines), moved command references to separate lazy-loaded files, added behavioral guidelines |
| **personal-tutor** | Expanded description (141 to ~340 chars), added topic normalization rules, node limits, quiz failure transitions |
| **library-analyzer** | Added context size limits, URL mode mapping, output-template lazy loading |
| **plugin-spec.md** | Updated 3 instances of old description format to match new standard |

**Phase 4 — Version bump and verify.** Patch-bumped all changed plugins, then ran CP2 (final verification) confirming all checks passed.

### Results

| Metric | Before | After |
|--------|--------|-------|
| FAIL plugins | 2 | 0 |
| Errors | 5 | 0 |
| Warnings | 35 | ≤12 |

## Key Technique

**Prerequisite-first execution**: Modify the review checklist before fixing the plugins, so every fix is validated against the updated standard in the same pass. This eliminates the risk of fixing plugins to an outdated standard and having to re-fix them after the checklist is updated. The final verification pass (CP2) is authoritative — if it passes, the plugins conform to the new standard, not just the old one.

## Prevention Checklist

Before merging any PR that modifies a `SKILL.md` file, verify each item:

- [ ] **Run skill-review eval**: Execute the skill-review analyzer on every modified `SKILL.md`. Zero errors must be the merge threshold.
- [ ] **Description starts with "Use when..."**: The description field must open with a trigger phrase. Follow with trigger nouns/verbs, then a "Do NOT trigger for..." negative boundary clause.
- [ ] **Frontmatter contains only `name` and `description`**: No `version`, `author`, `tags`, or any other metadata fields in YAML frontmatter.
- [ ] **Body is 150 lines or fewer**: If the skill needs heavy reference material, move it into a `references/` directory.
- [ ] **Lazy loading table present when `references/` exists**: Include a "References Loading Guide" table mapping each reference file to when to load it.
- [ ] **No hard-coded version numbers**: Search the file for semver patterns. Instruct the agent to check at runtime instead.
- [ ] **Tool-wrapper naming is intentional**: Skills named after tools (vitest, gh-cli) are acceptable convention. Generic skills should not be named after a single tool.

## Anti-Patterns to Avoid

1. **The Vague Description**: `"Manages deployments"` — too broad, causes false activations. Fix: add trigger conditions and negative boundaries.
2. **The Metadata-Stuffed Frontmatter**: Extra fields create maintenance burden and token cost. Fix: strip to `name` and `description` only.
3. **The 400-Line Mega-Skill**: Every activation loads the entire file. Fix: keep body under 150 lines, move references out.
4. **The Hard-Coded Version**: Version numbers go stale within weeks. Fix: instruct runtime checking.
5. **The Cheat Sheet Masquerading as a Skill**: Tables of commands without behavioral instructions. Fix: lead with behavioral guidelines, move reference tables to `references/`.

## Related References

- **Plan**: `docs/plans/2026-03-08-refactor-skill-quality-improvements-plan.md`
- **Checklist**: `plugins/skill-review/skills/skill-review/references/checklist.md`
- **Plugin spec**: `docs/contributors/plugin-spec.md`
- **PR**: https://github.com/hamsurang/kit/pull/15
