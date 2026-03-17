# Contract: Context Summary

**Producer**: Context agent
**Consumer**: Planner agent

## Purpose

A structured snapshot of all codebase knowledge relevant to the current task. The Planner uses this to build an implementation plan without needing to re-read files.

## Schema

```markdown
## Context Summary

### Language
<value from Routing Block>

### Files involved
- <relative/path/to/file.ext>: <one-line purpose>

### Key symbols
- `<SymbolName>`: defined in `<file>:<line>`, used by `<caller1>`, `<caller2>`

### Relevant API surface
<extracted public interface — signatures, types, contracts>

### Dependencies and constraints
<anything that limits what can be changed: interfaces, contracts, backwards compat requirements>

### Open questions
<anything ambiguous that the Planner must resolve before acting>
```

## Field rules

| Section | Required | Notes |
|---------|----------|-------|
| Language | yes | Copied from Routing Block |
| Files involved | yes | At least one entry |
| Key symbols | yes if symbols are relevant | Omit if no specific symbols involved |
| Relevant API surface | yes if public interface is affected | |
| Dependencies and constraints | yes | Use "None identified" if none |
| Open questions | yes | Use "None" if none |

## Invariants

- Context Agent must not make any code changes — read only
- All file references must use relative paths from the project root
- If a file is too large to summarise fully, note which sections were skipped and why
