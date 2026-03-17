---
name: js-verify-tests
description: Verify the quality and coverage of existing JavaScript or TypeScript tests. Used by Reviewer Agent for JavaScript tasks.
language: javascript
used-by: executor,reviewer
---

Assess the quality and completeness of the provided test suite.

Check:
- **Coverage**: happy paths, error paths, edge cases, async flows
- **Assertions**: specific enough to catch real bugs (not just `toBeTruthy`)
- **Component tests**: testing user behaviour, not implementation details
- **Mocking**: appropriate use — are real behaviours being tested?
- **Async handling**: all promises awaited; rejected cases tested
- **Flakiness**: time-dependent, order-dependent, or environment-dependent tests
- **Missing tests**: what is not tested that should be

**Anti-patterns to flag:**
- Assertions using only `toBeTruthy()` / `toBeDefined()` without specific value checks
- Missing `expect.assertions(n)` in async tests (swallowed rejections silently pass)
- Tests patching module internals with `jest.spyOn` on private methods instead of injecting via interfaces
- Test descriptions that are vague ("should work", "test 1", "handles case")
- `beforeAll` shared mutable state that creates test inter-dependencies
- Non-deterministic tests: `Date.now()`, `Math.random()`, or network calls without mocking

Output: coverage assessment + list of missing test scenarios with suggested test signatures.

$ARGUMENTS
