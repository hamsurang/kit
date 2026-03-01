# Vitest API Reference

Import from `'vitest'`:

```ts
import { describe, it, test, expect, beforeAll, afterAll, beforeEach, afterEach } from 'vitest'
```

---

## Describe API

### `describe(name, fn)`
Groups related tests into a suite.

```ts
describe('Calculator', () => {
  it('adds numbers', () => { ... })
  it('subtracts numbers', () => { ... })
})
```

### `describe.only(name, fn)`
Only runs this suite (and other `.only` suites) in the file.

```ts
describe.only('focused suite', () => { ... })
```

### `describe.skip(name, fn)`
Skips this suite.

```ts
describe.skip('not ready yet', () => { ... })
```

### `describe.each(table)(name, fn)`
Runs the suite once per row in `table`.

```ts
describe.each([
  { input: 1, expected: 2 },
  { input: 2, expected: 4 },
])('double($input)', ({ input, expected }) => {
  it('returns doubled value', () => {
    expect(double(input)).toBe(expected)
  })
})
```

---

## Test API

`it` and `test` are aliases.

### `it(name, fn, timeout?)`
Defines a single test case.

```ts
it('returns the correct sum', () => {
  expect(add(2, 3)).toBe(5)
})
```

### `it.only` / `test.only`
Only run this test in the file.

### `it.skip` / `test.skip`
Skip this test (shown as pending in output).

### `it.todo`
Placeholder for a test not yet written — shows in output as a reminder.

```ts
it.todo('handle negative numbers')
```

### `it.each(table)(name, fn)`
Run the same test with different inputs.

```ts
it.each([
  [1, 2, 3],
  [0, 0, 0],
])('add(%i, %i) = %i', (a, b, expected) => {
  expect(add(a, b)).toBe(expected)
})
```

---

## Expect API (Matchers)

### Equality

```ts
expect(value).toBe(2)           // strict equality (===)
expect(value).toEqual({ a: 1 }) // deep equality (recursive)
expect(value).toStrictEqual(obj) // deep equality + checks undefined properties
```

### Truthiness

```ts
expect(value).toBeTruthy()
expect(value).toBeFalsy()
expect(value).toBeNull()
expect(value).toBeUndefined()
expect(value).toBeDefined()
```

### Numbers

```ts
expect(n).toBeGreaterThan(3)
expect(n).toBeGreaterThanOrEqual(3)
expect(n).toBeLessThan(10)
expect(n).toBeCloseTo(0.3, 5) // floating point: 5 decimal digits
```

### Strings & Arrays

```ts
expect(str).toContain('substring')
expect(arr).toContain(item)
expect(arr).toHaveLength(3)
expect(str).toMatch(/regex/)
```

### Objects

```ts
expect(obj).toHaveProperty('key')
expect(obj).toHaveProperty('nested.key', 'value')
expect(obj).toMatchObject({ partial: 'match' }) // subset match
```

### Errors

```ts
expect(() => fn()).toThrow()
expect(() => fn()).toThrow('error message')
expect(() => fn()).toThrow(TypeError)
```

### Async

```ts
await expect(promise).resolves.toBe('value')
await expect(promise).rejects.toThrow('error')
```

### Snapshots

```ts
expect(value).toMatchSnapshot()         // creates/compares a snapshot file
expect(value).toMatchInlineSnapshot()   // snapshot stored in the test file
```

### Negation

Prefix any matcher with `.not`:

```ts
expect(value).not.toBe(0)
expect(arr).not.toContain('foo')
```

---

## Hooks

Hooks run setup and teardown around tests.

### `beforeAll(fn, timeout?)` / `afterAll(fn, timeout?)`
Run once before/after all tests in the current suite.

```ts
beforeAll(async () => {
  await db.connect()
})

afterAll(async () => {
  await db.disconnect()
})
```

### `beforeEach(fn, timeout?)` / `afterEach(fn, timeout?)`
Run before/after each individual test.

```ts
beforeEach(() => {
  store.reset()
})

afterEach(() => {
  vi.clearAllMocks()
})
```

Hooks are scoped to the `describe` block they are in. Top-level hooks apply to all tests in the file.
