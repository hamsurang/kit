# velog-cli

Claude Code plugin for managing [velog.io](https://velog.io) blog posts from the terminal.

## Installation

```bash
# Install the velog CLI binary
brew tap hamsurang/velog-cli && brew install velog-cli

# Install the Claude Code plugin
claude plugin install velog-cli@hamsurang/kit
```

## Features

- **Authentication**: Login/logout with velog.io credentials
- **Post management**: Create, edit, delete, publish posts from markdown files
- **Browsing**: List your posts, drafts, trending, and recent posts
- **AI-optimized output**: `--format compact` for structured JSON output

## Usage

The skill activates automatically when you mention velog or want to manage blog posts:

- "List my velog posts"
- "Publish this markdown as a velog post"
- "Show trending posts on velog"
- "Edit my post about Rust"

## Prerequisites

- [velog-cli](https://github.com/hamsurang/velog-cli) (`brew install velog-cli` or `cargo install velog-cli`)

## License

MIT
