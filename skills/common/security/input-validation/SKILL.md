---
name: input-validation
description: Review input validation at architecture-level trust boundaries: API gateways, service ingestion points, and inter-service interfaces. For in-code validation logic (function parameters, data model constraints), use the language-specific code-review skill.
language: common
used-by: reviewer,standalone
---

Review the provided architecture, API definitions, and ingestion-point configuration for input validation gaps at trust boundaries.

**Scope**: architecture-level boundaries — where external or cross-service data enters the system.
**Out of scope**: in-code validation logic inside functions or data models — use the language-specific `code-review` skill for those.

Check every trust boundary crossing where external or lower-trust data enters a higher-trust system:

- **Missing schema validation at ingestion**: no JSON schema, OpenAPI spec enforcement, or type contract at the API gateway or message queue consumer
- **Trust boundary violations**: data from one trust level (e.g. public internet) used at a higher trust level (e.g. internal service) without re-validation or re-encoding at the boundary
- **API gateway validation rules**: are type, format, length, and allowable value constraints enforced at the gateway before requests reach services?
- **Message queue / event consumers**: are event payloads validated on arrival, or assumed to be safe because they came from an internal topic?
- **File and blob ingestion**: are MIME type, size limits, and filename sanitisation enforced at the ingestion endpoint?
- **Environment and configuration inputs**: are env vars and CLI args validated at startup, not silently used as defaults?
- **Error responses**: do validation failures leak internal schema, field names, or stack traces to the caller?

Output: list of validation gaps by severity (critical / high / medium / low) with location (endpoint, topic, service boundary), the input source, what is missing, and the correct validation pattern.

$ARGUMENTS
