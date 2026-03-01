# Vitest Mocking Reference

All mocking utilities live on the `vi` object, imported from `'vitest'`:

```ts
import { vi } from 'vitest'
```

---

## `vi.fn()` — Mock Functions

Creates a mock function that records calls, arguments, and return values.

```ts
const mockFn = vi.fn()
mockFn('hello')

expect(mockFn).toHaveBeenCalled()
expect(mockFn).toHaveBeenCalledWith('hello')
expect(mockFn).toHaveBeenCalledTimes(1)
```

### Return values

```ts
const mockFn = vi.fn().mockReturnValue(42)
const mockAsync = vi.fn().mockResolvedValue({ data: 'ok' })
const mockOnce = vi.fn()
  .mockReturnValueOnce('first')
  .mockReturnValueOnce('second')
```

### Implementations

```ts
const mockFn = vi.fn().mockImplementation((x) => x * 2)
const mockOnce = vi.fn().mockImplementationOnce(() => 'one-time')
```

---

## `vi.mock()` — Module Mocking

Hoisted automatically to the top of the file (before imports). Replaces the entire module.

### Auto-mock (all exports become `vi.fn()`)

```ts
vi.mock('./myModule')
```

### Factory mock (control the shape)

```ts
vi.mock('./myModule', () => ({
  myFunction: vi.fn().mockReturnValue('mocked'),
  MyClass: vi.fn().mockImplementation(() => ({
    method: vi.fn(),
  })),
}))
```

### Partial mock (keep real implementation, override some)

```ts
vi.mock('./myModule', async (importOriginal) => {
  const real = await importOriginal<typeof import('./myModule')>()
  return {
    ...real,
    fetchData: vi.fn().mockResolvedValue({ mocked: true }),
  }
})
```

### `vi.unmock()` — Restore module

```ts
vi.unmock('./myModule')
```

---

## `vi.spyOn()` — Method Spies

Wraps an existing method to track calls while keeping the real implementation (unless overridden).

```ts
const spy = vi.spyOn(console, 'log')
console.log('hello')

expect(spy).toHaveBeenCalledWith('hello')
spy.mockRestore() // restore original implementation
```

### Override spy implementation

```ts
vi.spyOn(api, 'fetchUser').mockResolvedValue({ id: 1, name: 'Alice' })
```

---

## `vi.stubGlobal()` — Global Variable Mocking

Replace a global variable (e.g., `window`, `fetch`, `localStorage`):

```ts
vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
  json: () => Promise.resolve({ data: 'mocked' }),
}))

// restore after test
vi.unstubAllGlobals()
```

---

## Timer Control

### `vi.useFakeTimers()`
Replace `setTimeout`, `setInterval`, `Date`, etc. with fake implementations.

```ts
beforeEach(() => {
  vi.useFakeTimers()
})

afterEach(() => {
  vi.useRealTimers()
})

it('calls callback after 1 second', () => {
  const cb = vi.fn()
  setTimeout(cb, 1000)

  vi.advanceTimersByTime(1000) // jump time forward
  expect(cb).toHaveBeenCalledTimes(1)
})
```

### Timer utilities

```ts
vi.advanceTimersByTime(ms)   // advance time by ms
vi.advanceTimersToNextTimer() // run the next queued timer
vi.runAllTimers()             // run all pending timers
vi.runAllTimersAsync()        // run all pending async timers
vi.clearAllTimers()           // clear pending timers without running
```

### `vi.useRealTimers()`
Restore real timer implementations.

---

## Mock Reset / Restore

| Method | What it does |
|--------|-------------|
| `vi.clearAllMocks()` | Clears call history, instances, results — keeps implementation |
| `vi.resetAllMocks()` | Clears history + resets implementation to `vi.fn()` |
| `vi.restoreAllMocks()` | Restores all spies to their original implementations |

**Common pattern** — reset between tests without losing mock setup:

```ts
afterEach(() => {
  vi.clearAllMocks()
})
```

**Full reset** — start each test completely fresh:

```ts
afterEach(() => {
  vi.resetAllMocks()
})
```
