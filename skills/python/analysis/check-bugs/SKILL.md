---
name: py-check-bugs
description: Check Python code specifically for bugs and correctness issues. Used by Reviewer and Debugger agents for Python tasks.
language: python
used-by: reviewer
---

Perform a correctness-focused scan of the provided Python code.

Check for:
- Logic bugs and incorrect conditional branches
- Mutable default arguments (`def f(x=[])`)
- Incorrect use of `is` vs `==` for value comparison
- Unhandled exceptions and overly broad `except` clauses
- Resource leaks (files, connections not closed — missing `with` statements)
- Incorrect async/await usage (missing `await`, sync calls in async context)
- Thread-safety issues (shared mutable state without locks)
- Silent failures (bare `except: pass`, ignored return values)
- Off-by-one errors in slices and ranges

Output: list of bugs by severity with file:line, description, and minimal fix snippet.

$ARGUMENTS
