# vitest

> Auto-invoked skill for writing, debugging, and configuring Vitest tests in Vite-based projects

## Installation

```bash
claude plugin install vitest@hamsurang/hamkit
```

## What This Plugin Does

The `vitest` plugin adds a context skill that activates automatically when you're working with Vitest. Claude will be ready to help with test writing, configuration, mocking, coverage — without you having to explain what framework you're using.

## Auto-Activation Scenarios

The skill activates when you:

- Ask Claude to **write a test** for a function, component, or module
- Ask about **`vitest.config.ts`** or how to add Vitest to an existing Vite project
- Encounter a **failing test** and need help diagnosing it
- Ask how to **mock modules, functions, timers, or globals** with `vi`
- Ask about **coverage setup**, thresholds, or reporters
- Reference any **Vitest API** (`describe`, `it`, `expect`, `vi`, `beforeEach`, etc.)

## Plugin Structure

```
vitest/
├── .claude-plugin/
│   └── plugin.json                 # Plugin manifest
├── skills/
│   └── vitest/
│       ├── SKILL.md                # Activation conditions + behavior guidelines
│       └── references/
│           ├── config.md           # vitest.config.ts options
│           ├── api.md              # describe / it / expect / hooks API
│           ├── mocking.md          # vi.fn / vi.mock / vi.spyOn / timers
│           └── coverage.md        # Coverage providers, thresholds, reporters
└── README.md
```

The skill loads reference files on demand — only the files relevant to your current question are read.

## License

MIT
