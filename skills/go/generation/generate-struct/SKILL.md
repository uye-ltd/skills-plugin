---
name: go-generate-struct
description: Generate a Go struct and its constructor from a description or spec. Used by Executor Agent for Go tasks.
language: go
used-by: executor
---

Generate a well-structured Go struct for the provided description.

Requirements:
- Godoc comment on the struct and all exported fields
- Private fields with exported getters/setters only if mutation control is needed
- Constructor function `NewXxx(...)` that validates inputs and returns `(*Xxx, error)`
- `String() string` method if the struct will be logged or printed
- Implement relevant standard interfaces (`io.Reader`, `io.Closer`, `fmt.Stringer`, etc.)
- No exported mutable fields if the struct should be immutable

Include a usage example.

$ARGUMENTS
