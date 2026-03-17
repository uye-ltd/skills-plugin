---
name: py-verify-tests
description: Verify the quality and coverage of existing Python tests. Used by Reviewer Agent for Python tasks.
language: python
used-by: executor,reviewer
---

Assess the quality and completeness of the provided test suite.

Check:
- **Coverage**: are happy paths, error paths, and edge cases covered?
- **Assertions**: are assertions specific enough to catch real bugs? (e.g. `assert result == expected` not `assert result is not None`)
- **Isolation**: are tests independent? do they share mutable state?
- **Mocking**: is mocking appropriate? are real behaviours being tested or just mock setups?
- **Naming**: do test names follow `test_<function>_<scenario>_<expected>` — verb-first, descriptive?
- **Flakiness**: non-deterministic tests — time-dependent, random without seed, environment-dependent, order-dependent suites?
- **pytest.raises**: are exception types specific (concrete class) rather than broad base classes?
- **Missing tests**: what is not tested that should be?
- **Shared mutable state**: flag any fixtures or module-level variables that could bleed state between tests

Output: coverage assessment + list of missing test scenarios with suggested test signatures.

$ARGUMENTS
