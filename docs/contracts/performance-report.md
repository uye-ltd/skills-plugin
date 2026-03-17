# Contract: Performance Report

**Producer**: Performance agent
**Consumer**: Executor (if fixes requested), or end of pipeline (human review)

## Purpose

A prioritised list of performance issues with measurable improvements and profiling guidance. Performance agent does not implement fixes unless explicitly asked.

## Schema

```markdown
## Performance Report

### Profiling recommendation
<tool and command to run before making any changes>
<what to look for in the output>

### Issues found
| Priority | Issue | Location | Est. Impact | Fix | How to verify |
|----------|-------|----------|-------------|-----|---------------|
| 1 (high) | N+1 query | file:line | -90% DB calls | batch with IN query | benchmark before/after |
| 2 (med)  | ...   | ...      | ...         | ... | ...           |

### Baseline metrics
<if profiling was already run, record current numbers here>

### Recommended action
MEASURE_FIRST | FIX_NOW

- `MEASURE_FIRST`: issues are suspected but not confirmed — profile before changing code
- `FIX_NOW`: issue is confirmed and fix is clear (e.g. obvious N+1 in a loop)
```

## Field rules

| Section | Required | Notes |
|---------|----------|-------|
| Profiling recommendation | yes | Always include — even if fix seems obvious |
| Issues found | yes | Use "No issues found" if clean |
| Baseline metrics | no | Include if profiling was already done |
| Recommended action | yes | |

## Invariants

- Performance agent must not optimise without measurement — always recommend profiling first
- Every suggested fix must include a way to verify improvement
- Correctness is non-negotiable: a faster but incorrect solution is not acceptable
- `FIX_NOW` is only appropriate for confirmed, obvious issues (e.g. O(n²) loop with a clear O(n) alternative)
