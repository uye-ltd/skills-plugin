---
name: go-verify-tests
description: Verify the quality and coverage of existing Go tests. Used by Reviewer Agent for Go tasks.
language: go
used-by: executor,reviewer
---

Assess the quality and completeness of the provided Go test suite.

Check:
- **Coverage**: happy paths, error paths, edge cases, boundary values
- **Table-driven tests**: are multiple cases handled idiomatically?
- **Isolation**: are tests independent? do they use real global state?
- **Error assertions**: are error cases specifically checked (type, message) or just `!= nil`?
- **Concurrency**: are concurrent functions tested with `-race`?
- **Benchmarks**: are performance-sensitive functions benchmarked?
- **Missing tests**: what is not covered that should be?

Output: coverage assessment + list of missing test scenarios with suggested function signatures.

$ARGUMENTS
