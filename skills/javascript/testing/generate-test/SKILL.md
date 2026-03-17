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

$ARGUMENTS
