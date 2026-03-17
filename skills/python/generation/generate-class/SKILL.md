---
name: py-generate-class
description: Generate a Python class from a description or spec. Used by Executor Agent for Python tasks.
language: python
used-by: executor
---

Generate a well-structured Python class for the provided description.

Requirements:
- Use `@dataclass` or explicit `__init__` as appropriate
- Type annotations on all attributes and methods
- Docstring on class and public methods
- `__repr__` and `__eq__` if the class represents a value object
- No mutable default values in class attributes
- Dependency injection for external collaborators (passed via constructor, not instantiated inside)

Include a minimal usage example.

$ARGUMENTS
