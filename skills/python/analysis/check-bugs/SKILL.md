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
- Silent failures: `except: pass`, swallowed errors, ignored return values → **critical**
- Exceptions used for control flow (using exceptions as an expected code path)
- Off-by-one errors in slices and ranges
- Blocking calls in async functions: `time.sleep`, blocking file reads, `subprocess.run` without `asyncio.create_subprocess_*`, CPU-bound loops without `run_in_executor` → **critical**
- Unsafe deserialization: `pickle.loads`, `eval`, `exec` on any untrusted input path → **critical**
- f-strings inside logging calls (formatted even when log level is suppressed — latent performance issue)
- Non-deterministic logic: unseeded `random`, time-dependent assertions, environment-dependent behaviour
- Resource acquisition without cleanup (missing `with`, no `finally`)

Output: list of bugs by severity with file:line, description, and minimal fix snippet.

$ARGUMENTS
