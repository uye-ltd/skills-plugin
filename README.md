# uye Claude Code Plugin

Organisation-wide [Claude Code](https://code.claude.com) plugin for uye projects.
Multi-agent pipeline with language routing for Python, JavaScript, and Go.

---

## Design principles

- **Agents are maximally abstract** — they reason about project logic, not syntax
- **Skills are split into common and language-specific** — common skills are reused across all agents regardless of language
- **Skill names are conceptually parallel across languages** — `analyze-trace`, `detect-bugs`, `check-async` exist in Python, JS, and Go, making Planner and Reviewer fully language-agnostic
- **Language Router decides which skills apply** — Executor and Reviewer receive the correct skill set; the rest of the pipeline stays unchanged
- **Iterative workflow** — code loops between Executor → Reviewer → Debugger/Refactorer until it is clean

---

## Pipeline architecture

```
                     ┌──────────────────┐
                     │   User Request   │
                     └────────┬─────────┘
                              │
                              ▼
                     ┌──────────────────┐
                     │ Language Router  │  detects language from file
                     │                  │  extension or user instruction
                     └────────┬─────────┘
                              │
                              ▼
                     ┌──────────────────┐
                     │  Context Agent   │
                     │ ─────────────── │
                     │ read-file        │  reads relevant files
                     │ map-project      │  maps project structure
                     │ summarize-module │  builds module models
                     │ extract-api      │  extracts API surfaces
                     └────────┬─────────┘
                              │
                              ▼
                     ┌──────────────────┐
                     │  Planner Agent   │
                     │ ─────────────── │
                     │ find-symbol      │  locates definitions
                     │ find-references  │  assesses blast radius
                     │ trace-call-graph │  traces execution chains
                     └────────┬─────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
      ┌───────────────┐                ┌───────────────┐
      │   Executor    │                │   Reviewer    │
      │ ──────────── │                │ ──────────── │
      │ generate-func │                │ code-review   │
      │ generate-cls  │                │ check-bugs    │
      │ generate-test │                │ detect-smells │
      │ update-imports│                │ analyze-compl │
      └───────┬───────┘                │ verify-tests  │
              │                        └───────┬───────┘
              │◄── ITERATE: fix instructions ──┤
              │                                │
              │                           PASS ▼
              │                        ┌───────────────┐
              │                        │  Refactorer   │  optional cleanup
              │                        │ ──────────── │
              │                        │ extract-func  │
              │                        │ split-module  │
              │                        │ remove-dup    │
              │                        │ rename-sym    │
              │                        │ apply-types   │
              │                        └───────────────┘
              │
              │◄── fix ─────────────────────┐
              ▼                             │
      ┌───────────────┐             ┌───────────────┐
      │   Debugger    │             │  Performance† │
      │ ──────────── │             │ ──────────── │
      │ analyze-trace │             │ analyze-compl │
      │ trace-vars    │             │ suggest-cache │
      │ detect-bugs   │             │ detect-n+1    │
      │ check-async/  │             │ suggest-vec   │
      │ check-goroutne│             │ detect-alloc  │
      └───────────────┘             └───────────────┘

† Performance triggers when: Reviewer raises ≥ 2 major perf issues;
  pipeline.autoPerformance: true in settings.json and Reviewer issues PASS;
  Planner detects a hot path; or user explicitly requests it.
```

---

## Language Router

Entry point for every code task. Detects language and routes Executor and Reviewer to the correct skill set. All other agents remain language-agnostic.

**Detection order:**

| Priority | Signal | Example |
|----------|--------|---------|
| 1 | Explicit instruction | "fix this Go code", "in TypeScript" |
| 2 | File extension | `.py` → Python · `.ts`/`.js` → JS · `.go` → Go |
| 3 | Project markers | `pyproject.toml` · `go.mod` · `package.json` |
| 4 | Imports / shebang | `#!/usr/bin/env python` · `import (` · `require()` |

**Routing output:**

```
LANGUAGE: python
REASON:   file.py extension
EXECUTOR SKILLS: skills/python/generation/, skills/python/refactoring/
REVIEWER SKILLS: skills/python/analysis/, skills/python/debugging/
COMMON SKILLS:   skills/common/navigation/, skills/common/analysis/
NEXT: context-agent
```

**Multi-language tasks** (e.g. Go backend + TS frontend): each language is processed independently with its own skills; common skills apply across all.

---

## Iterative workflow

```
User request
     │
     ▼
Language Router  →  determines language
     │
     ▼
Context Agent    →  collects relevant files and API surfaces
     │
     ▼
Planner          →  builds ordered implementation steps
     │
     ▼
Executor         →  generates code (language-specific)
     │
     ▼
Reviewer         →  checks code (language-specific)
     │
     ├─► PASS    →  Refactorer (optional cleanup)  →  done
     │
     ├─► ITERATE →  Executor (with specific fix instructions)
     │
     └─► DEBUG   →  Debugger  →  root cause + fix  →  Executor
                         │
                         └─► repeat until Reviewer passes
```

The loop continues until the Reviewer issues a PASS. Performance analysis is triggered automatically when the Reviewer flags ≥ 2 major perf issues, or when `pipeline.autoPerformance: true` is set; it can also be invoked manually by the Planner or the user at any point.

---

## Agents

| Agent | Role | Language-specific? |
|-------|------|--------------------|
| `language-router` | Detects language, routes skill sets to Executor and Reviewer | Yes — entry point |
| `context` | Reads files, maps structure, extracts API surfaces | No |
| `planner` | Breaks task into ordered, verifiable steps | No |
| `executor` | Generates and modifies code | Via routed skills |
| `reviewer` | Code review, smells, test verification | Via routed skills |
| `debugger` | Traces errors, tracks vars, finds root causes | Via routed skills |
| `refactorer` | Extract, split, dedup, rename, type | Via routed skills |
| `performance` | Complexity, caching, N+1, vectorisation, allocations | Via routed skills |

Agent handoff schemas are in [`docs/contracts/`](docs/contracts/).

---

## Skills

Skills are invoked as `/uye:<skill-name>` or automatically by the pipeline agents.

### Common — shared across all languages

| Subcategory | Skill | Used by |
|-------------|-------|---------|
| `navigation` | `read-file` | Context |
| | `map-project` | Context |
| | `find-symbol` | Context, Planner |
| | `find-references` | Planner |
| | `trace-call-graph` | Planner |
| `analysis` | `summarize-module` | Context, Planner |
| | `extract-api` | Context |
| | `analyze-complexity` | Reviewer, Performance |
| | `detect-code-smells` | Reviewer |
| `performance` | `suggest-cache` | Performance |
| | `detect-n-plus-one` | Performance |
| `docs` | `docs-write` | — |
| | `docs-review` | — |
| | `docs-changelog` | — |
| | `docs-readme` | — |
| | `docs-api` | — |
| `devops` | `dockerfile` | — |
| | `ci-pipeline` | — |
| | `k8s` | — |
| | `debug-pipeline` | — |
| | `security-scan` | — |
| `security` | `secrets-scan` | — |
| | `owasp-check` | — |
| | `dependency-audit` | — |
| | `input-validation` | — |
| | `auth-review` | — |
| `reference` | `reference-docs` | standalone |
| | `reference-help` | standalone |
| | `reference-sourcecode` | standalone |
| | `reference-api` | standalone |
| | `reference-changelog` | standalone |
| | `reference-config` | standalone |
| | `reference-examples` | standalone |
| | `reference-list` | standalone |

> Reference skills are dormant until tool names are listed in `settings.json → tools`.
> Tool configs in `config/tools/` are schema-validated by `validate.sh` (required fields, name matches filename).
> All eight reference skills share a common tool-resolution preamble via `skills/templates/reference-base.md`.
> See [`docs/tools-config.md`](docs/tools-config.md) for optional fields: `docs.api_url`, `config.paths`, `aliases`, `github.related_repos`.

### Python

| Subcategory | Skills | Used by |
|-------------|--------|---------|
| `analysis` | `py-code-review`, `py-check-bugs` | Reviewer |
| `generation` | `py-generate-func`, `py-generate-class`, `py-update-imports` | Executor |
| `refactoring` | `py-extract-func`, `py-split-module`, `py-remove-dup`, `py-rename-sym`, `py-apply-types` | Refactorer |
| `testing` | `py-generate-test`, `py-verify-tests` | Executor, Reviewer |
| `debugging` | `py-analyze-trace`, `py-trace-vars`, `py-detect-bugs`, `py-check-async` | Debugger |
| `performance` | `py-suggest-vectorize`, `py-profile-hotspot` | Performance |

### JavaScript / TypeScript

| Subcategory | Skills | Used by |
|-------------|--------|---------|
| `analysis` | `js-code-review`, `js-check-bugs` | Reviewer |
| `generation` | `js-generate-func`, `js-generate-class`, `js-generate-component`, `js-update-imports` | Executor |
| `refactoring` | `js-extract-func`, `js-remove-dup`, `js-rename-sym`, `js-add-types` | Refactorer |
| `testing` | `js-generate-test`, `js-verify-tests` | Executor, Reviewer |
| `debugging` | `js-analyze-trace`, `js-trace-vars`, `js-detect-bugs`, `js-check-async` | Debugger |
| `performance` | `js-detect-rerender`, `js-suggest-memoize` | Performance |

### Go

| Subcategory | Skills | Used by |
|-------------|--------|---------|
| `analysis` | `go-code-review`, `go-check-bugs` | Reviewer |
| `generation` | `go-generate-func`, `go-generate-struct`, `go-generate-interface`, `go-update-imports` | Executor |
| `refactoring` | `go-extract-func`, `go-split-module`, `go-remove-dup`, `go-rename-sym` | Refactorer |
| `testing` | `go-generate-test`, `go-generate-benchmark`, `go-verify-tests` | Executor, Reviewer |
| `debugging` | `go-analyze-trace`, `go-trace-vars`, `go-detect-bugs`, `go-check-goroutine` | Debugger |
| `performance` | `go-suggest-pool`, `go-detect-alloc` | Performance |

---

## Configuration

`settings.json` at the plugin root controls default behaviour. Projects can override by shipping their own `settings.json` alongside `.claude-plugin/plugin.json`.

| Key | Default | Description |
|-----|---------|-------------|
| `agent` | `"language-router"` | Entry-point agent for all requests |
| `outputStyle` | `"Explanatory"` | Response verbosity: `Explanatory` \| `Concise` |
| `language` | `null` | Pin language; skips auto-detection in Language Router |
| `pipeline.skipReview` | `false` | Skip Reviewer agent (prototyping only) |
| `pipeline.skipPlanner` | `false` | Skip Planner for small tasks |
| `pipeline.autoPerformance` | `false` | Run Performance agent automatically after every PASS |
| `tools` | `[]` | Enable reference skills: `["postgres", "redis"]`. Supports version pinning: `[{"name": "redis", "version": "7.2"}]` — overrides `github.branch` for source and config lookups. See [`docs/tools-config.md`](docs/tools-config.md) for all bundled tools |

---

## Bundled tools

Reference skills activate for tools listed in `settings.json → tools`. All definitions live in `config/tools/`.

| Tool | Category | Description |
|------|----------|-------------|
| `filebrowser` | Storage | Web-based file manager for self-hosted environments |
| `navidrome` | Media | Self-hosted music streaming server compatible with the Subsonic API |
| `caddy` | Web server | Fast, extensible web server with automatic HTTPS |
| `nginx` | Web server | High-performance HTTP server, reverse proxy, and load balancer |
| `fail2ban` | Security | Daemon that blocks IPs conducting repeated failed login attempts |
| `docker` | Containers | Docker Engine CLI, Dockerfile authoring, image building, and registry management |
| `docker-compose` | Containers | Multi-container application definition and orchestration |
| `docker-buildx` | Containers | Extended image building with BuildKit: multi-platform builds and cache backends |
| `prometheus` | Observability | Metrics collection, PromQL querying, and alerting rules |
| `grafana` | Observability | Dashboards, alerting, and data source integrations for metrics, logs, and traces |
| `elasticsearch` | Search / analytics | Distributed full-text search, structured queries, aggregations, and vector search |
| `kibana` | Search / analytics | Visualisation and exploration UI for Elasticsearch — dashboards, Discover, Lens, Maps |
| `kafka` | Messaging | Distributed event streaming — topics, partitions, consumer groups, and Kafka Streams |
| `rabbitmq` | Messaging | Message broker supporting AMQP, MQTT, and STOMP — exchanges, queues, and routing |
| `redis` | Data store | In-memory caching, pub/sub, sorted sets, streams, and Redis Cluster |
| `postgres` | Database | Relational database — SQL, JSONB, full-text search, partitioning, and replication |
| `mongodb` | Database | Document-oriented NoSQL — aggregation pipelines, Atlas Search, and transactions |
| `clickhouse` | Database | Column-oriented OLAP — MergeTree engines, materialized views, and distributed tables |
| `kubernetes` | Orchestration | Workloads, services, ingress, RBAC, config maps, persistent volumes, and cluster management |
| `helm` | Orchestration | Kubernetes package manager — chart authoring, values, templating, releases, and hooks |
| `traefik` | Web server | Cloud-native reverse proxy — routers, middlewares, TLS, and Let's Encrypt auto-certs |
| `github-actions` | CI/CD | Workflows, jobs, reusable actions, secrets, environments, and self-hosted runners |
| `logstash` | Observability | Data processing pipeline — inputs, filters, outputs, codecs, and Elastic Stack ingest |
| `opentelemetry` | Observability | Distributed tracing, metrics, and logs SDK, collector config, and instrumentation |
| `sentry` | Observability | Error tracking and performance monitoring — SDK, issue grouping, traces, and alerts |
| `terraform` | Infrastructure | Infrastructure as code — providers, resources, modules, state, and remote backends |
| `ansible` | Infrastructure | Agentless automation — playbooks, roles, inventories, modules, and Vault secrets |
| `vault` | Auth & secrets | Dynamic secrets, PKI, encryption as a service, auth methods, and audit logging |
| `rustfs` | Storage | S3-compatible object storage in Rust — buckets, access policies, and high-throughput storage |
| `minio` | Storage | High-performance S3-compatible storage — IAM policies, lifecycle rules, and replication |
| `icecast` | Media | Streaming media server — mount points, relay, source clients, and listener auth |
| `liquidsoap` | Media | Audio/video streaming scripting — sources, operators, scheduling, and live radio automation |
| `plex` | Media | Media library organisation, streaming, transcoding, remote access, and client management |
| `neo4j` | Database | Graph database — Cypher queries, graph data modeling, indexes, constraints, and graph algorithms |
| `sqlite` | Database | Embedded relational database — SQL, FTS5 full-text search, WAL mode, and JSON functions |
| `mysql` | Database | Relational database — SQL, stored procedures, replication, InnoDB engine, and partitioning |
| `mailserver` | Mail | Full-featured mail server in Docker — SMTP, IMAP, DKIM, SPF, DMARC, and spam filtering |
| `keycloak` | Auth | Identity and access management — SSO, OAuth2, OIDC, SAML, realms, clients, and user federation |
| `celery` | Messaging | Distributed task queue — async tasks, periodic tasks, brokers, result backends, and routing |
| `loki` | Observability | Log aggregation — LogQL queries, label-based indexing, log streams, and ruler alerting |
| `tempo` | Observability | Distributed tracing — trace ingestion, TraceQL queries, search, and metrics generation |
| `wireguard` | Networking | Modern VPN — tunnel configuration, peer setup, key management, and routing |
| `tailscale` | Networking | Zero-config mesh VPN — ACL policies, subnet routing, exit nodes, and MagicDNS |
| `pihole` | Networking | DNS ad blocker — blocklists, allowlists, DHCP server, query logging, and custom DNS records |
| `adguard-home` | Networking | Network-wide DNS blocker — filtering rules, DHCP, encrypted DNS, and parental controls |
| `portainer` | Infra | Container management UI — Docker and Kubernetes environments, stacks, and RBAC |
| `crowdsec` | Security | Collaborative security engine — behavior detection, bouncers, scenarios, and CAPI sharing |
| `trivy` | Security | Vulnerability scanner — containers, IaC, SBOMs, and secret detection |

See [`docs/tools-config.md`](docs/tools-config.md) for the full schema and how to add new tools.

---

## Installation

### Single repo

```bash
cd /path/to/skills-plugin
./scripts/install.sh /path/to/your-repo
```

This does two things:
1. Registers the plugin as a marketplace in your user Claude config (once per machine)
2. Installs the `uye` plugin at project scope in `.claude/settings.json` of the target repo

Commit `.claude/settings.json` to share the plugin with your team:
```bash
git add .claude/settings.json && git commit -m 'chore: add uye claude plugin'
```

> **Each developer** needs to run `install.sh` (or `update.sh`) once on their machine
> to register the marketplace. The committed `settings.json` activates the plugin once
> the marketplace is registered locally.

### Multiple repos

```bash
./scripts/update.sh /path/to/repo1 /path/to/repo2
./scripts/update.sh --from-file repos.txt
```

### Local testing (no install)

```bash
# Test locally without installing
claude --plugin-dir /path/to/skills-plugin

# Reload after changes (in-session)
/reload-plugins
```

---

## Adding new components

### New tool (reference skill family)

```bash
./scripts/add-tool.sh \
  --name grafana \
  --description "Metrics dashboarding and alerting platform" \
  --docs-url "https://grafana.com/docs/grafana/latest/" \
  --github grafana/grafana \
  --branch main \
  --examples "dashboard provisioning,alerting rules,data sources" \
  --api-url "https://grafana.com/docs/grafana/latest/developers/http_api/" \
  --aliases "grafana-oss" \
  --config-paths "conf/defaults.ini" \
  --related-repos "grafana/loki,grafana/tempo"
# → creates config/tools/grafana.json

# Enable in any project's settings.json:
#   { "tools": ["grafana"] }
#   { "tools": [{"name": "redis", "version": "7.2"}] }   ← version-pinned source lookups

# Or copy config into a project that can't reference the plugin path:
./scripts/enable-tool.sh grafana /path/to/project
```

All flags after `--branch` are optional. See [`docs/tools-config.md`](docs/tools-config.md) for the full schema.

### New skill

```bash
./scripts/new-skill.sh <language|common> <subcategory> <skill-name>

# Examples
./scripts/new-skill.sh python    refactoring  inline-const
./scripts/new-skill.sh go        debugging    detect-race
./scripts/new-skill.sh common    analysis     detect-dead-code
```

If the subcategory is new, add it to the `"skills"` array in `.claude-plugin/plugin.json`.

### New language

```bash
./scripts/new-language.sh <language-name>

# Example — creates all 6 subcategories and registers paths in plugin.json
./scripts/new-language.sh rust
```

### New common category

```bash
./scripts/new-category.sh <category-name> [skill1 skill2 ...]

# Example
./scripts/new-category.sh accessibility contrast-check keyboard-nav
```

### New agent

```bash
./scripts/new-agent.sh <agent-name>

# Example
./scripts/new-agent.sh security-reviewer
```

---

## Validation and utilities

```bash
# Validate plugin structure (frontmatter, paths, duplicates, executability, tool configs)
./scripts/validate.sh
./scripts/validate.sh --strict    # treat warnings as errors

# List all registered skills grouped by language / subcategory
./scripts/list-skills.sh
./scripts/list-skills.sh python                  # filter by language
./scripts/list-skills.sh --used-by executor      # filter by consuming agent
./scripts/list-skills.sh --names-only            # just skill names

# Release a new version
./scripts/release.sh <version>
# Example: ./scripts/release.sh 2.1.0
# Bumps plugin.json, prepends CHANGELOG entry, prints next steps
```

---

## Repository structure

```
skills-plugin/
├── CLAUDE.md                         # contributor guide for this repo
├── CHANGELOG.md
├── .claude-plugin/
│   └── plugin.json                   # manifest: name, version, skill paths
├── agents/
│   ├── language-router.md            # pipeline entry point
│   ├── context.md
│   ├── planner.md
│   ├── executor.md
│   ├── reviewer.md
│   ├── debugger.md
│   ├── refactorer.md
│   └── performance.md
├── config/
│   └── tools/                        # one JSON definition per supported tool
├── docs/
│   ├── contracts/                    # agent handoff schemas
│   │   ├── routing-block.md
│   │   ├── context-summary.md
│   │   ├── implementation-plan.md
│   │   ├── execution-summary.md
│   │   ├── review-report.md
│   │   ├── debug-report.md
│   │   ├── refactoring-summary.md
│   │   └── performance-report.md
│   └── tools-config.md               # tool definition schema + enable-tool usage
├── skills/
│   ├── common/
│   │   ├── navigation/               # read-file, map-project, find-symbol, …
│   │   ├── analysis/                 # summarize-module, extract-api, …
│   │   ├── performance/              # suggest-cache, detect-n-plus-one
│   │   ├── docs/                     # docs-write, docs-review, …
│   │   ├── devops/                   # dockerfile, ci-pipeline, k8s, …
│   │   ├── security/                 # infra/boundary-level: owasp-check, input-validation, …
│   │   └── reference/               # reference-docs, reference-help, reference-sourcecode,
│                                #   reference-api, reference-changelog, reference-config,
│                                #   reference-examples, reference-list
│   ├── python/
│   │   ├── analysis/                 # py-code-review, py-check-bugs
│   │   ├── generation/               # py-generate-func, py-generate-class, …
│   │   ├── refactoring/              # py-extract-func, py-apply-types, …
│   │   ├── testing/                  # py-generate-test, py-verify-tests
│   │   ├── debugging/                # py-analyze-trace, py-check-async, …
│   │   └── performance/              # py-suggest-vectorize, py-profile-hotspot
│   ├── javascript/                   # same 6 subcategories
│   ├── go/                           # same 6 subcategories
│   └── templates/                    # base templates for parallel skill families
│                                     # (analyze-trace, detect-bugs, reference-base, …)
├── hooks/
│   └── hooks.json                    # PostToolUse: ruff format+fix on .py files
├── scripts/
│   ├── install.sh                    # install into a target repo
│   ├── update.sh                     # bulk install across org repos
│   ├── new-skill.sh                  # scaffold: <language> <subcategory> <name>
│   ├── new-agent.sh                  # scaffold: <name>
│   ├── new-language.sh               # scaffold full language tree
│   ├── new-category.sh               # scaffold new common category
│   ├── add-tool.sh                   # add a new tool definition to config/tools/
│   ├── enable-tool.sh                # copy tool config into a project directory
│   ├── validate.sh                   # lint plugin structure
│   ├── list-skills.sh                # browse registered skills
│   ├── release.sh                    # bump version + CHANGELOG
│   └── hooks/
│       ├── format-python.sh          # PostToolUse: ruff format + ruff check --fix
│       └── format-js.sh              # PostToolUse: formatter for JS/TS files
└── settings.json                     # plugin default settings (JSONC)
```

---

## Hooks

`hooks/hooks.json` has PostToolUse enabled for two languages:

- **Python** (`format-python.sh`): after every Write or Edit to a `.py`/`.pyi` file, runs `ruff format` + `ruff check --fix`. Requires [ruff](https://docs.astral.sh/ruff/); exits silently if not found.
- **JavaScript** (`format-js.sh`): after every Write or Edit to a `.js`/`.ts`/`.jsx`/`.tsx` file.

When scaffolding a new language with `./scripts/new-language.sh`, a stub hook script is created automatically at `scripts/hooks/format-<language>.sh`.

All other hook event types are present and commented out — uncomment to enable.

---

## Versioning

Follows [Semantic Versioning](https://semver.org/). Use `./scripts/release.sh <version>` to bump and generate a CHANGELOG entry.
