---
name: py-remove-dup
description: Remove duplicated code in Python by extracting shared logic. Used by Refactorer Agent for Python tasks.
language: python
used-by: refactorer
---

Identify and eliminate code duplication in the specified code.

Steps:
1. Find duplicate or near-duplicate code blocks
2. Before introducing a new abstraction, check if an existing one can be extended to cover the duplication
3. Determine the simplest abstraction that removes the duplication (shared function, base class, mixin, decorator, or context manager)
4. Prefer composition over inheritance when the extracted abstraction is a class
5. Extract the shared logic with appropriate parameters for the varying parts
6. Make the change minimal and targeted — do not restructure surrounding code
7. Replace all duplicate sites with calls to the extracted abstraction
8. Verify behaviour is preserved at all call sites

For each duplication: show location, what varies, proposed abstraction name, and the before/after.

$ARGUMENTS
