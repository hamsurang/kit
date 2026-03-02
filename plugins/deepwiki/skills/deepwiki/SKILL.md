---
name: deepwiki
description: >
  Use deepwiki CLI to query GitHub repository documentation without MCP overhead.
  Activates when the user asks questions about a specific GitHub repository
  (owner/repo format), asks how a library or framework works, or needs to
  understand a codebase they haven't read locally.
version: 1.0.0
license: MIT
---

# DeepWiki Skill

DeepWiki provides AI-generated wiki documentation for GitHub repositories.
Use the `deepwiki` CLI to query it directly — this keeps only the result text
in Claude's context, avoiding MCP protocol overhead.

## When This Skill Activates

- User references a GitHub repository by name (owner/repo format)
- User asks how a library or framework works
- User needs to understand a codebase they haven't read locally
- User asks architecture or API questions about an open-source project

## How to Use

Run via `Bash` tool:

```bash
# Ask a question about a repository
deepwiki ask <owner/repo> "<question>"

# List wiki topics for a repository
deepwiki structure <owner/repo>

# Read full wiki contents
deepwiki read <owner/repo>
```

## Examples

```bash
deepwiki ask facebook/react "How does the reconciler work?"
deepwiki ask vercel/next.js "What is the App Router architecture?"
deepwiki structure rust-lang/rust
deepwiki read tokio-rs/tokio
```

## Prerequisites

The `deepwiki` binary must be installed:

```bash
cargo install deepwiki-cli
```

If the binary is not found, inform the user to install it first.

## Why This Saves Tokens

Using the CLI via `Bash` outputs only the result text to Claude's context.
Connecting DeepWiki as an MCP server adds initialize handshake + tool listing
overhead on every session start.
