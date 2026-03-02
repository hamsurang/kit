# Auth, Search & API — Extended Reference

## Authentication

### gh auth login

```bash
# Interactive (recommended — handles SSH key setup too)
gh auth login

# Non-interactive: pipe token from stdin
echo "$GITHUB_TOKEN" | gh auth login --with-token

# GitHub Enterprise Server
gh auth login --hostname enterprise.internal

# Specific protocol
gh auth login --git-protocol ssh|https

# Web-based OAuth
gh auth login --web
```

### Managing accounts

```bash
gh auth status                             # Show all authenticated accounts
gh auth status --show-token                # Display the actual token

# Multiple accounts: switch between them
gh auth switch
gh auth switch --hostname github.com --user alice

# Get token for scripting
gh auth token
export GH_TOKEN=$(gh auth token)

# Refresh token / add scopes
gh auth refresh
gh auth refresh --scopes "repo,workflow,write:packages"
gh auth refresh --remove-scopes "delete_repo"

# Log out
gh auth logout
gh auth logout --hostname github.com --user alice
```

### Environment variables for CI/CD

```bash
# These env vars override stored credentials
export GH_TOKEN=ghp_xxxxxxxxxxxx          # GitHub token
export GH_HOST=github.com                 # Override hostname
export GH_REPO=owner/repo                 # Override default repo
export GH_ENTERPRISE_HOSTNAME=ghe.company.com

# Disable interactive prompts in CI
export GH_PROMPT_DISABLED=true

# Example: use in GitHub Actions
- name: List PRs
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: gh pr list --state open
```

---

## Search

### gh search — cross-repository

```bash
# Search repositories
gh search repos "language:typescript stars:>1000"
gh search repos "org:vercel topic:react" --limit 20
gh search repos "created:>2024-01-01 stars:>500" --json fullName,stargazersCount

# Search issues and PRs
gh search issues "is:open label:bug repo:vercel/next.js"
gh search prs "is:merged author:@me merged:>2024-01-01"
gh search prs "review-requested:@me is:open" --json number,title,url

# Search commits
gh search commits "fix auth" --repo owner/repo
gh search commits "merge" --author alice --limit 10

# Search code
gh search code "useState" --repo facebook/react --language typescript
gh search code "TODO" --owner my-org --language go
```

### Useful search qualifiers

| Qualifier | Example | Description |
|-----------|---------|-------------|
| `is:` | `is:open`, `is:merged` | State filter |
| `author:` | `author:@me` | By author |
| `assignee:` | `assignee:@me` | By assignee |
| `label:` | `label:bug` | By label |
| `milestone:` | `milestone:"v2.0"` | By milestone |
| `created:` | `created:>2024-01-01` | Date range |
| `updated:` | `updated:<2024-06-01` | Last updated |
| `repo:` | `repo:owner/name` | Specific repo |
| `org:` | `org:vercel` | Organization |
| `language:` | `language:typescript` | Code language |
| `stars:` | `stars:>1000` | Star count |
| `sort:` | `sort:updated-desc` | Sort order |
| `no:` | `no:assignee` | Missing field |

---

## Direct API Access

`gh api` lets you call any GitHub REST or GraphQL endpoint with auth handled automatically.

### REST API patterns

```bash
# GET (default)
gh api repos/{owner}/{repo}
gh api user
gh api orgs/my-org/members

# POST
gh api repos/{owner}/{repo}/issues \
  --method POST \
  --field title="Bug report" \
  --field body="Something is broken" \
  --field labels[]="bug"

# PATCH
gh api repos/{owner}/{repo}/issues/42 \
  --method PATCH \
  --field state="closed"

# DELETE
gh api repos/{owner}/{repo}/labels/123 --method DELETE

# Pagination — fetch all pages at once
gh api repos/{owner}/{repo}/issues --paginate \
  --jq '.[].title'

# Use {owner} and {repo} placeholders (auto-filled from current repo)
gh api repos/{owner}/{repo}/pulls --jq '.[].number'
```

### GraphQL

```bash
gh api graphql -f query='
  query($owner: String!, $name: String!, $n: Int!) {
    repository(owner: $owner, name: $name) {
      pullRequests(last: $n, states: OPEN) {
        nodes {
          number
          title
          author { login }
        }
      }
    }
  }
' -f owner=facebook -f name=react -F n=5

# From a file
gh api graphql --input query.graphql
```

### jq cheat sheet for gh output

```bash
# Extract a single field
gh api user --jq '.login'

# Map over array
gh pr list --json number,title --jq '.[] | "\(.number): \(.title)"'

# Filter array
gh run list --json status,name --jq '.[] | select(.status == "failure") | .name'

# Count
gh issue list --json number --jq 'length'

# Sort and limit
gh pr list --json number,createdAt --jq 'sort_by(.createdAt) | reverse | .[0:5]'

# Nested access
gh api user --jq '.plan.name'

# Key-value pairs
gh pr view 123 --json labels --jq '.labels | map(.name) | join(", ")'
```

---

## Configuration

```bash
gh config list                             # Show all settings
gh config get editor
gh config set editor "code --wait"         # VS Code
gh config set editor "nvim"
gh config set git_protocol ssh|https
gh config set prompt enabled|disabled
gh config set pager "less -R"
gh config set browser "open"

gh config clear-cache                      # Clear HTTP cache
```

### Aliases

```bash
gh alias list
gh alias set co 'pr checkout'             # gh co 123
gh alias set prc 'pr create --web'
gh alias set mine 'issue list --assignee @me'
gh alias set ready '!gh pr list --state open | fzf | cut -f1 | xargs gh pr ready'

gh alias delete co
```

---

## SSH & GPG Keys

```bash
# SSH keys
gh ssh-key list
gh ssh-key add ~/.ssh/id_ed25519.pub --title "My laptop"
gh ssh-key delete 12345

# GPG keys
gh gpg-key list
gh gpg-key add ./public-key.asc
gh gpg-key delete ABC123
```
