# Plugin Specification

This document defines the format for kit plugins. All plugins must follow this specification to be accepted into the marketplace.

## Directory Structure

```
plugins/my-plugin/
├── .claude-plugin/
│   └── plugin.json          # REQUIRED: Plugin manifest
├── .mcp.json                # Optional: MCP server configuration
├── commands/                # Optional: Slash commands
│   └── my-command.md
├── skills/                  # Optional: Auto-invoked skills
│   └── my-skill/
│       └── SKILL.md
├── agents/                  # Optional: Agent definitions
│   └── my-agent.md
└── README.md                # REQUIRED: Plugin documentation
```

Only `.claude-plugin/plugin.json` and `README.md` are required.

## Plugin Manifest (`plugin.json`)

The manifest lives at `.claude-plugin/plugin.json` inside the plugin directory.

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Unique kebab-case identifier. Must match the directory name. Max 50 chars. |
| `version` | string | Semantic version (e.g. `1.0.0`). See [Versioning](#versioning). |
| `description` | string | One clear sentence describing what the plugin does. Max 200 chars. |
| `author.name` | string | Human-readable author name. |
| `author.github` | string | GitHub username for attribution and contact. |
| `license` | string | SPDX license identifier (e.g. `MIT`, `Apache-2.0`). |

### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `keywords` | string[] | Up to 5 tags for discoverability. Lowercase, no spaces. |
| `repository` | string | URL of the plugin's source repository. |
| `homepage` | string | URL of the plugin's homepage or documentation. |
| `skills` | string | Path to skills directory if plugin includes skills (e.g. `"./skills/"`). |
| `mcpServers` | string | Path to `.mcp.json` if plugin uses MCP servers (e.g. `"./.mcp.json"`). |

### Full Example

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "A plugin that does something useful for developers",
  "author": {
    "name": "Your Name",
    "github": "your-github-username"
  },
  "license": "MIT",
  "keywords": ["automation", "workflow"],
  "repository": "https://github.com/you/my-plugin",
  "skills": "./skills/"
}
```

## Commands

Commands are slash commands that users invoke explicitly. Each `.md` file in `commands/` becomes a `/plugin-name:command-name` command in Claude Code.

### Frontmatter

```yaml
---
description: Short description shown in /help (required)
argument-hint: <required-arg> [optional-arg]   # Optional
allowed-tools: [Read, Glob, Grep, Bash]        # Optional
model: sonnet                                  # Optional: haiku, sonnet, opus
---
```

`commands/*.md` frontmatter requires only `description`.

### Body

The body is the command's prompt template. Use `$ARGUMENTS` to reference user-provided arguments.

### Example: `commands/analyze.md`

```markdown
---
description: Analyze code quality in a file or directory
argument-hint: <path>
allowed-tools: [Read, Glob, Grep]
model: sonnet
---

# Analyze Code Quality

Analyze the code at: $ARGUMENTS

Steps:
1. Read the file(s) at the given path
2. Check for common code quality issues
3. Report findings with line numbers and suggestions
```

## Skills

Skills are automatically invoked by Claude when the conversation context matches the skill's trigger conditions. Each skill lives in its own subdirectory with a `SKILL.md` file.

### Frontmatter

```yaml
---
name: skill-name              # Required: unique identifier
description: >                # Required: trigger conditions (used by Claude to decide when to activate)
  This skill should be used when...
---
```

`skills/*/SKILL.md` frontmatter requires both `name` and `description`.

The `description` field is critical — it's what Claude reads to decide whether to activate this skill. Write it as trigger scenarios starting with "This skill should be used when...".

### Example: `skills/code-explainer/SKILL.md`

```markdown
---
name: code-explainer
description: >
  This skill should be used when the user asks to "explain this code",
  "what does this do", "help me understand", or asks questions about
  how a specific piece of code works.
---

# Code Explainer

## When This Skill Activates

When the user wants to understand code they're looking at.

## How to Help

1. Read the relevant code file(s)
2. Explain what the code does in plain language
3. Highlight key patterns, data structures, or algorithms
4. Point out any non-obvious behaviors or edge cases
```

## Agents

Agent definitions in `agents/` provide specialized system prompts for targeted tasks.

### Frontmatter

```yaml
---
name: agent-name              # Required: identifier
description: >                # Required: when/how to invoke this agent
  Use this agent when...
---
```

`agents/*.md` frontmatter requires both `name` and `description`.

### Example: `agents/reviewer.md`

```markdown
---
name: reviewer
description: >
  Use this agent to perform code reviews. It applies consistent
  review criteria and provides structured feedback.
---

# Code Reviewer

You are an expert code reviewer. When reviewing code:

1. Check for correctness and edge cases
2. Evaluate readability and maintainability
3. Identify security vulnerabilities
4. Suggest improvements with clear rationale

Format feedback as: [severity] file:line — description
Severity levels: critical, warning, suggestion
```

## MCP Configuration (`.mcp.json`)

Plugins that integrate with external services use `.mcp.json` to configure MCP servers.

### stdio Server (local binary/script)

```json
{
  "mcpServers": {
    "server-name": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@scope/package-name"],
      "env": {
        "API_KEY": "${MY_API_KEY}"
      }
    }
  }
}
```

### HTTP Server (remote endpoint)

```json
{
  "mcpServers": {
    "server-name": {
      "type": "http",
      "url": "https://api.example.com/mcp",
      "headers": {
        "Authorization": "Bearer ${API_TOKEN}"
      }
    }
  }
}
```

**Security rules:**
- URLs must use `https://` (except `localhost` and `127.0.0.1`)
- Use environment variable references (`${VAR_NAME}`) for secrets — never hardcode credentials
- Document required environment variables in your plugin's `README.md`

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Plugin name | kebab-case, lowercase | `my-plugin`, `git-helper` |
| Plugin directory | Same as `name` field | `plugins/my-plugin/` |
| Command files | kebab-case `.md` | `commands/analyze-code.md` |
| Skill directories | kebab-case | `skills/code-explainer/` |
| Agent files | kebab-case `.md` | `agents/reviewer.md` |
| MCP server names | kebab-case | `"github-api"` |

**Length limits:**
- Plugin name: max 50 characters
- Description: max 200 characters
- Keywords: max 5, each max 30 characters

**Forbidden in names:** spaces, uppercase letters, underscores (use hyphens), special characters except `-`

## Versioning

Plugins must use [Semantic Versioning](https://semver.org/):

- `MAJOR.MINOR.PATCH` (e.g. `1.2.3`)
- `MAJOR`: breaking changes (commands renamed, behavior changed)
- `MINOR`: new features added backward-compatibly
- `PATCH`: bug fixes, documentation updates

Start at `1.0.0`. When updating an existing plugin, always increment the version in `plugin.json`.
