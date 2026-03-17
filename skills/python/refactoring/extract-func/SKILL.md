---
name: py-extract-func
description: Extract a block of Python code into a named function. Used by Refactorer Agent for Python tasks.
language: python
used-by: refactorer
---

Extract the specified code block into a well-named function.

Steps:
1. Identify inputs (variables read from outer scope) → become parameters
2. Identify outputs (variables written and used after the block) → become return values
3. Choose a name that describes what the function does, not how
4. Add full type annotations and a docstring
5. Replace the original block with a call to the new function
6. Verify the refactoring is behaviour-preserving

Show before and after. Confirm: does any existing test need to be updated?

$ARGUMENTS
