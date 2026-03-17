---
name: go-generate-struct
description: Generate a Go struct and its constructor from a description or spec. Used by Executor Agent for Go tasks.
language: go
used-by: executor
---

Generate a well-structured Go struct for the provided description.

Requirements:
- Struct names: UpperCamelCase nouns (`Order`, `UserStore`)
- `NewXxx` constructor validates inputs and returns `(*Xxx, error)` for structs that can fail to init
- Accept interfaces as dependencies (not concrete types) in the constructor
- Private fields by default; exported getters/setters only when mutation control is needed
- Implement relevant standard interfaces (`io.Reader`, `io.Closer`, `fmt.Stringer`) where applicable
- No exported mutable fields if the struct should be immutable
- No global state in struct methods; pass all dependencies via constructor (DI)
- Godoc comment on struct and all exported fields

Include a usage example.

$ARGUMENTS
