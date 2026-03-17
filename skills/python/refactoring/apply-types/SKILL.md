---
name: py-apply-types
description: Add or improve type annotations in Python code. Used by Refactorer Agent for Python tasks.
language: python
used-by: refactorer
---

Add comprehensive type annotations to the provided Python code.

Target **Python 3.13+**. Use built-in generics, `X | Y` union syntax, and all modern type system features.

Guidelines:
1. Annotate all public function parameters and return types
2. Annotate class attributes
3. Use built-in generics: `list[str]` not `List[str]`, `dict[str, int]` not `Dict[str, int]`
4. Use `X | Y` union syntax — not `Union[X, Y]` or `Optional[X]`
5. Use `TypeVar`, `Generic`, `Protocol` for generic code — prefer Protocols over inheritance for structural typing
6. Use `TypedDict` for dict shapes, `NamedTuple` for named tuples
7. Avoid `Any` — if something is genuinely unknown, use `object` and explain
8. Do **not** add `from __future__ import annotations`. Resolve forward references with string literals (`"ClassName"`) or restructure the code
9. Avoid overly complex annotations that reduce readability
10. Note any places where the code structure makes typing hard and suggest how to fix

$ARGUMENTS
