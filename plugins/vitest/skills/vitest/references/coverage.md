# Vitest Coverage Reference

## Provider Options

Vitest supports two coverage providers:

| Provider | Package | Notes |
|----------|---------|-------|
| `v8` | built-in (no extra install) | Uses Node.js V8 engine's native coverage — fast, no instrumentation overhead |
| `istanbul` | `@vitest/coverage-istanbul` | Mature, widely used — better browser/non-Node support |

### Install a provider

```bash
# v8 (recommended for Node.js projects)
npm install -D @vitest/coverage-v8

# istanbul
npm install -D @vitest/coverage-istanbul
```

---

## Configuration

Add a `coverage` block inside `test` in `vitest.config.ts`:

```ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',           // or 'istanbul'
      reporter: ['text', 'html', 'lcov'],
      reportsDirectory: './coverage',
      include: ['src/**/*.ts'],
      exclude: [
        'src/**/*.d.ts',
        'src/**/*.test.ts',
        'src/index.ts',
      ],
    },
  },
})
```

---

## Thresholds

Fail the test run if coverage drops below the specified percentage:

```ts
coverage: {
  provider: 'v8',
  thresholds: {
    lines: 80,
    functions: 80,
    branches: 70,
    statements: 80,
  },
},
```

Vitest exits with a non-zero code if any threshold is not met — useful for CI enforcement.

---

## Reporter Options

| Reporter | Output |
|----------|--------|
| `'text'` | Summary table in terminal |
| `'text-summary'` | Compact one-line summary |
| `'html'` | Interactive HTML report in `./coverage/` |
| `'lcov'` | `lcov.info` file — for Codecov, Coveralls, SonarQube |
| `'json'` | `coverage-final.json` — for custom processing |
| `'clover'` | XML for some CI systems |

Specify multiple reporters:

```ts
reporter: ['text', 'html', 'lcov']
```

---

## Exclude Patterns

Use glob patterns to exclude files from coverage collection:

```ts
exclude: [
  'node_modules/**',
  'dist/**',
  '**/*.d.ts',
  '**/*.config.{ts,js}',
  '**/__mocks__/**',
  '**/index.ts',      // barrel files
]
```

---

## CLI Usage

```bash
# Run tests with coverage
npx vitest run --coverage

# Watch mode with coverage
npx vitest --coverage

# Specify provider via CLI
npx vitest run --coverage --coverage.provider=v8
```

---

## `all` Option

Include files that have zero tests (not just files that were imported):

```ts
coverage: {
  provider: 'v8',
  all: true,
  include: ['src/**/*.ts'],
}
```

Without `all: true`, files that are never imported during tests won't appear in the coverage report.
