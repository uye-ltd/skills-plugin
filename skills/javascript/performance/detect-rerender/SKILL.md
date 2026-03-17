---
name: js-detect-rerender
description: Detect unnecessary React re-renders. Used by Performance Agent for JavaScript tasks.
language: javascript
used-by: performance
---

Identify components that re-render more than necessary.

**Precondition:** Require React DevTools Profiler evidence before recommending memoization — do not suggest `React.memo` / `useMemo` / `useCallback` without profiler data showing unnecessary renders.

Look for:
- Objects or arrays created inline in JSX (`style={{ }}`, `value={[]}`) — new reference every render
- Functions defined inline in JSX (`onClick={() => ...}`) without `useCallback`
- Context providers whose `value` is a new object on every render
- Components that receive the same prop values but re-render anyway (candidates for `React.memo`)
- `useEffect` with missing or too-broad dependency arrays
- State updates that trigger parent re-renders unnecessarily (state lifted too high)

For each issue:
1. Location of the unnecessary re-render
2. Why it re-renders
3. Fix (memoisation strategy, state restructuring, or context split)
4. How to verify with React DevTools Profiler

$ARGUMENTS
