---
name: py-code-review
description: Review Python code for correctness, style, security, and design. Used by Reviewer Agent for Python tasks.
language: python
used-by: reviewer
---

Review the provided Python code across all dimensions:

- **Correctness**: bugs, edge cases, incorrect error handling, off-by-one errors
- **Style**: PEP 8, naming conventions, readability
- **Design**: SOLID principles, appropriate abstractions, unnecessary complexity
- **Performance**: inefficient algorithms, missing caching, unnecessary I/O
- **Security**: injection, insecure defaults, unsafe deserialization, secrets in code
- **Types**: missing annotations, use of `Any`, incorrect generics
- **Testability**: is the code structured to be testable?

## Python standards checklist

Check each category and flag violations at the appropriate severity:

**Structure & style:**
- [ ] Functions ≤ ~30 lines; classes ≤ ~100 lines
- [ ] Nesting depth ≤ 2 levels (guard clauses used)
- [ ] No unexpected side effects; business logic separated from I/O
- [ ] Comprehensions used for simple transforms; `enumerate` over index loops
- [ ] f-strings used; `pathlib` over `os.path`; context managers for resources
- [ ] Input arguments not mutated
- [ ] `__slots__` present in classes/dataclasses where appropriate
- [ ] Composition preferred over inheritance

**Imports:**
- [ ] All imports at top of module (no inline imports without justification)
- [ ] No wildcard imports (`from x import *`)
- [ ] Absolute imports everywhere except `__init__.py` re-exports
- [ ] No `from __future__ import annotations`
- [ ] Aliases only when widely accepted

**Naming:**
- [ ] Functions/methods start with a verb; classes are PascalCase nouns
- [ ] snake_case variables/attributes; UPPER_CASE module-level constants
- [ ] No single-letter names except `i`, `j` in loops
- [ ] No vague or abbreviated names

**Typing:**
- [ ] All public APIs annotated (parameters + return type)
- [ ] Built-in generics used (`list[str]`, `X | Y` unions)
- [ ] No unexplained `Any`
- [ ] Protocols preferred over inheritance for structural typing

**Docs:**
- [ ] One-line docstring on all public functions, methods, and classes
- [ ] Docstrings don't just restate the signature
- [ ] No module-level docstrings
- [ ] Inline comments only where logic isn't self-evident

**Exceptions:**
- [ ] Specific exception types only — no bare `except`
- [ ] No silent swallowing (`except: pass`)
- [ ] No exceptions used for control flow
- [ ] Custom types for domain errors; meaningful raise messages

**Async:**
- [ ] No blocking calls in async functions
- [ ] asyncio primitives used over threads
- [ ] `async with`/`async for` for resource cleanup

**Logging:**
- [ ] `logging` module used, not `print`
- [ ] `%` placeholders in log calls — no f-strings inside log statements

**Security:**
- [ ] No `pickle`/`eval`/`exec` on untrusted data

**Config:**
- [ ] No hardcoded config values or magic numbers

Output:
1. Summary (2–3 sentence overall assessment)
2. Issues table (severity: critical / major / minor / nit, file:line, description, suggestion)
3. Verdict: PASS | ITERATE | DEBUG

$ARGUMENTS
