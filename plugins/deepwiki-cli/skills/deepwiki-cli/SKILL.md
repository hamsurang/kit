---
name: deepwiki-cli
description: >
  Use when the user asks questions about a GitHub repository's architecture,
  API, or internals, or mentions deepwiki-cli or DeepWiki. Activates when
  the user needs to understand a codebase they haven't cloned locally, or
  asks how a library or framework works. Do NOT activate for local codebases
  already accessible on disk or private repositories.
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

## When NOT to Use

- Repository is already cloned locally — use Glob/Grep/Read tools directly
- Repository is private — deepwiki-cli only works with public repositories
- User is asking about their own code in the current working directory

## Error Handling

If `deepwiki-cli` is not installed or a command fails:

1. Check if the binary exists: `which deepwiki-cli`
2. If not found, tell the user to install: `cargo install deepwiki-cli`
3. If the repository is not found, verify the owner/repo format
4. If the command times out, try `deepwiki-cli structure` first (lighter query), then ask specific questions
5. As a last resort, fall back to web search for the repository's documentation

## Why This Saves Tokens

Using the CLI via `Bash` outputs only the result text to Claude's context.
Connecting deepwiki-cli as an MCP server adds initialize handshake + tool listing
overhead on every session start.
