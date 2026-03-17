---
name: py-extract-func
description: Extract a block of Python code into a named function. Used by Refactorer Agent for Python tasks.
language: python
used-by: refactorer
---

Extract the specified code block into a well-named function.

**Trigger conditions:** function > ~30 lines, multiple concerns in one function, nesting depth > 2 levels.

Steps:
1. Identify inputs (variables read from outer scope) → become parameters
2. Identify outputs (variables written and used after the block) → become return values
3. Choose a name that describes what the function does, not how — must start with a verb; be descriptive, not abbreviated
4. Add full type annotations using built-in generics (Python 3.13+) and a one-line docstring
5. Make any side effects explicit via parameters — do not rely on outer scope mutation
6. Replace the original block with a call to the new function
7. Verify the refactoring is behaviour-preserving

**Constraints on the extracted function:**
- ≤ ~30 lines
- Single concern
- Full type annotations (built-in generics: `list[str]`, `X | Y` unions)
- One-line docstring

Show before and after. Confirm: does any existing test need to be updated?

$ARGUMENTS
