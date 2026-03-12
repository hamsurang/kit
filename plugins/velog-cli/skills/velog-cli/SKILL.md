---
name: velog-cli
description: >
  Use when the user wants to manage velog.io blog posts from the terminal.
  Activates when the user mentions velog, wants to publish a blog post, list
  their velog posts, create or edit articles, manage drafts, or check trending
  posts on velog.io. Also use when the user writes markdown content and wants
  to publish it as a blog post, or when they ask about their velog account
  status. Even if they just say "post this to my blog" or "publish this",
  consider activating if velog-cli is installed.
---

# velog-cli Skill

`velog` is a CLI client for [velog.io](https://velog.io), a developer blogging platform.
It lets you manage blog posts entirely from the terminal — create from markdown files,
edit, publish drafts, browse trending posts, and more.

## Prerequisites

The `velog` binary must be installed:

```bash
# macOS
brew tap hamsurang/velog-cli && brew install velog-cli

# Cargo (any platform)
cargo install velog-cli
```

If `velog` is not found, tell the user to install it first.

## Authentication

Most write operations require authentication. Check status before attempting mutations.

```bash
# Check if logged in
velog auth status

# Login (interactive — prompts for tokens from browser DevTools)
velog auth login

# Logout
velog auth logout
```

**How to get tokens**: The user opens velog.io in their browser, opens DevTools (F12) →
Application → Cookies, and copies `access_token` and `refresh_token`. The CLI prompts
for these during `velog auth login`.

Credentials are stored at `~/.config/velog-cli/credentials.json` and auto-refresh when expired.

## Post Management

### List Posts

```bash
# List your own posts (requires auth)
velog post list

# List your drafts
velog post list --drafts

# Trending posts (filterable by period)
velog post list --trending
velog post list --trending --period week

# Recent posts across velog
velog post list --recent

# Posts by a specific user
velog post list -u <username>

# Control result count (1–100, default 20)
velog post list --limit 50

# Pagination
velog post list --recent --cursor <cursor>
velog post list --trending --offset 20
```

### Show a Post

```bash
# Show your own post by slug
velog post show <slug>

# Show another user's post
velog post show <slug> -u <username>
```

The slug is the URL path segment (e.g., `my-first-post` from `velog.io/@user/my-first-post`).

### Create a Post

```bash
# From a markdown file (saved as draft by default)
velog post create -t "Post Title" -f article.md

# From stdin
echo "# Hello World" | velog post create -t "Hello"

# Publish immediately (not draft)
velog post create -t "Title" -f article.md --publish

# With tags and custom slug
velog post create -t "Title" -f article.md --tags "rust,cli,velog" --slug my-custom-slug

# Private post
velog post create -t "Title" -f article.md --publish --private
```

### Edit a Post

```bash
# Update content from a file
velog post edit <slug> -f updated.md

# Update title
velog post edit <slug> -t "New Title"

# Update tags
velog post edit <slug> --tags "new,tags"

# Update everything
velog post edit <slug> -t "New Title" -f updated.md --tags "new,tags"
```

### Publish a Draft

```bash
velog post publish <slug>
```

### Delete a Post

```bash
# With confirmation prompt
velog post delete <slug>

# Skip confirmation
velog post delete <slug> -y
```

## Output Formats

All commands accept `--format` to control output style:

| Format | Use case | Description |
|--------|----------|-------------|
| `pretty` | Human reading (default) | Tables, colors, markdown rendering |
| `compact` | AI agents, scripts | Minified JSON on a single line |
| `silent` | CI/CD, exit-code-only checks | Queries emit JSON, mutations emit nothing |

When Claude is running velog commands programmatically, use `--format compact` to get
structured JSON output that's easy to parse:

```bash
velog post list --format compact
velog post show my-post --format compact
```

## Common Workflows

### Write and publish a blog post

1. Write markdown content to a file
2. Create as draft: `velog post create -t "Title" -f article.md --tags "tag1,tag2"`
3. Preview on velog.io if needed
4. Publish: `velog post publish <slug>`

### Update an existing post

1. Find the slug: `velog post list --format compact`
2. Edit: `velog post edit <slug> -f updated.md`

### Browse trending posts for inspiration

```bash
velog post list --trending --period week --limit 10
```

## Shell Completions

```bash
# Generate completions
velog completions zsh    # or bash, fish, elvish, powershell
```

## Error Handling

1. **Not authenticated**: Run `velog auth status` first. If not logged in, guide
   the user through `velog auth login`.
2. **Post not found**: Verify the slug with `velog post list --format compact`.
3. **Binary not found**: Tell the user to install via `brew` or `cargo`.

## Tips for AI Agent Usage

- Always use `--format compact` when you need to parse the output programmatically.
- Check auth status before attempting create/edit/delete/publish operations.
- When creating posts from user-written content, save to a temp file first, then
  pass via `-f`. This avoids shell escaping issues with stdin piping.
- Default behavior is to save as draft — use `--publish` only when the user
  explicitly asks to publish immediately.
- Use `--format silent` for mutations when you only care about success/failure
  (check exit code).
