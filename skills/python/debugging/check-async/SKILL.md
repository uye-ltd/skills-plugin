---
name: py-check-async
description: Check Python async/await code for correctness. Used by Debugger Agent for Python async bugs.
language: python
used-by: debugger
---

Review the provided async Python code for concurrency and correctness issues.

Check for:
- Missing `await` on coroutine calls (returning coroutine objects instead of values)
- Sync I/O called inside `async` functions (blocking the event loop)
- `asyncio.sleep(0)` / yield points needed to prevent starvation
- Incorrect use of `asyncio.create_task` vs `await` (fire-and-forget vs sequential)
- `asyncio.gather` error handling (one failure silently cancelling others)
- Shared mutable state accessed from multiple coroutines without locks
- Missing `async with` / `async for` on async context managers and iterators
- Task cancellation not handled (missing `try/except asyncio.CancelledError`)

For each issue: location, problem, and correct pattern.

$ARGUMENTS
