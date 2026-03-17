---
name: py-profile-hotspot
description: Identify Python performance hotspots and recommend profiling steps. Used by Performance Agent for Python tasks.
language: python
used-by: performance
---

Identify the most likely performance bottlenecks in the provided Python code and recommend how to measure them.

**Rule #0: Measure before optimising.** Do not suggest optimisations without profiling evidence. Always begin by recommending the appropriate profiling tool:
- CPU-bound: `cProfile` + `snakeviz`, or `py-spy` for live/sampling profiling
- Memory: `memory_profiler`, `tracemalloc`
- Async: `asyncio` debug mode

Static analysis:
- Flag O(n²) or worse loops
- Flag repeated function calls with identical arguments (memoisation candidates)
- Flag unnecessary object creation inside hot loops
- Flag redundant database/file/network calls

Profiling recommendations:
- For CPU-bound code: `cProfile` + `snakeviz`, or `py-spy` for live profiling
- For memory: `memory_profiler`, `tracemalloc`
- For async: `aiohttp-devtools`, `asyncio` debug mode

Output:
1. Static hotspot list with estimated impact
2. Profiling commands ready to run
3. What to look for in the profiling output

Also flag: hardcoded magic timeout/threshold values that could mask performance regressions (e.g. `timeout=30`, `max_retries=3` without named constants).

$ARGUMENTS
