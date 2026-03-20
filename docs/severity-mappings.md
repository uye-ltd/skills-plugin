# Severity Mappings

Used by: Reviewer agent (`agents/reviewer.md`), Review Report contract (`docs/contracts/review-report.md`)

## Severity levels

| Severity | Meaning |
|----------|---------|
| `critical` | Correctness bug, security issue, or broken contract |
| `major` | Design problem, missing error handling, poor testability |
| `minor` | Style, naming, missing docs |
| `nit` | Cosmetic, personal preference |

## Language-specific mappings

### JavaScript / TypeScript

| Pattern | Severity |
|---------|----------|
| Unhandled promise rejection (no `.catch()` or `try/catch`) | `critical` |
| XSS via unsanitized `innerHTML` / `dangerouslySetInnerHTML` | `critical` |
| Hardcoded secret, credential, or API key | `critical` |
| Silent error swallowing (`catch (e) {}` or catch that only logs) | `critical` |
| Missing `await` on async call (returns Promise instead of value) | `major` |
| TypeScript `any` used to bypass type checking | `major` |
| `==` instead of `===` (type coercion) | `major` |
| React stale closure or missing `useEffect` dependency | `major` |
| Naming convention violations | `minor` |
| Style violations | `nit` |

### Python

| Pattern | Severity |
|---------|----------|
| Any security violation (unsafe deserialization, injection, hardcoded secrets) | `critical` |
| Any blocking call in async code | `critical` |
| Silent exception swallowing (`except: pass`) | `critical` |
| Missing type annotations on public API | `major` |
| Calls to undocumented/private library APIs | `major` |
| Naming violations | `minor` |
| Style violations | `nit` |

### Go

| Pattern | Severity |
|---------|----------|
| Ignored error return value | `critical` |
| Goroutine leak (no exit path) | `critical` |
| Data race (shared state without sync) | `critical` |
| Any security violation (`unsafe` without justification, hardcoded secrets, unvalidated inputs) | `critical` |
| Silent error swallowing | `critical` |
| Error not wrapped with context (`%w`) | `major` |
| Exported symbol missing godoc | `major` |
| Interface defined at producer instead of consumer | `major` |
| Naming violations (wrong casing, stutter, `self`/`this` receiver) | `minor` |
| Style violations | `nit` |
