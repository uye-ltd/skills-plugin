# Changelog

All notable changes to this plugin will be documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.0.0] - 2026-03-14

### Added
- Initial plugin scaffold with namespace `uye`
- Skills: `docs` category (docs-write, docs-review, docs-changelog, docs-readme, docs-api)
- Skills: `python` category (py-review, py-tests, py-refactor, py-debug, py-types)
- Skills: `go` category (go-review, go-tests, go-refactor, go-interfaces, go-debug)
- Skills: `js` category (js-review, js-tests, js-refactor, js-component, js-debug)
- Skills: `devops` category (dockerfile, ci-pipeline, k8s, debug-pipeline, security-scan)
- Agents: docs-reviewer, python-expert, go-expert, js-expert, devops-engineer
- Hook configuration template with all 14 events commented out
- Install script for deploying to org repos at project scope
- Scaffold scripts for new skills and agents
