# gh-cli

> Auto-invoked skill for working with GitHub from the command line using the `gh` CLI tool.

```bash
claude plugin install gh-cli@hamsurang/kit
```

## What it does

This skill activates automatically when you mention GitHub CLI operations — creating PRs, managing issues, checking CI runs, cloning repos, and more. It provides:

- **Practical workflow patterns** for the most common daily tasks
- **JSON + jq examples** for scripting and automation
- **Quick reference** for flags, global options, and aliases
- **Extended references** for PRs/issues, repos/Actions, and auth/search/API

## Trigger examples

The skill activates on prompts like:

- "create a PR for this branch"
- "list my open issues"
- "check if CI passed"
- "how do I merge this PR with squash?"
- "re-run the failed workflow"
- "fork this repo and clone it"
- "set a repo secret for CI"
- "gh auth is failing in CI"

## Contents

```
skills/gh-cli/
├── SKILL.md                        # Core workflow guide (loaded on trigger)
└── references/
    ├── prs-issues.md               # Full PR & issue command reference
    ├── repos-actions.md            # Repo settings, Actions, secrets, variables
    └── auth-search-api.md          # Auth, search syntax, direct API calls
```

## License

MIT
