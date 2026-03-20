---
name: reference-docs
description: >
  Fetch and answer from the official documentation of any tool enabled in the
  project's settings.json `tools` array. Use when the user asks how to configure,
  install, or operate a supported tool — even if they don't say "docs" explicitly.
  Dormant when `tools` is empty.
language: common
used-by: standalone
template: reference-base
---

# Reference Docs Skill

Fetch official documentation for the active tool and answer the user's question.

<!-- Steps 1–3: tool resolution — see skills/templates/reference-base.md -->

## Step 4 — Fetch documentation

Use the selected tool's `docs.url` as the starting point. Fetch the page with `WebFetch`.

- If the user's question maps to a known section, append the relevant path from
  `docs.sections` to the base URL and fetch that page directly.
- Extract the content that answers the user's question.
- If the first page does not contain sufficient detail, follow links within the same
  docs domain to find the relevant section.
- **Fetch at most 3 pages.** After 3 pages, synthesise an answer from what you have.
  If the answer is still incomplete, tell the user which section to read manually and
  provide the direct URL.

**WebSearch fallback:** If a `WebFetch` call returns a 404, redirect loop, empty body, or
JavaScript-only SPA shell (no meaningful text content), fall back to:
```
WebSearch site:<docs-domain> <2-3 keywords from user's question>
```
Replace `<docs-domain>` with the hostname from `docs.url` (e.g. `grafana.com`).
Follow the most relevant result URL to fetch the actual page. Count the WebSearch
and its followed fetch together as one page toward the 3-page limit.

## Step 5 — Answer

Answer the user's question citing the specific documentation page(s) fetched.
Include the URL of each source page referenced.

## User question

$ARGUMENTS

If no question is provided, ask the user what they want to know about the tool.
