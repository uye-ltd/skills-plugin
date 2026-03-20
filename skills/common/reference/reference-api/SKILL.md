---
name: reference-api
description: >
  Look up REST, HTTP, or gRPC API endpoints for any tool enabled in the project's
  settings.json `tools` array. Use when the user asks about API endpoints, request/response
  formats, authentication, rate limits, or SDK usage against a tool's API surface.
  Prefers `docs.api_url` when defined; falls back to the main docs URL. Do NOT use for
  general configuration questions — use reference-docs instead. Dormant when `tools` is empty.
language: common
used-by: standalone
template: reference-base
---

# Reference API Skill

Fetch and answer from the API reference of the active tool.

<!-- Steps 1–3: tool resolution — see skills/templates/reference-base.md -->

## Step 4 — Fetch API reference

### 4a — Use dedicated API URL if available
If the tool config contains `docs.api_url`, use it as the starting point:
```
WebFetch <docs.api_url>
```

### 4b — Fall back to main docs with API section heuristic
If `docs.api_url` is absent, search within the main docs for API reference sections.
Check `docs.sections` for entries containing "api", "reference", "rest", or "http_api".
Append the best match to `docs.url` and fetch:
```
WebFetch <docs.url>/<api-section>
```

### 4c — WebSearch fallback
If the fetched page is empty, a 404, or a JavaScript SPA shell, fall back to:
```
WebSearch site:<docs-domain> <tool-name> API reference <keyword>
```
Follow the most relevant result URL.

## Step 5 — Navigate to the specific endpoint or operation

Once the API reference is loaded:
- Locate the endpoint, method, or operation relevant to the user's question.
- If the reference is paginated or split across pages, follow links to the relevant section
  (count each fetch toward the 3-page limit).
- Extract: HTTP method, URL path, required and optional parameters, request/response schema,
  authentication requirements, and any rate limit notes.

## Step 6 — Answer

Present the API information:
- **Endpoint**: `METHOD /path`
- **Description**: What it does
- **Authentication**: Required auth method
- **Parameters**: Table of name, type, required/optional, description
- **Request body example** (if applicable): JSON/YAML snippet
- **Response example**: JSON/YAML snippet
- **Notes**: Rate limits, pagination, deprecations
- **Source**: Link to the API reference page

## User question

$ARGUMENTS

If no question is provided, ask the user which API endpoint or operation they want to know about.
