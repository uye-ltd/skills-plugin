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

Output:
1. Summary (2–3 sentences)
2. Issues table (severity: critical / major / minor / nit, file:line, description, suggestion)
3. Verdict: PASS | ITERATE | DEBUG

$ARGUMENTS
