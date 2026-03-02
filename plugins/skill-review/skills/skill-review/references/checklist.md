# Skill Review Checklist

Derived from the Claude Agent Skills best practices. Run every check against the target `SKILL.md`.

---

## 1. Frontmatter

| Check | Severity | What to look for |
|---|---|---|
| Only `name` and `description` fields present | ⚠️ Warning | Extra fields (e.g. `version`, `license`) are ignored by Claude and signal authoring confusion |
| Total frontmatter ≤ 1024 characters | ❌ Error | Longer frontmatter may be truncated; description becomes unreliable |
| `name` uses only letters, numbers, and hyphens | ❌ Error | Parentheses, underscores, or special characters break skill lookup |
| No XML/HTML tags in frontmatter values | ❌ Error | Tags cause parsing errors in some environments |
| `name` value is not a reserved word | ❌ Error | Avoid: `help`, `skills`, `cancel`, `clear`, `reset` |

---

## 2. Description Quality

The description is how Claude decides whether to load a skill. It must be a precise triggering signal.

| Check | Severity | What to look for |
|---|---|---|
| Written in third person | ❌ Error | "Use when..." not "I help you..." or "You can use this..." — it is injected into the system prompt |
| Describes ONLY triggering conditions, NOT workflow | ❌ Error | Summarizing the skill's process in the description causes Claude to follow the description instead of reading the full skill |
| Starts with "Use when..." | ⚠️ Warning | Strongly preferred; makes triggering intent unambiguous |
| Includes specific trigger phrases or keywords | ❌ Error | Vague descriptions ("helps with skills") cause missed activations |
| Includes "what" context AND "when to use" context | ⚠️ Warning | Pure "what" without "when" creates confusion; pure "when" without domain context may match too broadly |
| No vague generics like "helps with", "assists in" | ⚠️ Warning | Weak phrasing degrades retrieval precision |
| Description ≤ 500 characters (not counting YAML key) | ⚠️ Warning | Longer descriptions risk truncation and are harder to scan |
| Technology-specific triggers are explicit | ⚠️ Warning | If the skill is framework-specific, say so ("Use when using React Router...") |

---

## 3. Naming Conventions

| Check | Severity | What to look for |
|---|---|---|
| Name uses gerund (-ing) or descriptive verb form for process skills | ⚠️ Warning | `creating-skills` > `skill-creation`; `condition-based-waiting` > `async-test-helpers` |
| Name is not a vague generic | ⚠️ Warning | Avoid: `helper`, `utils`, `misc`, `tools` — names must be searchable |
| Name reflects the action being taken, not the domain | ⚠️ Warning | `root-cause-tracing` > `debugging` — concrete > abstract |

---

## 4. Content Quality

| Check | Severity | What to look for |
|---|---|---|
| Skill body is ≤ 500 lines | ⚠️ Warning | Longer skills should move heavy reference to `references/` files |
| Instructions use imperative form | ⚠️ Warning | "Read the config file" not "You should read the config file" |
| No explaining what Claude already knows | ⚠️ Warning | Skip basics like "Markdown is a markup language" — focus on non-obvious context |
| Consistent terminology throughout | ⚠️ Warning | Pick one term per concept; don't swap between "test" / "spec" / "case" arbitrarily |
| One high-quality example (not mediocre multi-language examples) | ⚠️ Warning | One complete, runnable, well-commented example beats five generic stubs |
| No narrative storytelling ("In session X, we found...") | ❌ Error | Skills must be reusable across contexts, not session-specific post-mortems |
| Code examples are complete and runnable | ⚠️ Warning | Fill-in-the-blank templates are nearly useless |

---

## 5. Progressive Disclosure

| Check | Severity | What to look for |
|---|---|---|
| Heavy reference (100+ lines) is in `references/` not inline | ⚠️ Warning | Inline API docs bloat every invocation of the skill |
| Nesting is at most one level deep (`references/topic.md`) | ⚠️ Warning | Deeper nesting (`references/a/b/c.md`) is hard to maintain and discover |
| If the skill has ≥ 4 major sections, there is a table of contents | ⚠️ Warning | Long skills without a ToC are hard to navigate |
| `references/` files are only loaded when relevant (lazy loading) | ⚠️ Warning | "Load all reference files upfront" wastes context; files should be conditional |

---

## 6. Structure & File Hygiene

| Check | Severity | What to look for |
|---|---|---|
| All file paths use Unix format (forward slashes) | ❌ Error | Windows-style paths (`references\checklist.md`) break cross-platform skills |
| No time-sensitive information (dates, version numbers without caveats) | ⚠️ Warning | Skills are reused long-term; stale dates erode trust |
| Separate files have descriptive names (not `file1.md`, `helper.js`) | ⚠️ Warning | File names must convey purpose to future readers |
| Supporting files only exist for reusable tools or heavy reference | ⚠️ Warning | One-off content should stay inline |
| Flowcharts are only used for non-obvious decisions or process loops | ⚠️ Warning | Flowcharts for linear instructions or reference material add noise |

---

## 7. Scripts (if present)

Only applies if the skill includes shell scripts, Python scripts, or other executable files.

| Check | Severity | What to look for |
|---|---|---|
| Scripts have explicit error handling | ❌ Error | Silent failures in skill scripts are very hard to debug |
| No magic numbers without explanation | ⚠️ Warning | Constants like `60`, `1024`, `0x1F` must be named or commented |
| All required packages/dependencies are documented | ❌ Error | Scripts that depend on unlisted packages fail silently on other machines |
| MCP tool calls use fully qualified names (`mcp__server__tool`) | ❌ Error | Unqualified MCP names fail when multiple servers are loaded |

---

## 8. Plugin Manifest (if present)

Only applies if the skill is part of a plugin (includes `plugin.json`).

| Check | Severity | What to look for |
|---|---|---|
| `plugin.json` has `name` field | ❌ Error | Required for plugin registry |
| `plugin.json` has `version` field (semver) | ❌ Error | Required for update management |
| `plugin.json` has `description` field | ❌ Error | Required for marketplace display |
| `plugin.json` has `author` field | ⚠️ Warning | Strongly recommended for attribution and support |

---

## Scoring Guide

After running all checks:

| Result | Status |
|---|---|
| 0 errors, 0 warnings | **PASS** — ready to publish |
| 0 errors, 1+ warnings | **NEEDS WORK** — fix warnings before merging |
| 1+ errors | **FAIL** — must fix errors before publishing |
