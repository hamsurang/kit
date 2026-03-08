---
name: gh-cli
description: >
  Use when working with GitHub from the command line using the gh CLI tool.
  Trigger on "create PR", "open pull request", "list issues", "check CI",
  "merge PR", "review PR", "create issue", "release", "gh auth", "clone repo",
  "fork repo", "close issue", "view workflow run", or any GitHub operation
  from the terminal. Do NOT trigger for GitHub web UI actions or direct REST
  API calls without gh.
---

# GitHub CLI (gh) — Workflow Guide

## Contents

- [Behavior Guidelines](#behavior-guidelines)
- [Core Workflows](#core-workflows)
- [JSON Scripting Patterns](#json-scripting-patterns)
- [Common Troubleshooting](#common-troubleshooting)
- [References Loading Guide](#references-loading-guide)

## Behavior Guidelines

1. **Always check auth first** — run `gh auth status` before complex operations. If not logged in, run `gh auth login`.
2. **Prefer `--json` + `--jq` for scripting** — never parse human-readable gh output with grep/awk. Use structured JSON output.
3. **Use `--repo owner/repo` for cross-repo ops** — avoid cd-ing into directories when you can target repos directly.
4. **Prefer `gh pr create` over manual push + web UI** — it handles branch pushing, PR creation, and linking in one step.
5. **Use `--web` to hand off to browser** — when the user needs to fill forms or review visually, open in browser instead of guessing.

## Core Workflows

### Pull Requests

```bash
# Create PR (interactive — fills title/body from commits)
gh pr create

# Create with details
gh pr create --title "feat: add dark mode" --body "Closes #42"

# Draft PR
gh pr create --draft --title "WIP: refactor auth"

# Review and merge
gh pr review 123 --approve
gh pr merge 123 --squash --auto

# Check PR status
gh pr checks 123
gh pr list --author "@me"
```

### Issues

```bash
# Create issue
gh issue create --title "Bug: login fails" --label "bug" --assignee "@me"

# List and filter
gh issue list --label "bug" --state open
gh issue list --search "is:open label:bug created:>2024-01-01"

# Close with comment
gh issue close 42 --comment "Fixed in #123"
```

### CI / Actions

```bash
# Watch current run
gh run watch

# List failures
gh run list --branch main --status failure --limit 10

# View logs
gh run view 12345678 --log

# Re-run failed jobs
gh run rerun 12345678 --failed

# Trigger workflow manually
gh workflow run deploy.yml --field environment=staging
```

## JSON Scripting Patterns

```bash
# List PR titles and numbers
gh pr list --json number,title --jq '.[] | "\(.number): \(.title)"'

# Check if all PR checks passed
gh pr checks 123 --json name,state --jq '[.[] | select(.state != "SUCCESS")] | length == 0'

# Find failing workflow runs
gh run list --json status,name,url --jq '.[] | select(.status == "failure") | .url'
```

## Common Troubleshooting

| Problem | Fix |
|---------|-----|
| `gh: command not found` | `brew install gh` or see [install guide](https://cli.github.com) |
| `Not logged in` | `gh auth login` |
| Permission denied | `gh auth refresh --scopes repo,workflow` |
| Wrong repo targeted | Add `--repo owner/repo` or `cd` into the repo |
| Stale token | `gh auth refresh` |

## References Loading Guide

| Situation | Load |
|-----------|------|
| PR creation/review/merge details, issue templates, milestones | `references/prs-issues.md` |
| Repo/Actions/Workflow management, secrets, caches | `references/repos-actions.md` |
| Authentication, search syntax, API calls | `references/auth-search-api.md` |
