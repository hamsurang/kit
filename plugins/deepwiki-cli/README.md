# deepwiki

> Query GitHub repository wikis via DeepWiki — without MCP token overhead.

## Prerequisites

Install the `deepwiki` CLI:

```bash
cargo install deepwiki-cli
```

## Install Plugin

```bash
claude plugin install deepwiki@hamsurang/hamkit
```

## Usage

### Auto-invoked

Ask Claude about any GitHub repository — the skill activates automatically:

> "How does useEffect work in facebook/react?"
> "Explain the App Router architecture of vercel/next.js"

### Slash command

```
/deepwiki:ask facebook/react "What is the reconciler?"
```

## Token Savings

| Method | Overhead |
|--------|----------|
| MCP server connection | initialize + tool listing per session |
| deepwiki CLI (this plugin) | result text only |

## Plugin Structure

```
deepwiki/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── skills/
│   └── deepwiki/
│       └── SKILL.md             # Auto-invoked skill
├── commands/
│   └── ask.md                   # /deepwiki:ask slash command
└── README.md
```

## License

MIT
