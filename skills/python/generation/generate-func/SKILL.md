---
name: py-generate-func
description: Generate a Python function from a description or signature. Used by Executor Agent for Python tasks.
language: python
used-by: executor
---

Generate a well-structured Python function for the provided description or signature.

**Approach:** Target Python 3.13+. Prefer the simplest correct solution. Think about edge cases and testability before writing.

**Structure:**
- Functions ≤ ~30 lines, single concern
- No unexpected side effects; make side effects explicit via parameters
- Business logic independent from I/O
- Use dependency injection — pass dependencies as parameters, never instantiate inside

**Style:**
- Early returns / guard clauses over deep nesting (max 1–2 levels)
- Descriptive intermediate variables for complex expressions
- f-strings for string formatting
- `pathlib` over `os.path`
- `enumerate` over index loops
- Context managers for resource cleanup
- Do not mutate input arguments
- Walrus operator only for simple conditional assignments

**Typing:**
- Full type annotations on all parameters and return type
- Built-in generics: `list[str]`, `dict[str, int]` — not `List[str]`, `Dict[str, int]`
- `X | Y` union syntax — not `Union[X, Y]` or `Optional[X]`
- Do not add `from __future__ import annotations`

**Naming:**
- Verb-first names (`process_order`, `validate_input`)
- snake_case
- Descriptive — no abbreviations or single-letter names except `i`, `j` in loops

**Docs:**
- One-line docstring for all public functions
- Concise — don't repeat what the signature already shows
- Inline comments only where logic isn't self-evident

**Exceptions:**
- Specific exception types — never bare `except`
- Meaningful raise messages
- No silent failures (`except: pass`)
- No exceptions for control flow
- Custom exception types for domain errors

**Async:**
- No blocking calls in async functions (`time.sleep`, blocking I/O, CPU-bound loops)
- Use asyncio primitives over threads
- `async with` / `async for` for resource cleanup

**Logging:**
- Use the `logging` module — not `print`
- `%` placeholders in log calls — no f-strings inside log statements (avoids formatting overhead when suppressed)

**Constants & config:**
- Named constants for all magic numbers
- Config via config objects or env vars — never hardcoded values

**Determinism:**
- No hidden randomness unless explicitly required by the function's contract

**Resources:**
- Always clean up (files, sockets, DB connections)
- Prefer context managers over manual `try/finally`

Also generate a minimal usage example in a comment block.

$ARGUMENTS
