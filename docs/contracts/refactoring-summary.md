# Contract: Refactoring Summary

Produced by: Refactorer agent
Consumed by: End of pipeline (human review)

## Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| Operations applied | yes | ordered list | Each operation: `type: file — rationale` |
| Operation types used | yes | checklist | Check all operation types applied |
| Preserved interfaces | yes | list | Each exported symbol: unchanged ✓ or changed with migration note |
| Behaviour preservation | yes | checklist | All three items must be checked |
| Follow-up recommendations | no | prose | Out-of-scope design issues observed |

### Valid operation types

`extract-func`, `split-module`, `remove-dup`, `rename-sym`, `apply-types` / `add-types`, `other: <describe>`

## Invariants

- Refactorer must not change observable behaviour — only structure
- Each operation must be listed; no silent changes
- If a public interface must change, it must be flagged in "Preserved interfaces" with a migration note
- Tests must pass after each individual operation, not just at the end

## Example

```markdown
## Refactoring Summary

### Operations applied
1. `extract-func`: `src/auth/login.py` — extracted `_build_session()` from `handle_login()` to isolate session creation logic
2. `remove-dup`: `src/auth/login.py`, `src/auth/oauth.py` — deduplicated `_hash_token()` into `src/auth/utils.py`

### Operation types used
- [x] extract-func
- [ ] split-module
- [x] remove-dup
- [ ] rename-sym
- [ ] apply-types / add-types

### Preserved interfaces
- `handle_login`: signature unchanged ✓
- `_hash_token`: moved to utils.py — callers in login.py and oauth.py updated to import from new location

### Behaviour preservation
- [x] No logic changes — refactoring only
- [x] All existing tests pass
- [x] No new public API added or removed

### Follow-up recommendations
`handle_login` is still 80 lines — consider splitting the validation and persistence steps in a future pass.
```
