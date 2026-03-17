---
name: py-generate-test
description: Write pytest tests for Python code. Used by Executor Agent for Python tasks.
language: python
used-by: executor,reviewer
---

Write comprehensive pytest tests for the provided code.

Guidelines:
- Use pytest conventions; `unittest.mock` for mocking
- Structure: arrange / act / assert
- Name tests: `test_<function>_<scenario>_<expected>` — verb-first, descriptive, not abbreviated
- Cover: happy paths, edge cases, error/exception paths, boundary values
- Use `@pytest.mark.parametrize` for multiple scenarios
- Use fixtures for shared setup; keep fixtures minimal
- For async code use `pytest-asyncio`
- Prefer real dependencies over mocks where practical
- Use dependency injection in test setup — pass dependencies explicitly, never rely on global state
- Tests must be deterministic: no unseeded random data, no time-dependent assertions, no order-dependent test suites
- `pytest.raises` must specify a concrete exception type, not a base class (e.g. `pytest.raises(ValueError)` not `pytest.raises(Exception)`)
- Inline comments explain *why* an edge case is tested, not *what* the test does

Include any `conftest.py` additions needed.

$ARGUMENTS
