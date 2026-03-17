# Contract: Performance Report

Produced by: Performance agent
Consumed by: Executor (if fixes requested), or end of pipeline (human review)

## Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| Profiling recommendation | yes | prose | Tool, command, and what to look for; always include even if fix seems obvious |
| Issues found | yes | table | Prioritised list; use "No issues found" if clean |
| Baseline metrics | no | prose | Current numbers if profiling was already run |
| Recommended action | yes | enum: MEASURE_FIRST, FIX_NOW | Whether to profile before changing code |

### Issues table columns

| Column | Required | Description |
|--------|----------|-------------|
| Priority | yes | 1 (high), 2 (med), 3 (low) |
| Issue | yes | Short name of the problem |
| Location | yes | file:line |
| Est. Impact | yes | Expected improvement (e.g. "-90% DB calls") |
| Fix | yes | Concrete change to make |
| How to verify | yes | Benchmark or measurement command |

### Recommended action values

- `MEASURE_FIRST`: issues are suspected but not confirmed — profile before changing code
- `FIX_NOW`: issue is confirmed and fix is clear (e.g. obvious N+1 in a loop)

## Invariants

- Performance agent must not optimise without measurement — always recommend profiling first
- Every suggested fix must include a way to verify improvement
- Correctness is non-negotiable: a faster but incorrect solution is not acceptable
- `FIX_NOW` is only appropriate for confirmed, obvious issues (e.g. O(n²) loop with a clear O(n) alternative)

## Example

```markdown
## Performance Report

### Profiling recommendation
Run `python -m cProfile -o profile.out src/ingest/process.py` then `snakeviz profile.out`.
Look for `process_row` — expected to dominate CPU time.

### Issues found
| Priority | Issue | Location | Est. Impact | Fix | How to verify |
|----------|-------|----------|-------------|-----|---------------|
| 1 (high) | N+1 query | src/ingest/process.py:88 | -95% DB calls | batch with `SELECT ... WHERE id IN (...)` | benchmark before/after with `pytest --benchmark` |
| 2 (med) | Repeated JSON parse | src/ingest/process.py:104 | -20% CPU | cache parsed result outside loop | cProfile before/after |

### Baseline metrics
`process_row` called 10,000× per run; total runtime 4.2s on staging dataset.

### Recommended action
FIX_NOW — N+1 pattern is confirmed; batching is safe and the fix is straightforward.
```
