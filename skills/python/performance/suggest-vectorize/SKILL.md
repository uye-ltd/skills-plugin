---
name: py-suggest-vectorize
description: Identify Python loops that can be replaced with vectorised NumPy/Pandas operations. Used by Performance Agent for Python tasks.
language: python
used-by: performance
---

Analyse the provided Python code for vectorisation opportunities.

**Precondition:** Only suggest vectorisation if a profiler (`cProfile`, `py-spy`, or equivalent) has confirmed this loop is a hotspot. If no profiling evidence is provided, include a profiling step first.

Look for:
- Python loops iterating over arrays, lists, or DataFrame rows that could use NumPy ufuncs
- `df.iterrows()` / `df.apply()` calls that could be vectorised column operations
- Element-wise operations implemented as loops (`for x in arr: result.append(x * 2)`)
- Nested loops on numerical data that could use broadcasting

For each opportunity:
1. Show the current loop-based code
2. Show the vectorised equivalent — include full type annotations on the vectorised version
3. Estimate the expected speedup (typical: 10–1000x for pure Python loops → NumPy)
4. Note any correctness constraints (NaN handling, dtype changes, etc.)
5. If the vectorised form significantly reduces readability, name intermediate results and add an explanatory comment

$ARGUMENTS
