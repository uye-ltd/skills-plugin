---
name: py-generate-func
description: Generate a Python function from a description or signature. Used by Executor Agent for Python tasks.
language: python
used-by: executor
---

Generate a well-structured Python function for the provided description or signature.

Requirements:
- Full type annotations on parameters and return type (Python 3.10+ syntax)
- Docstring (Google or NumPy style — match project convention)
- Input validation for public-facing functions
- Proper error handling with specific exception types
- Testable design: no hidden dependencies, side effects passed explicitly

Also generate a minimal usage example in a comment block.

$ARGUMENTS
