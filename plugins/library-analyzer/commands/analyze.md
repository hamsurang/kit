---
description: Analyze an open-source library for contribution readiness
argument-hint: <owner/repo or local-path>
---

# Analyze Library for Contribution

Analyze the target at `$ARGUMENTS` for open-source contribution readiness.

Follow the **library-analyzer** skill workflow:

1. Parse the input (URL, owner/repo shorthand, or local path)
2. Run data collection (deepwiki-cli for URL mode, static analysis for local mode)
3. Collect GitHub issues via `gh` CLI
4. Launch 3 parallel analysis agents (codebase, lifecycle, contribution)
5. Assemble results into a Markdown report
6. Save to `docs/library-analysis/<name>-<date>.md`
