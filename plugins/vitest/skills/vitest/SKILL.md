---
name: vitest
description: >
  Use when the user asks to write, run, or debug tests using Vitest,
  asks about vitest.config.ts or vite.config.ts test configuration, asks how to mock modules,
  functions, timers, or globals with the `vi` utility, asks about test coverage setup or thresholds,
  references Vitest API (describe, it, test, expect, beforeEach, afterAll, etc.),
  or encounters failing Vitest tests and needs help diagnosing them.
---

# Vitest Skill

## Contents

- [Quick Start](#quick-start)
- [When This Skill Activates](#when-this-skill-activates)
- [Behavior Guidelines](#behavior-guidelines)
- [References Loading Guide](#references-loading-guide)

## Quick Start

**Minimum setup:**

```bash
npm install -D vitest
```

```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'node',
  },
})
```

**First test (`src/math.test.ts`):**

```ts
import { describe, it, expect } from 'vitest'
import { add } from './math'

describe('add', () => {
  it('returns the sum of two numbers', () => {
    expect(add(1, 2)).toBe(3)
  })
})
```

```bash
npx vitest        # watch mode
npx vitest run    # single run (CI)
```

## When This Skill Activates

- User asks to write a test for a function, component, or module
- User asks how to configure Vitest or integrate it into an existing Vite project
- User's tests are failing and they need help diagnosing the error
- User asks about mocking, spying, or stubbing in Vitest
- User wants to measure or enforce test coverage

## Behavior Guidelines

1. **Prefer Vitest-native imports** — import `describe`, `it`, `expect`, `vi`, etc. from `'vitest'`, not from `@jest/*` packages.
2. **Respect the existing config** — read `vitest.config.ts` or `vite.config.ts` before suggesting configuration changes.
3. **Match the project's test style** — check existing test files for naming conventions (`*.test.ts` vs `*.spec.ts`, `it` vs `test`) and follow them.
4. **Use `vi` for all mocking** — never suggest `jest.fn()`, `jest.mock()`, etc.
5. **Run tests to verify** — after writing or modifying tests, suggest running `npx vitest run` to confirm they pass.

## References Loading Guide

Load additional context files based on what the user needs:

| Situation | Load |
|-----------|------|
| Questions about `vitest.config.ts`, environments, globals, setupFiles | `references/config.md` |
| Questions about `describe`, `it`, `test`, `expect`, hooks | `references/api.md` |
| Questions about `vi.fn()`, `vi.mock()`, `vi.spyOn()`, timers, globals | `references/mocking.md` |
| Questions about coverage providers, thresholds, `--coverage` flag | `references/coverage.md` |

Read only what is relevant to the current question. Do not preload all files unless the user's question spans multiple areas.
