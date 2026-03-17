---
name: py-check-async
description: Check Python async/await code for correctness. Used by Debugger Agent for Python async bugs.
language: python
used-by: debugger
---

Review the provided async Python code for concurrency and correctness issues.

Check for:
- Missing `await` on coroutine calls (returning coroutine objects instead of values)
- Blocking calls inside `async` functions: `time.sleep`, blocking file reads, `subprocess.run` without `asyncio.create_subprocess_*`, CPU-bound loops without `run_in_executor`
- `asyncio.sleep(0)` / yield points needed to prevent starvation
- Incorrect use of `asyncio.create_task` vs `await` (fire-and-forget vs sequential)
- `asyncio.gather` error handling (one failure silently cancelling others)
- Shared mutable state accessed from multiple coroutines without locks
- Missing `async with` / `async for` on async context managers and iterators — including `aiofiles`, async DB connections, HTTP client sessions
- Task cancellation not handled (missing `try/except asyncio.CancelledError`)
- `threading.Thread` / `ThreadPoolExecutor` used inside async code where asyncio primitives would suffice — flag as a design issue

For each issue: location, problem, and correct pattern.

$ARGUMENTS
