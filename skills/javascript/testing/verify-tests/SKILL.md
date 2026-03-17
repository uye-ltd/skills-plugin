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

Output: coverage assessment + list of missing test scenarios with suggested test signatures.

$ARGUMENTS
