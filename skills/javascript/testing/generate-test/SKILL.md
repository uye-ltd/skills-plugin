---
name: js-generate-test
description: Write Jest or Vitest tests for JavaScript or TypeScript code. Used by Executor Agent for JavaScript tasks.
language: javascript
used-by: executor,reviewer
---

Write comprehensive tests for the provided code.

Guidelines:
- Use Jest (default) or Vitest if already in the project
- Use `@testing-library/react` (or relevant library) for component tests
- Prefer Testing Library queries over implementation details
- Mock external dependencies with `jest.mock` / `vi.mock`; avoid over-mocking
- Structure: `describe` by unit, `it`/`test` by scenario
- Cover: happy paths, error states, edge cases, async flows
- For async: `async/await`; test both resolved and rejected cases
- Tests must be deterministic: mock `Date`, `Math.random`, and timers — no implicit external state
- `it`/`test` names describe scenario and expected outcome, not the implementation ("should work" → bad)
- Use `expect.assertions(n)` or `expect.hasAssertions()` for async tests to catch swallowed rejections
- Inline comments explain *why* an edge case is tested, not *what* the test does
- Use `beforeEach` to reset mocks; never rely on test execution order

$ARGUMENTS
