---
name: js-suggest-memoize
description: Identify memoisation opportunities in JavaScript or TypeScript code. Used by Performance Agent for JavaScript tasks.
language: javascript
used-by: performance
---

Identify where memoisation would improve performance.

Look for:
- Expensive pure functions called repeatedly with the same arguments → `useMemo` / `useCallback` / `memoize`
- Derived data recalculated on every render from stable inputs → `useMemo`
- Selector functions in Redux/Zustand/Jotai not using `createSelector`
- API responses not cached between identical requests
- Heavy computations in render paths (sorting, filtering large arrays)

For each opportunity:
1. The expensive computation and its location
2. What makes it safe to memoize (pure, stable inputs)
3. The correct hook or utility to use
4. Cache invalidation: when should the memoized value be recalculated?

$ARGUMENTS
