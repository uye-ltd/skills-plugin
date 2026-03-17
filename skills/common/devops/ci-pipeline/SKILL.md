---
name: ci-pipeline
description: Write or review a CI/CD pipeline configuration (GitHub Actions, GitLab CI, etc.).
language: common
used-by: standalone
---

Write or review a CI/CD pipeline for the provided project.

Detect platform from context (GitHub Actions, GitLab CI, CircleCI); default to GitHub Actions.

Include stages as appropriate: lint, type-check, unit tests with coverage, integration tests, build, Docker build/push, deploy.

Best practices:
- Cache dependencies to speed up runs
- Pin action versions to a commit SHA
- Use secrets from the platform store — never hardcode credentials
- Run lint and tests in parallel where possible
- Gate deployments with environment approvals

$ARGUMENTS
