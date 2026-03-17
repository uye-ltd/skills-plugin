---
name: py-remove-dup
description: Remove duplicated code in Python by extracting shared logic. Used by Refactorer Agent for Python tasks.
language: python
used-by: refactorer
---

Identify and eliminate code duplication in the specified code.

Steps:
1. Find duplicate or near-duplicate code blocks
2. Determine the common abstraction (shared function, base class, mixin, decorator, or context manager)
3. Extract the shared logic with appropriate parameters for the varying parts
4. Replace all duplicate sites with calls to the extracted abstraction
5. Verify behaviour is preserved at all call sites

For each duplication: show location, what varies, proposed abstraction name, and the before/after.

$ARGUMENTS
