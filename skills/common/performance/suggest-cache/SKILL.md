---
name: suggest-cache
description: Identify caching opportunities in code. Used by Performance Agent to reduce repeated computation or I/O.
language: common
used-by: performance
---

Analyse the code for caching opportunities.

Look for:
- **Repeated computation**: the same value computed multiple times with the same inputs
- **Repeated I/O**: the same file, DB record, or API response fetched multiple times per request
- **Expensive pure functions**: functions with no side effects called repeatedly with identical arguments
- **Hot paths**: frequently called code that builds or transforms the same data

For each opportunity:
1. Identify the cache key (what varies across calls)
2. Identify the cache value (what is expensive to compute)
3. Assess staleness risk (can this safely be cached? for how long?)
4. Suggest the appropriate caching mechanism (in-memory, TTL, memoisation decorator, HTTP cache header, etc.)
5. Estimate the expected improvement

$ARGUMENTS
