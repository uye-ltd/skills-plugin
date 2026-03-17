---
name: py-profile-hotspot
description: Identify Python performance hotspots and recommend profiling steps. Used by Performance Agent for Python tasks.
language: python
used-by: performance
---

Identify the most likely performance bottlenecks in the provided Python code and recommend how to measure them.

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

$ARGUMENTS
