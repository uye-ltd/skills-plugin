---
name: py-verify-tests
description: Verify the quality and coverage of existing Python tests. Used by Reviewer Agent for Python tasks.
language: python
used-by: executor,reviewer
---

Assess the quality and completeness of the provided test suite.

Check:
- **Coverage**: are happy paths, error paths, and edge cases covered?
- **Assertions**: are assertions specific enough to catch real bugs?
- **Isolation**: are tests independent? do they share mutable state?
- **Mocking**: is mocking appropriate? are real behaviours being tested or just mock setups?
- **Naming**: do test names describe the scenario and expected outcome?
- **Flakiness**: any time-dependent, order-dependent, or environment-dependent tests?
- **Missing tests**: what is not tested that should be?

Output: coverage assessment + list of missing test scenarios with suggested test signatures.

$ARGUMENTS
