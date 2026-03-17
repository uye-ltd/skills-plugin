---
name: py-apply-types
description: Add or improve type annotations in Python code. Used by Refactorer Agent for Python tasks.
language: python
used-by: refactorer
---

Add comprehensive type annotations to the provided Python code.

Guidelines:
- Use Python 3.10+ syntax: `X | Y` over `Union[X, Y]`, `list[str]` over `List[str]`
- Annotate all function parameters and return types
- Annotate class attributes
- Use `TypeVar`, `Generic`, `Protocol` for generic code
- Use `TypedDict` for dict shapes, `NamedTuple` for named tuples
- Avoid `Any` — if something is genuinely unknown, use `object` and explain
- Add `from __future__ import annotations` if needed for forward references
- Note any places where the code structure makes typing hard and suggest how to fix

$ARGUMENTS
