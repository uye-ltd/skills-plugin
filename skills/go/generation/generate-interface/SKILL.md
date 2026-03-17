---
name: go-generate-interface
description: Generate a Go interface and/or mock implementation. Used by Executor Agent for Go tasks.
language: go
used-by: executor
---

Design and implement a Go interface for the provided description.

Interface design rules (explicit checklist):
- Interface at the **consumer** package, not the producer — flag if the request implies producer-side definition
- Minimal: single-method interfaces are ideal; no more methods than the consumer needs
- Name after behaviour with `-er` suffix: `Reader`, `Storer`, `Notifier` — not `IReader`, `ReaderInterface`
- No stutter: `user.UserStore` → `user.Store`
- Accept interfaces, return concrete types (general rule)
- Full godoc comment on the interface and each method

Mock implementation:
- Simple hand-written mock (struct with function fields) unless `gomock` is in the project
- If `gomock` is used, provide the `mockgen` command
- Implement the full interface; panic on unset function fields in tests to catch missing setup

$ARGUMENTS
