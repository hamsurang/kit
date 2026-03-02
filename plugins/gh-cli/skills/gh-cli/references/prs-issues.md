# PRs & Issues — Extended Reference

## Pull Requests: Full Options

### gh pr create

```bash
gh pr create \
  --title "feat: dark mode" \
  --body "Closes #42" \
  --base main \
  --head my-feature-branch \
  --draft \
  --assignee "@me" \
  --reviewer alice,bob \
  --label "enhancement,frontend" \
  --milestone "v2.0" \
  --project "Roadmap"
```

### gh pr list

```bash
gh pr list --state open|closed|merged|all
gh pr list --base main                    # PRs targeting main
gh pr list --head feature-branch          # PRs from a specific branch
gh pr list --author "@me"
gh pr list --assignee alice
gh pr list --label "bug"
gh pr list --search "is:open review:approved"
gh pr list --search "review-requested:@me is:open"
gh pr list --draft                        # Draft PRs only
gh pr list --limit 100
```

### gh pr view

```bash
gh pr view                     # Current branch's PR
gh pr view 123
gh pr view 123 --comments      # Show comments
gh pr view 123 --json number,title,state,body,labels,reviews
```

### gh pr edit

```bash
gh pr edit 123 --title "New title"
gh pr edit 123 --body "Updated description"
gh pr edit 123 --add-label "priority:high" --remove-label "needs-triage"
gh pr edit 123 --add-reviewer alice --remove-reviewer bob
gh pr edit 123 --add-assignee "@me"
gh pr edit 123 --milestone "v2.0"
```

### gh pr merge

```bash
gh pr merge 123                    # Interactive merge type selection
gh pr merge 123 --merge            # Create merge commit
gh pr merge 123 --squash           # Squash and merge
gh pr merge 123 --rebase           # Rebase and merge
gh pr merge 123 --auto             # Enable auto-merge (when checks pass)
gh pr merge 123 --delete-branch    # Delete head branch after merge
gh pr merge 123 --squash --delete-branch --body "squash commit message"
```

### gh pr review

```bash
gh pr review 123 --approve
gh pr review 123 --request-changes --body "Please add unit tests"
gh pr review 123 --comment --body "Style nit on line 42"
```

### gh pr checks

```bash
gh pr checks 123
gh pr checks 123 --watch           # Watch until all checks complete
gh pr checks 123 --fail-fast       # Exit as soon as any check fails
gh pr checks 123 --json name,state,link
```

### gh pr diff / comment

```bash
gh pr diff 123
gh pr diff 123 --patch             # Output as .patch file
gh pr comment 123 --body "LGTM!"
gh pr comment 123 --body-file comment.md
gh pr comment 123 --edit-last      # Edit your last comment
```

### gh pr close / reopen / lock

```bash
gh pr close 123
gh pr close 123 --comment "Closing in favor of #456" --delete-branch
gh pr reopen 123
gh pr lock 123 --reason "resolved|off-topic|too heated|spam"
gh pr unlock 123
```

---

## Issues: Full Options

### gh issue create

```bash
gh issue create \
  --title "Bug: login fails" \
  --body "Steps: 1. Go to /login 2. Click submit 3. See error" \
  --label "bug,priority:high" \
  --assignee "@me,alice" \
  --milestone "Sprint 5" \
  --project "Bug Tracker"

# From a template
gh issue create --template bug_report.md
```

### gh issue list

```bash
gh issue list --state open|closed|all
gh issue list --assignee "@me"
gh issue list --author alice
gh issue list --label "bug"
gh issue list --milestone "Sprint 5"
gh issue list --mention "@me"
gh issue list --search "is:open label:bug no:assignee"
gh issue list --search "is:open created:>2024-06-01 sort:updated-desc"
gh issue list --limit 200 --json number,title,state,labels
```

### gh issue view / edit / close

```bash
gh issue view 42 --comments
gh issue view 42 --json number,title,state,body,labels,assignees,comments

gh issue edit 42 \
  --title "Updated: login bug" \
  --add-label "regression" \
  --remove-label "needs-triage" \
  --add-assignee alice \
  --remove-assignee bob

gh issue close 42 --comment "Fixed in PR #123"
gh issue close 42 --reason "completed|not planned"
gh issue reopen 42
```

### gh issue comment / lock / pin / transfer

```bash
gh issue comment 42 --body "Still reproducible on v2.1"
gh issue comment 42 --body-file update.md
gh issue comment 42 --edit-last

gh issue lock 42 --reason "resolved|off-topic|too heated|spam"
gh issue unlock 42

gh issue pin 42
gh issue unpin 42

gh issue transfer 42 owner/other-repo
```

### gh issue develop (linked branches)

```bash
# Create a branch linked to an issue
gh issue develop 42
gh issue develop 42 --name "fix/login-safari" --base develop

# List branches linked to an issue
gh issue develop 42 --list
```

---

## Labels

```bash
gh label list
gh label create "priority:high" --color "FF0000" --description "Urgent"
gh label edit "priority:high" --name "p1" --color "D93F0B"
gh label delete "wontfix"

# Clone labels from another repo
gh label clone owner/source-repo
```

---

## Milestones (via API)

```bash
# List milestones
gh api repos/{owner}/{repo}/milestones --jq '.[].title'

# Create milestone
gh api repos/{owner}/{repo}/milestones \
  --method POST \
  --field title="v2.0" \
  --field due_on="2024-12-31T00:00:00Z"
```
