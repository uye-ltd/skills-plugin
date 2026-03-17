---
name: py-generate-test
description: Write pytest tests for Python code. Used by Executor Agent for Python tasks.
language: python
used-by: executor,reviewer
---

Write comprehensive pytest tests for the provided code.

Guidelines:
- Use pytest conventions; `testify/mock` or `unittest.mock` for mocking
- Structure: arrange / act / assert
- Name tests: `test_<function>_<scenario>_<expected>`
- Cover: happy paths, edge cases, error/exception paths, boundary values
- Use `@pytest.mark.parametrize` for multiple scenarios
- Use fixtures for shared setup; keep fixtures minimal
- For async code use `pytest-asyncio`
- Prefer real dependencies over mocks where practical

Include any `conftest.py` additions needed.

$ARGUMENTS
