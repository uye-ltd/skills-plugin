---
name: py-detect-bugs
description: Scan Python code for bugs without a specific error to start from. Used by Debugger Agent for proactive bug detection in Python.
language: python
used-by: debugger
---

Perform a bug-focused scan of the provided Python code.

Look specifically for:
- Logic errors in conditionals and loops
- Off-by-one errors
- Incorrect handling of `None` / empty collections
- Mutable default arguments
- Incorrect use of `is` vs `==`
- Unhandled exception cases
- Resource leaks (missing `with` / `close()`)
- Data races in async or threaded code
- Incorrect string/bytes handling
- Silent failures (empty `except` blocks, ignored return values)
- Non-deterministic logic: unseeded `random`, time-dependent behaviour, assumptions about `dict` ordering (Python < 3.7)
- Calls to private/internal APIs (`_method`) or deprecated functions
- `pickle`, `eval`, `exec` on untrusted inputs → **critical**
- f-strings inside logging calls (formatted even when log level is suppressed)
- Hardcoded config values or credentials that could cause production bugs

For each bug: file:line, description of the bug, why it's a problem, and a minimal fix.

$ARGUMENTS
