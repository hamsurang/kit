# Vitest Configuration Reference

## Standalone `vitest.config.ts`

Use this when you want a dedicated config separate from your Vite app config:

```ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    // options here
  },
})
```

## Integrated in `vite.config.ts`

Add a `test` field directly to your existing Vite config — no separate file needed:

```ts
/// <reference types="vitest" />
import { defineConfig } from 'vite'

export default defineConfig({
  plugins: [...],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/setupTests.ts'],
  },
})
```

> The `/// <reference types="vitest" />` triple-slash directive gives TypeScript type information for the `test` field.

## Key Options

### `test.include`
Glob patterns for test files. Default: `['**/*.{test,spec}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}']`

```ts
include: ['src/**/*.test.ts']
```

### `test.exclude`
Glob patterns to exclude. Default includes `node_modules`, `dist`, `.idea`, `.git`, `.cache`.

```ts
exclude: ['**/node_modules/**', '**/e2e/**']
```

### `test.environment`
The test environment to use:

| Value | Use case |
|-------|----------|
| `'node'` (default) | Pure Node.js — server-side code, utilities |
| `'jsdom'` | Browser-like DOM APIs — React/Vue components |
| `'happy-dom'` | Faster DOM alternative to jsdom |
| `'edge-runtime'` | Vercel Edge Runtime APIs |

```ts
environment: 'jsdom'
```

Override per-file with a docblock comment:
```ts
// @vitest-environment jsdom
```

### `test.globals`
When `true`, injects `describe`, `it`, `expect`, etc. into every test file without explicit imports.

```ts
globals: true
```

Requires adding `"vitest/globals"` to `tsconfig.json` `compilerOptions.types`:
```json
{ "compilerOptions": { "types": ["vitest/globals"] } }
```

### `test.setupFiles`
Files to run before each test file. Use for global setup (e.g., `@testing-library/jest-dom` matchers):

```ts
setupFiles: ['./src/setupTests.ts']
```

### `test.globalSetup`
Files to run once before all test suites (outside the worker context — for DB setup, server start, etc.):

```ts
globalSetup: ['./test/globalSetup.ts']
```

### `test.testTimeout`
Default timeout per test in milliseconds (default: `5000`):

```ts
testTimeout: 10_000
```

## Watch Mode

Vitest runs in watch mode by default during development:

```bash
npx vitest           # watch
npx vitest run       # single run (CI)
npx vitest --watch   # explicit watch
```

Watch mode only re-runs tests affected by changed files (via Vite's module graph).
