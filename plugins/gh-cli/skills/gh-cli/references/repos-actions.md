# Repos & GitHub Actions — Extended Reference

## Repositories

### gh repo create

```bash
gh repo create my-app --public --clone
gh repo create my-app --private --description "My project" --clone
gh repo create org/my-app --internal --team "backend"

# From a template repo
gh repo create my-app --template owner/template-repo --clone

# With homepage and topics
gh repo create my-app --public \
  --description "Awesome app" \
  --homepage "https://myapp.io" \
  --add-readme \
  --gitignore Node \
  --license MIT
```

### gh repo clone / fork / sync

```bash
gh repo clone owner/repo
gh repo clone owner/repo -- --depth 1 --branch main

# Fork (creates fork in your account)
gh repo fork owner/repo
gh repo fork owner/repo --clone              # Fork and clone immediately
gh repo fork owner/repo --fork-name my-fork
gh repo fork owner/repo --org my-org        # Fork into org

# Sync fork with upstream
gh repo sync                                 # Sync current fork's default branch
gh repo sync --branch main
gh repo sync owner/fork --source owner/upstream
```

### gh repo view / edit

```bash
gh repo view
gh repo view owner/repo --web
gh repo view owner/repo --json name,description,visibility,url,defaultBranchRef

gh repo edit \
  --description "New description" \
  --homepage "https://new-url.io" \
  --visibility public|private \
  --default-branch main \
  --enable-issues \
  --disable-wiki \
  --enable-auto-merge \
  --enable-squash-merge \
  --enable-rebase-merge \
  --delete-branch-on-merge
```

### gh repo archive / delete / rename

```bash
gh repo archive owner/repo
gh repo delete owner/repo --confirm        # DESTRUCTIVE — no undo
gh repo rename new-name
```

### gh repo deploy-key

```bash
gh repo deploy-key list
gh repo deploy-key add ./id_rsa.pub --title "CI deploy key" --allow-write
gh repo deploy-key delete 12345
```

---

## GitHub Actions

### Workflow Runs

```bash
# List runs
gh run list
gh run list --workflow ci.yml
gh run list --branch main
gh run list --status failure|success|in_progress|queued|cancelled
gh run list --user alice
gh run list --commit abc1234
gh run list --event push|pull_request|workflow_dispatch
gh run list --limit 50

# View a run
gh run view 12345678
gh run view 12345678 --log
gh run view 12345678 --log-failed          # Only failed job logs
gh run view 12345678 --job 98765432        # Specific job

# Watch run in real time
gh run watch
gh run watch 12345678
gh run watch 12345678 --exit-status        # Exit with run's exit code

# Re-run
gh run rerun 12345678                      # Re-run all jobs
gh run rerun 12345678 --failed             # Re-run only failed jobs
gh run rerun 12345678 --job 98765432       # Re-run specific job

# Cancel
gh run cancel 12345678

# Download artifacts
gh run download 12345678
gh run download 12345678 --name artifact-name
gh run download 12345678 --dir ./downloads
```

### Workflows

```bash
gh workflow list
gh workflow list --all                     # Include disabled
gh workflow view ci.yml
gh workflow view ci.yml --web

# Trigger manually (workflow_dispatch)
gh workflow run ci.yml
gh workflow run deploy.yml --field environment=prod --field version=v2.0
gh workflow run release.yml --ref release/v2.0

# Enable / disable
gh workflow enable ci.yml
gh workflow disable old-deploy.yml
```

### Secrets

```bash
# Repository secrets
gh secret list
gh secret set MY_TOKEN                     # Prompts for value
echo "secret-value" | gh secret set MY_TOKEN
gh secret set MY_TOKEN --body "secret-value"
gh secret set MY_TOKEN < ./token.txt
gh secret delete MY_TOKEN

# Environment secrets
gh secret list --env production
gh secret set DB_PASSWORD --env production

# Organization secrets
gh secret list --org my-org
gh secret set SHARED_TOKEN --org my-org --visibility all|private|selected
```

### Variables

```bash
gh variable list
gh variable get APP_ENV
gh variable set APP_ENV --body "production"
gh variable set APP_ENV                    # Interactive
gh variable delete APP_ENV

# Environment variables
gh variable list --env staging
gh variable set BASE_URL --env staging --body "https://staging.myapp.io"

# Organization variables
gh variable list --org my-org
gh variable set ORG_SETTING --org my-org --visibility all
```

### Caches

```bash
gh cache list
gh cache list --key "node-modules-"
gh cache list --sort size|created_at --order desc
gh cache list --json id,key,sizeInBytes,ref

gh cache delete 12345678
gh cache delete --all                      # Delete ALL caches (careful!)
```

### Artifacts

```bash
# Download artifacts from a run
gh run download 12345678
gh run download 12345678 --name "build-output" --dir ./artifacts
```

---

## Codespaces

```bash
gh codespace list
gh codespace create --repo owner/repo
gh codespace create --repo owner/repo --machine premiumLinux --branch feature
gh codespace code --codespace my-codespace   # Open in VS Code
gh codespace ssh --codespace my-codespace    # SSH into codespace
gh codespace stop --codespace my-codespace
gh codespace delete --codespace my-codespace
gh codespace ports                           # List forwarded ports
gh codespace ports forward 3000:3000        # Forward a port
```

---

## Environments (via API)

```bash
# List environments
gh api repos/{owner}/{repo}/environments --jq '.environments[].name'

# Create/update environment
gh api repos/{owner}/{repo}/environments/production \
  --method PUT \
  --field wait_timer=5
```
