---
name: py-generate-class
description: Generate a Python class from a description or spec. Used by Executor Agent for Python tasks.
language: python
used-by: executor
---

Generate a well-structured Python class for the provided description.

**Approach:** Target Python 3.13+. Prefer the simplest correct solution. Think about edge cases and testability before writing.

**Structure:**
- Classes ≤ ~100 lines; if larger, split into smaller classes using composition
- Prefer composition over inheritance — use small, composable objects
- Use `@dataclass` or explicit `__init__` as appropriate
- Use `__slots__` in classes and dataclasses where possible (reduces memory and prevents accidental attribute creation)
- `__repr__` and `__eq__` if the class represents a value object
- No mutable default values in class attributes
- Dependency injection for external collaborators (passed via constructor, not instantiated inside)
- Business logic independent from I/O; pass dependencies explicitly

**Style:**
- Early returns / guard clauses over deep nesting (max 1–2 levels)
- Descriptive intermediate variables for complex expressions
- f-strings for string formatting
- `pathlib` over `os.path`
- Context managers for resource cleanup
- Do not mutate input arguments

**Typing:**
- Full type annotations on all attributes, parameters, and return types
- Built-in generics: `list[str]`, `dict[str, int]` — not `List[str]`, `Dict[str, int]`
- `X | Y` union syntax — not `Union[X, Y]` or `Optional[X]`
- Do not add `from __future__ import annotations`

**Naming:**
- PascalCase noun names for classes (`Order`, `InputValidator`)
- Verb-first names for methods (`process_order`, `validate_input`)
- snake_case for attributes
- Descriptive — no abbreviations or single-letter names except `i`, `j` in loops

**Docs:**
- One-line class docstring
- One-line docstring on all public methods
- No module-level docstrings
- Inline comments only where logic isn't self-evident

**Imports:**
- `__init__.py` re-exports use relative imports from the same package
- All other imports use absolute imports

**Exceptions:**
- Specific exception types — never bare `except`
- Meaningful raise messages; no silent failures
- Custom exception types for domain errors

**Async:**
- No blocking calls in async methods
- `async with` / `async for` for resource cleanup

**Logging:**
- Use the `logging` module — not `print`
- `%` placeholders in log calls — no f-strings inside log statements

**Constants & config:**
- Named constants for all magic numbers
- Config via config objects or env vars — never hardcoded values in the class

**Determinism:**
- No hidden randomness unless explicitly required

**Resources:**
- Always clean up (files, sockets, DB connections)
- Prefer context managers over manual `try/finally`

Include a minimal usage example.

$ARGUMENTS
