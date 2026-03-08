---
name: library-analyzer
description: >
  Use when the user wants to contribute to an open-source library,
  says "analyze this library for contribution", "I want to contribute to X",
  "help me contribute to", "contribution readiness", or "기여하고 싶다".
  Do NOT activate for general "how does X work" questions (use deepwiki-cli instead).
---

# Library Analyzer

Analyze an open-source library for contribution readiness. Produces a structured
Markdown report covering codebase structure, lifecycle, and contribution paths.

## Contents

- [When This Skill Activates](#when-this-skill-activates)
- [Step 1: Input Parsing](#step-1-input-parsing)
- [Step 2: Data Collection](#step-2-data-collection)
- [Step 3: Parallel Analysis](#step-3-parallel-analysis)
- [Step 4: Result Assembly](#step-4-result-assembly)
- [Iron Rules](#iron-rules)

---

## When This Skill Activates

- User wants to **contribute** to an open-source library or project
- User says "analyze this library", "I want to contribute to X", "기여하고 싶다"
- User asks for a "contribution analysis" or "contribution readiness" report

**Do NOT activate when:**
- User asks "how does X work?" or "what is the architecture of X?" → use `deepwiki-cli`
- User wants to understand a codebase without contributing intent → use `deepwiki-cli`

---

## Step 1: Input Parsing

Parse the target from `$ARGUMENTS` or ask the user with AskUserQuestion.

| Input Format | Action |
|-------------|--------|
| `https://github.com/owner/repo` | URL mode |
| `owner/repo` | URL mode (shorthand, treat as GitHub) |
| `/path/to/dir` or `./path` | Local mode |
| `react` (bare name) | Reject: "Please use owner/repo format (e.g., facebook/react)" |

**Validate the input:**

- **URL mode**: Run `which deepwiki-cli` via Bash.
  - If installed → proceed with deepwiki-cli data collection.
  - If NOT installed → tell the user:
    "deepwiki-cli is required for URL mode. Install with `cargo install deepwiki-cli`,
    or clone the repo locally and provide the local path instead."
- **Local mode**: Verify the path exists and is a directory.
  - If not → report the error and stop.

**Extract owner/repo for issue collection:**

- URL mode: parse from the URL or shorthand directly.
- Local mode: run `git -C <path> remote get-url origin` and match `github.com[:/]owner/repo`.
  - If no GitHub remote → issues will be skipped (note this to the user).

Announce what you will analyze:
> "Analyzing **{owner/repo}** for contribution readiness ({url|local} mode)..."

---

## Step 2: Data Collection

Collect data into a **context bundle** before launching any agents.
Read `references/agent-prompts.md` at this point for the agent prompt templates.

**Context size limits** — cap each field to keep total context under 15,000 characters:
- `readme`: first 500 lines
- `file_tree`: max 300 entries (top 3 directory levels)
- `wiki_content` (URL mode): first 800 lines
- Truncate with a note: `(truncated at N lines — full content available via direct access)`

### URL Mode (deepwiki-cli)

```bash
# Get repository structure overview
deepwiki-cli structure <owner/repo>

# Get full wiki content
deepwiki-cli read <owner/repo>
```

**Map deepwiki-cli output to context bundle fields:**
- `deepwiki-cli structure` output → `file_tree`
- `deepwiki-cli read` output → split into `readme` (first section) + `wiki_content` (remainder)
- If `deepwiki-cli ask` is used for specific questions → append answers to relevant fields

### Error Recovery (both modes)

If `deepwiki-cli` or `gh` commands fail (timeout, network error, rate limit, permission denied):

1. **Log the error** in the context bundle as a note (e.g., `issues: "gh rate limited"`)
2. **Try WebFetch fallback** for URL mode — fetch README, CONTRIBUTING, and file listings directly from `raw.githubusercontent.com` and the GitHub web UI
3. **Continue with whatever data was successfully collected** — partial context is better than no context
4. The analysis will be partial but still valuable. Note any data gaps when reporting completion.

### Local Mode (static analysis)

```
1. Glob("**/*", path) — get file tree (cap at 500 entries, top 3 levels)
2. Read README.md; search for CONTRIBUTING.md in: target directory, repo root, docs/, .github/
3. Read package manifest (package.json, Cargo.toml, pyproject.toml, go.mod, etc.)
4. Read CI config (.github/workflows/*.yml) — first file only, summarize
```

### Issue Collection (both modes, if owner/repo is available)

Run via Bash. If `gh` is not authenticated or not installed, skip and note it.

```bash
# Good first issues (up to 20)
gh issue list --repo <owner/repo> --label "good first issue" --state open \
  --json number,title,createdAt,updatedAt,comments --limit 20

# Help wanted (up to 15)
gh issue list --repo <owner/repo> --label "help wanted" --state open \
  --json number,title,createdAt,updatedAt,comments --limit 15

# Recently active (up to 30)
gh issue list --repo <owner/repo> --sort updated --state open \
  --json number,title,labels,updatedAt,comments --limit 30
```

Deduplicate by issue number. Cap at 50 total.

**Enrichment queries** (run if time permits, enhances analysis quality):

```bash
# Repository metadata
gh api repos/<owner/repo> --jq '{stars: .stargazers_count, forks: .forks_count, open_issues: .open_issues_count}'

# Top contributors (top 10)
gh api repos/<owner/repo>/contributors?per_page=10

# Recent releases (last 5)
gh api repos/<owner/repo>/releases?per_page=5

# Community health
gh api repos/<owner/repo>/community/profile
```

These are optional but significantly improve the contribution-agent's analysis.

### Context Bundle

After collection, you should have:

| Field | Content |
|-------|---------|
| `owner_repo` | e.g., `facebook/react` |
| `source_mode` | `url` or `local` |
| `library_name` | repo name (e.g., `react`) |
| `readme` | README content (first 500 lines if large) |
| `contributing` | CONTRIBUTING.md content or null |
| `file_tree` | Directory structure (top 3 levels, max 500 entries) |
| `package_manifest` | package.json / Cargo.toml / etc. content |
| `ci_config` | CI workflow summary or null |
| `issues` | Deduplicated issue JSON or null |

---

## Step 3: Parallel Analysis

**Launch ALL 3 agents in a SINGLE response turn.** Do NOT launch them one by one.

Use the Agent tool with `subagent_type: "general-purpose"` for each.
Do NOT use `run_in_background: true` — issue all 3 calls at once and collect results together.

For each agent, take the prompt template from `references/agent-prompts.md` and replace
the `{placeholder}` tags with the actual context bundle data collected in Step 2.
For example, replace `{readme}` with the full README content, `{file_tree}` with the
directory listing, etc. If a field is `null`, replace the placeholder with:
`(Not available — this repository does not have this file)`

### Agent 1: codebase-agent

**Input:** `file_tree`, `readme`, `package_manifest`
**Output sections:** §1 Directory Structure, §2 Module Architecture, §3 Key Concepts

### Agent 2: lifecycle-agent

**Input:** `readme`, `package_manifest`, `file_tree`
**Output sections:** §4 Lifecycle, §5 Extension Points

### Agent 3: contribution-agent

**Input:** `contributing`, `ci_config`, `issues`, `readme`
**Output sections:** §6 How to Contribute, §7 Issue Landscape, §8 Recommended First Contributions

---

## Step 4: Result Assembly

Read `references/output-template.md` at this point for the report template.

After all 3 agents return:

1. **Check each result.** For any agent that failed or returned empty:
   - Insert: `> ⚠️ This section could not be analyzed.`
   - Continue with remaining sections.

2. **Count successes:** `sections_completed = N/3`

3. **Assemble the report** using the template from `references/output-template.md`.
   Fill in the YAML frontmatter and each section with agent results.

4. **Save the file:**
   ```bash
   mkdir -p docs/library-analysis
   ```
   Write the assembled Markdown to:
   `docs/library-analysis/<library_name>-<YYYY-MM-DD>.md`

5. **Report completion to the user:**
   > "Analysis complete: `docs/library-analysis/<name>-<date>.md`
   > Sections completed: N/3 agents succeeded."

---

## Iron Rules

1. **Never launch agents before data collection is complete** — agents without context produce hallucinated analysis that pollutes the final report. The context bundle must be fully prepared first.
2. **Never abort the entire report because one agent failed** — partial analysis is more valuable than no analysis. Users can always re-run for missing sections. Assemble whatever succeeded.
3. **Always launch all 3 agents in ONE response turn** — sequential launches add unnecessary latency; parallel execution cuts total time by ~60%. Do NOT use `run_in_background`. If the Agent tool is not available (e.g., in subagent context), perform all 3 analyses sequentially in the same response — output quality is the same, only speed differs.
4. **Always report the file path and section count** after saving the report — users need to know where to find the output and whether any sections are missing.
5. **Always read `references/agent-prompts.md`** before launching agents — the prompt templates define the exact output structure each agent must produce.
