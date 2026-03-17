---
name: go-code-review
description: Review Go code for correctness, idiomatic style, and design. Used by Reviewer Agent for Go tasks.
language: go
used-by: reviewer
---

Review the provided Go code:

- **Correctness**: logic bugs, nil pointer risks, errors ignored or swallowed
- **Error handling**: errors wrapped with `fmt.Errorf("...: %w", err)`, sentinel errors used correctly
- **Idiomatic Go**: Effective Go and Go Code Review Comments compliance
- **Concurrency**: goroutine leaks, race conditions, incorrect channel/sync usage
- **Interfaces**: defined at consumer, minimal surface, named after behaviour
- **Performance**: unnecessary allocations, inefficient slice/map usage
- **Security**: unsafe package, unvalidated inputs, injection risks

## Go standards checklist

**Error handling:**
- [ ] All error returns checked (no `_` discard without justification)
- [ ] Errors wrapped with `fmt.Errorf("...: %w", err)` at each call hop
- [ ] Sentinel errors used for matchable conditions
- [ ] Custom error types for structured domain errors
- [ ] No silent swallowing

**Structure:**
- [ ] Functions ≤ ~30 lines; single concern
- [ ] No `init()` without justification
- [ ] No global mutable state
- [ ] No panic for expected errors
- [ ] Business logic independent from I/O

**Interfaces:**
- [ ] Defined at consumer, not producer
- [ ] Minimal (single-method preferred)
- [ ] Named after behaviour; `-er` suffix where appropriate
- [ ] No stutter in exported names

**Naming:**
- [ ] Exported UpperCamelCase; unexported lowerCamelCase
- [ ] Package names: short, lowercase, no underscores
- [ ] Acronyms: consistent (all-caps or all-lowercase)
- [ ] Receiver names: 1–2 letters, not `self`/`this`
- [ ] No vague or abbreviated names

**Docs:**
- [ ] Every exported symbol has godoc starting with symbol name
- [ ] `doc.go` present for complex packages

**Concurrency:**
- [ ] Every goroutine has a defined exit path
- [ ] `context.Context` first param for I/O functions
- [ ] No mutex/WaitGroup copied by value
- [ ] `-race` flag recommended for concurrent tests

**Imports:**
- [ ] goimports grouping (stdlib → external → internal)
- [ ] No dot imports outside tests
- [ ] `_` imports have a comment explaining the side effect

**defer & Resources:**
- [ ] Cleanup deferred immediately after acquisition
- [ ] No `defer` inside loops
- [ ] `Close()` errors checked when data integrity matters

**Security:**
- [ ] `unsafe` has explicit justification + comment
- [ ] All external inputs validated at package boundaries
- [ ] No hardcoded credentials or config values

**Performance:**
- [ ] Slices/maps preallocated when size is known (`make([]T, 0, n)`)
- [ ] `strings.Builder` used for concatenation in loops
- [ ] No unnecessary interface boxing in hot paths

Output:
1. Summary (2–3 sentences)
2. Issues table (severity: critical / major / minor / nit, file:line, description, suggestion)
3. Verdict: PASS | ITERATE | DEBUG

$ARGUMENTS
