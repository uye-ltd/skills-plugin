# Template: generate-func
# Used by: py-generate-func, js-generate-func, go-generate-func

Generate a well-structured function for the provided description or signature.

**Approach:** Prefer the simplest correct solution. Think about edge cases and testability before writing.

**Structure:**
- Functions ≤ ~30 lines, single concern
- No global state; pass all dependencies as parameters (dependency injection)
- Business logic independent from I/O
- No unexpected side effects; make side effects explicit via parameters

**Naming:** Verb-first names. Descriptive — no abbreviations or single-letter names except `i`, `j` in loops.

**Security:** Validate all external inputs at function boundaries. No hardcoded credentials, secrets, or environment-specific config.

**Determinism:** No hidden randomness unless explicitly required by the function's contract.

**Resources:** Always clean up (files, sockets, DB connections).

Include a minimal usage example.
