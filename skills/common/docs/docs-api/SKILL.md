---
name: docs-api
description: Generate API reference documentation from code, route definitions, or OpenAPI specs.
language: common
used-by: standalone
---

Produce API reference documentation for the provided interface.

For REST APIs, document each endpoint with:
- Method + path, description
- Path / query / header / body parameters (name, type, required, description, example)
- Response codes and response body schema
- Example request and response (curl + JSON)

For SDKs / libraries, document each public function/class with:
- Signature, description, parameters, return type, exceptions, usage example

Match any existing docs format (OpenAPI YAML, Markdown tables, etc.) if present in the project.

$ARGUMENTS
