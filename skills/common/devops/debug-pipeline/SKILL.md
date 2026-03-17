---
name: debug-pipeline
description: Debug a failing CI/CD pipeline from logs or error output.
language: common
used-by: standalone
---

Analyse the pipeline failure and identify the root cause.

Steps:
1. Identify which stage/step failed and the exact error
2. Distinguish: flaky test, environment issue, dependency problem, code bug, permissions, or resource exhaustion
3. Propose a concrete fix with the exact config or code change needed
4. Suggest how to prevent recurrence

If logs are truncated or key info is missing, identify exactly what additional context is needed.

$ARGUMENTS
