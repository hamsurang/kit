---
name: gh-cli
description: >
  Use when working with GitHub from the command line using the gh CLI tool. Triggers on
  "create PR", "open pull request", "gh command", "GitHub CLI", "list issues", "check CI",
  "merge PR", "view workflow run", "gh auth", "clone repo", "fork repo", "create issue",
  "review PR", "close issue", "release", or any GitHub operation from the terminal.
  Always use this skill when the user wants to interact with GitHub repositories,
  pull requests, issues, releases, or GitHub Actions via the command line — even if
  they don't explicitly say "gh" or "GitHub CLI".
---

# GitHub CLI (gh) — Practical Workflow Guide

The `gh` CLI lets you do everything GitHub without leaving the terminal.

> **Version:** 2.85.0+ | **Docs:** [cli.github.com](https://cli.github.com)
>
> For detailed command options, see the `references/` files linked throughout.

---

## Quick Start

```bash
# Install
brew install gh                    # macOS
sudo apt install gh                # Ubuntu/Debian
winget install --id GitHub.cli    # Windows

# Authenticate
gh auth login                      # Interactive (recommended)
gh auth status                     # Verify login
```

---

## Pull Requests

### Create a PR

```bash
# Interactive — gh fills in title/body from commit messages
gh pr create

# One-liner
gh pr create --title "feat: add dark mode" --body "Closes #42"

# Draft PR
gh pr create --draft --title "WIP: refactor auth"

# Target a specific base branch
gh pr create --base develop --title "feat: add feature"

# Open the new PR in browser immediately
gh pr create --web
```

### Review & Merge

```bash
# List open PRs in current repo
gh pr list

# View PR details (with diff)
gh pr view 123
gh pr view 123 --web            # Open in browser

# Check out a PR locally
gh pr checkout 123

# Review: approve / request changes / comment
gh pr review 123 --approve
gh pr review 123 --request-changes --body "Please add tests"
gh pr review 123 --comment --body "Looks good, but minor nit below"

# Merge (default: merge commit)
gh pr merge 123
gh pr merge 123 --squash        # Squash merge
gh pr merge 123 --rebase        # Rebase merge
gh pr merge 123 --auto          # Auto-merge when checks pass
```

### PR Status & Search

```bash
# PRs assigned to you or mentioning you
gh pr list --author "@me"
gh pr list --assignee "@me"
gh pr list --search "review-requested:@me"

# Filter by label or state
gh pr list --label "bug" --state open
gh pr list --state merged --limit 20

# Show all checks for a PR
gh pr checks 123
```

---

## Issues

### Create & Edit

```bash
# Interactive
gh issue create

# One-liner
gh issue create --title "Bug: login fails on Safari" --body "Steps to reproduce..."

# With labels and assignee
gh issue create --title "feat: dark mode" --label "enhancement" --assignee "@me"

# Edit an issue
gh issue edit 42 --title "Updated title" --add-label "priority:high"
```

### List & Close

```bash
# List open issues
gh issue list

# Filter
gh issue list --label "bug"
gh issue list --assignee "@me"
gh issue list --search "is:open label:bug created:>2024-01-01"

# View issue
gh issue view 42
gh issue view 42 --web

# Close / reopen
gh issue close 42
gh issue close 42 --comment "Fixed in #123"
gh issue reopen 42
```

---

## Repositories

```bash
# Clone a repo
gh repo clone owner/repo
gh repo clone owner/repo -- --depth 1   # Shallow clone

# Fork and clone in one step
gh repo fork owner/repo --clone

# Create a new repo
gh repo create my-app --public --clone
gh repo create my-app --private --description "My new project"

# View repo info
gh repo view
gh repo view owner/repo --web

# List repos for a user/org
gh repo list                           # Your repos
gh repo list my-org --limit 50        # Org repos
```

---

## GitHub Actions

```bash
# List recent workflow runs
gh run list
gh run list --workflow ci.yml
gh run list --branch main --status failure --limit 10

# Watch a run in real time
gh run watch

# View run logs
gh run view 12345678
gh run view 12345678 --log

# Re-run failed jobs only
gh run rerun 12345678 --failed

# Trigger a workflow manually
gh workflow run ci.yml
gh workflow run deploy.yml --field environment=staging

# List workflows
gh workflow list
gh workflow enable ci.yml
gh workflow disable old-workflow.yml
```

---

## Releases

```bash
# List releases
gh release list

# View latest release
gh release view

# Create a release
gh release create v1.2.0
gh release create v1.2.0 --title "v1.2.0 — Dark Mode" --notes "Added dark mode support"
gh release create v1.2.0 ./dist/*.tar.gz   # Attach assets

# Upload additional assets to an existing release
gh release upload v1.2.0 ./dist/app.zip
```

---

## JSON Output & Scripting

`gh` returns rich JSON via `--json`. Pair with `jq` for powerful filtering.

```bash
# List PR titles and numbers
gh pr list --json number,title --jq '.[] | "\(.number): \(.title)"'

# Get PR's head branch name
gh pr view 123 --json headRefName --jq '.headRefName'

# Check if all PR checks passed
gh pr checks 123 --json name,state --jq '[.[] | select(.state != "SUCCESS")] | length == 0'

# Get issue labels
gh issue view 42 --json labels --jq '.labels[].name'

# Find failing workflow runs
gh run list --json status,name,url --jq '.[] | select(.status == "failure") | .url'

# Count open PRs by author
gh pr list --state open --json author --jq 'group_by(.author.login) | map({author: .[0].author.login, count: length})'
```

---

## Useful Global Flags

| Flag | Description |
|------|-------------|
| `--repo owner/repo` | Target a specific repo (skip cd) |
| `--json field1,field2` | Return JSON for scripting |
| `--jq <expr>` | Filter JSON with jq expression |
| `--web` | Open in browser |
| `--paginate` | Fetch all pages (use with `--json`) |
| `--limit N` | Limit results (default varies) |

```bash
# Operate on a repo without cd-ing into it
gh pr list --repo facebook/react --limit 5

# Paginate all issues as JSON
gh issue list --paginate --json number,title,state
```

---

## Quick Aliases (save typing)

```bash
# Set up convenient aliases
gh alias set prc 'pr create --web'
gh alias set prl 'pr list --assignee @me'
gh alias set isl 'issue list --assignee @me'

# Use them
gh prc          # open PR creation in browser
gh prl          # list your PRs
gh isl          # list your issues
```

---

## Common Troubleshooting

| Problem | Fix |
|---------|-----|
| `gh: command not found` | `brew install gh` or see [install guide](https://cli.github.com) |
| `Not logged in` | `gh auth login` |
| Permission denied | `gh auth refresh --scopes repo,workflow` |
| Wrong repo targeted | Add `--repo owner/repo` or `cd` into the repo |
| Stale token | `gh auth refresh` |

---

## More Detail

For exhaustive flag lists and advanced options, see:

- [`references/prs-issues.md`](references/prs-issues.md) — PR reviews, issue templates, milestones, projects
- [`references/repos-actions.md`](references/repos-actions.md) — repo settings, Actions secrets/variables, caches, artifacts
- [`references/auth-search-api.md`](references/auth-search-api.md) — auth flows, search syntax, direct API calls
