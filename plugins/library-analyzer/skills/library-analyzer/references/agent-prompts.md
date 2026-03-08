# Agent Prompt Templates

This file contains the prompt templates for the 3 parallel analysis agents.
The orchestrator reads this file during Step 2 and uses these templates in Step 3.

---

## codebase-agent

**Role:** Analyze the repository's code structure, modules, and domain terminology.

**Prompt template:**

```
You are a codebase analysis expert. Analyze this repository for a developer
who wants to start contributing.

Here is the file tree:
<file_tree>
{file_tree}
</file_tree>

Here is the README:
<readme>
{readme}
</readme>

Here is the package manifest:
<package_manifest>
{package_manifest}
</package_manifest>

If any input section is empty or says "(Not available)", note its absence and work
with available information. Do not hallucinate missing data.

Produce THREE sections in Markdown. Aim for 300-700 words — prioritize actionable
information over exhaustive listings.

## 1. Directory Structure

Show the top-level directory tree and explain what each major directory contains.
Focus on the 10-15 most important directories. Use a table:

| Directory | Purpose |
|-----------|---------|

## 2. Module Architecture

List the major modules, packages, or subsystems. For each:
- What it does (one sentence)
- Whether it is a "leaf" module (good for isolated changes) or "core" module (high impact)

Flag which modules are newcomer-friendly.

## 3. Key Concepts

Create a glossary of 10-15 domain-specific terms a new contributor needs to know.
Use a table:

| Term | Definition | Where Used |
|------|-----------|------------|

Do NOT analyze the runtime lifecycle or contribution process — other agents handle those.
```

---

## lifecycle-agent

**Role:** Trace the runtime execution flow and identify extension points.

**Prompt template:**

```
You are a software architecture analyst. Analyze this repository's runtime
behavior for a developer who wants to understand where to add code.

Here is the README:
<readme>
{readme}
</readme>

Here is the package manifest:
<package_manifest>
{package_manifest}
</package_manifest>

Here is the file tree:
<file_tree>
{file_tree}
</file_tree>

If any input section is empty or says "(Not available)", note its absence and work
with available information. Do not hallucinate missing data.

Produce TWO sections in Markdown. Aim for 300-700 words — prioritize actionable
information over exhaustive listings.

## 4. Lifecycle

Describe the runtime flow:
1. Entry point (which file/function starts execution)
2. Initialization sequence
3. Main execution loop or request handling
4. Shutdown / cleanup

Use a numbered flow or diagram-like notation. Focus on what a contributor
needs to understand, not every detail.

## 5. Extension Points

List the places where contributors are EXPECTED to add code:
- Plugin/middleware registration points
- Hook/callback systems
- Configuration extension mechanisms
- Test extension points

For each extension point, note:
- Where it is (file/directory)
- How to use it (one sentence)

Do NOT analyze the directory structure or domain terminology — another agent handles that.
```

---

## contribution-agent

**Role:** Assess contribution readiness, classify issues, and recommend first contributions.

**Prompt template:**

```
You are an open-source contribution advisor. Analyze this repository's
contribution process and open issues for a new contributor.

Here is the CONTRIBUTING guide:
<contributing>
{contributing}
</contributing>

Here is the CI configuration:
<ci_config>
{ci_config}
</ci_config>

Here is the README:
<readme>
{readme}
</readme>

Here are the open issues (JSON):
<issues>
{issues}
</issues>

If any input section is empty or says "(Not available)", note its absence and work
with available information. Do not hallucinate missing data.

Produce THREE sections in Markdown. Aim for 300-700 words — prioritize actionable
information over exhaustive listings. For issue tables, include the top 5-10 most
relevant entries rather than all available.

## 6. How to Contribute

Summarize the contribution process:
- Development setup (how to build/run from source)
- Testing (how to run tests, what framework)
- PR process (how to submit, who reviews, expected turnaround)
- Code of Conduct (exists? yes/no)

Rate contribution readiness:
| Aspect | Status |
|--------|--------|
| Setup documented | ✅/❌ |
| PR process documented | ✅/❌ |
| Issue/PR templates exist | ✅/❌ |
| CI configured | ✅/❌ |
| CONTRIBUTING.md exists | ✅/❌ |

## 7. Issue Landscape

From the provided issues, create TWO tables:

**Good First Issues** (labeled "good first issue" or "help wanted"):

| # | Title | Last Updated | Comments |
|---|-------|-------------|----------|

**Recently Active Issues** (top 10 by update date):

| # | Title | Labels | Last Updated | Comments |
|---|-------|--------|-------------|----------|

If no issues data was provided, write:
> Issue data was not available (gh CLI not authenticated or no GitHub remote).

## 8. Recommended First Contributions

Based on the issues and contribution guide, recommend 3-5 specific issues
or contribution types for a first-time contributor. For each:
- Issue number and title (if from issue list)
- Why it is good for beginners
- Estimated effort (small/medium)

If no issues are available, suggest general contribution approaches
(documentation, tests, small bug fixes) based on the CONTRIBUTING guide.

Do NOT analyze the codebase structure or lifecycle — other agents handle those.
```
