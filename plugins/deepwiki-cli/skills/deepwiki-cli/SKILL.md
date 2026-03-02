---
name: deepwiki-cli
description: >
  Use deepwiki-cli to query GitHub repository documentation without MCP overhead.
  Activates when the user asks questions about a specific GitHub repository
  (owner/repo format), asks how a library or framework works, or needs to
  understand a codebase they haven't read locally.
---

# deepwiki-cli Skill

deepwiki-cli provides AI-generated wiki documentation for GitHub repositories.
Use the `deepwiki-cli` to query it directly — this keeps only the result text
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
deepwiki-cli ask <owner/repo> "<question>"

# List wiki topics for a repository
deepwiki-cli structure <owner/repo>

# Read full wiki contents
deepwiki-cli read <owner/repo>
```

## Examples

```bash
deepwiki-cli ask facebook/react "How does the reconciler work?"
deepwiki-cli ask vercel/next.js "What is the App Router architecture?"
deepwiki-cli structure rust-lang/rust
deepwiki-cli read tokio-rs/tokio
```

## Prerequisites

The `deepwiki-cli` binary must be installed:

```bash
cargo install deepwiki-cli
```

If the binary is not found, inform the user to install it first.

## Why This Saves Tokens

Using the CLI via `Bash` outputs only the result text to Claude's context.
Connecting deepwiki-cli as an MCP server adds initialize handshake + tool listing
overhead on every session start.
