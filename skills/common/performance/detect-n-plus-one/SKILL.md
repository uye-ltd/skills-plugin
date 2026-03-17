---
name: detect-n-plus-one
description: Detect N+1 query patterns in code. Used by Performance Agent to identify database or API call patterns that scale linearly with data size.
language: common
used-by: performance
---

Identify N+1 query (or N+1 call) patterns in the specified code.

An N+1 pattern occurs when:
1. A collection of N items is fetched
2. For each item, a separate query/call is made — resulting in N+1 total queries instead of 1

Steps:
1. Find all loops, list comprehensions, or map() calls
2. Inside each, check for database queries, ORM relationships, API calls, or file reads
3. Identify the collection being iterated and the per-item call
4. Assess whether the per-item call could be batched

For each N+1 found:
- **Location**: file and line range
- **Pattern**: what is being fetched N times
- **Fix**: the batching/prefetch strategy (e.g., `select_related`, `DataLoader`, `IN` query, bulk API call)
- **Estimated impact**: queries reduced from N+1 to ~1 (or 2)

$ARGUMENTS
