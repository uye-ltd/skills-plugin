---
name: go-generate-interface
description: Generate a Go interface and/or mock implementation. Used by Executor Agent for Go tasks.
language: go
used-by: executor
---

Design and implement a Go interface for the provided description.

Interface design rules:
- Define the interface at the consumer (not the producer) package
- Keep it minimal — one method if possible, no more than needed
- Name after behaviour: `Reader`, `Storer`, `Notifier`
- Full godoc comment on the interface and each method

Mock implementation:
- Simple hand-written mock (struct with function fields) unless `gomock` is in the project
- If `gomock` is used, provide the `mockgen` command
- Implement the full interface; panic on unset function fields in tests to catch missing setup

$ARGUMENTS
