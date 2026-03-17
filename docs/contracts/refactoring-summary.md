# Contract: Refactoring Summary

**Producer**: Refactorer agent
**Consumer**: End of pipeline (human review)

## Purpose

A record of all refactoring operations applied, confirming that behaviour was preserved and tests still pass.

## Schema

```markdown
## Refactoring Summary

### Operations applied
1. `<operation-type>`: `<file>` — <rationale>
2. ...

### Operation types used
- [ ] extract-func
- [ ] split-module
- [ ] remove-dup
- [ ] rename-sym
- [ ] apply-types / add-types
- [ ] other: <describe>

### Preserved interfaces
- `<ExportedSymbol>`: signature unchanged ✓
- `<ExportedSymbol>`: signature changed — <migration note>

### Behaviour preservation
- [ ] No logic changes — refactoring only
- [ ] All existing tests pass
- [ ] No new public API added or removed (or change is intentional and documented)

### Follow-up recommendations
<optional: design issues observed that are out of scope for this refactor>
```

## Invariants

- Refactorer must not change observable behaviour — only structure
- Each operation must be listed; no silent changes
- If a public interface must change, it must be flagged in "Preserved interfaces" with a migration note
- Tests must pass after each individual operation, not just at the end
