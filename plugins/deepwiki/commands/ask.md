---
description: Ask a question about a GitHub repository using DeepWiki
argument-hint: <owner/repo> <question>
allowed-tools: [Bash]
---

Ask a question about a GitHub repository using the DeepWiki CLI.

Usage: `/deepwiki:ask <owner/repo> <question>`

Run the following command:

```bash
deepwiki ask $ARGUMENTS
```

If the `deepwiki` command is not found, inform the user to install it:

```bash
cargo install deepwiki-cli
```
