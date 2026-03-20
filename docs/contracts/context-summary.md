# Contract: Context Summary

Produced by: Context agent
Consumed by: Planner agent (or Executor if skipPlanner=true)

## Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| Language | yes | enum: python, javascript, go | Copied from Routing Block |
| Files involved | yes | list | At least one entry: `path: one-line purpose` |
| Files noted but not read | conditional | list | Files over `contextMaxFiles` limit; `path: why skipped` |
| Key symbols | conditional | list | Required when specific symbols are relevant; omit if none |
| Relevant API surface | conditional | prose | Required when public interface is affected |
| Dependencies and constraints | yes | prose | Use "None identified" if none |
| Open questions | yes | prose | Use "None" if none |

## Multi-language variant

For multi-language tasks, produce one labeled section per language followed by a shared cross-language section:

```
### [Go] Language / [Go] Files involved / … / [Go] Open questions
### [JavaScript] Language / [JavaScript] Files involved / … / [JavaScript] Open questions
### Cross-language dependencies
<shared API contracts, data formats, or interface boundaries between the two languages>
```

Each per-language section has the same fields as the single-language variant. The cross-language section is required when the languages share a boundary (REST API, shared schema, etc.).

## Invariants

- Context Agent must not make any code changes — read only
- All file references must use relative paths from the project root
- If a file is too large to summarise fully, note which sections were skipped and why
- Language value must be copied verbatim from the Routing Block
- Files over `contextMaxFiles` must appear in `Files noted but not read` — never silently omitted

## Example

```markdown
## Context Summary

### Language
python

### Files involved
- src/auth/login.py: handles login form submission and session creation
- src/auth/models.py: User model definition with password hashing

### Key symbols
- `User.authenticate`: defined in `src/auth/models.py:34`, used by `src/auth/login.py:12`
- `hash_password`: defined in `src/auth/utils.py:5`, used by `src/auth/models.py:40`

### Relevant API surface
`User.authenticate(username: str, password: str) -> Optional[User]`
Returns None on failure; raises ValueError if username is empty.

### Dependencies and constraints
- Must not break existing session token format (backwards compat with mobile clients)
- `bcrypt` version pinned to 4.0.x in pyproject.toml

### Open questions
- Should failed login attempts be rate-limited? Planner should decide before adding the endpoint.
```
