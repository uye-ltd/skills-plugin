# Tool Configuration — Reference Skill Family

The `reference-docs`, `reference-help`, and `reference-sourcecode` skills are
generic. They read tool definitions at runtime from `config/tools/` and activate
only for tools listed in the project's `settings.json`.

---

## Tool definition schema

Each tool is defined in `config/tools/<name>.json`:

```jsonc
{
  "name": "filebrowser",
  "description": "Web-based file manager for self-hosted environments",
  "docs": {
    "url": "https://filebrowser.org/",
    "api_url": "https://filebrowser.org/api",        // optional — dedicated API reference URL
    "sections": ["configuration", "installation", "docker", "api"]
  },
  "github": {
    "org": "filebrowser",
    "repo": "filebrowser",
    "branch": "master",
    "related_repos": [                               // optional — fallback repos for source search
      {"org": "filebrowser", "repo": "filebrowser-backend"}
    ]
  },
  "config": {                                        // optional — default config file paths in repo
    "paths": [".filebrowser.json"]
  },
  "aliases": ["fb"],                                 // optional — short names for tool selection
  "examples": [
    "file permissions",
    "reverse proxy setup",
    "docker-compose configuration",
    "user management"
  ]
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `name` | yes | Lowercase identifier — matches the key used in `settings.json` |
| `description` | yes | One-line description used by Claude to match user intent |
| `docs.url` | yes | Base URL of the official documentation |
| `docs.api_url` | no | Dedicated API reference URL — used by `reference-api` when present |
| `docs.sections` | no | Known sub-paths appended to `docs.url` for targeted fetches |
| `github.org` | yes | GitHub organisation or user |
| `github.repo` | yes | Repository name |
| `github.branch` | yes | Default branch for raw file fetches |
| `github.related_repos` | no | Additional repos searched by `reference-sourcecode` when primary yields no results |
| `config.paths` | no | Known paths to default/reference config files within the repo — used by `reference-config` |
| `aliases` | no | Alternative names users may use (e.g. `k8s` for `kubernetes`, `pg` for `postgres`) |
| `examples` | no | Sample topics — used by Claude to confirm tool selection |

---

## Enabling tools in a project

In the consuming project's `settings.json`, add a `tools` array:

```json
{
  "tools": ["filebrowser"]
}
```

Multiple tools:

```json
{
  "tools": ["traefik", "minio"]
}
```

**Version pinning** — pin source-code lookups to a specific branch or version tag:

```json
{
  "tools": [
    {"name": "redis", "version": "7.2"},
    "postgres"
  ]
}
```

When a version is specified, the `github.branch` from the tool config is overridden with the
given version string for all `reference-sourcecode` and `reference-config` fetches. The docs
URL is not affected — it uses whatever is defined in the tool config.

Reference skills are dormant when `tools` is `[]` or absent. No other config is
required — Claude loads `config/tools/<name>.json` from the plugin at runtime.

---

## Adding a new tool to the plugin

Use `add-tool.sh` to scaffold the JSON definition:

```bash
./scripts/add-tool.sh \
  --name grafana \
  --description "Metrics dashboarding and alerting platform" \
  --docs-url "https://grafana.com/docs/grafana/latest/" \
  --github grafana/grafana \
  --branch main \
  --examples "dashboard provisioning,alerting rules,data sources,plugins" \
  --api-url "https://grafana.com/docs/grafana/latest/developers/http_api/" \
  --aliases "grafana-oss" \
  --config-paths "conf/defaults.ini" \
  --related-repos "grafana/loki,grafana/tempo"
```

All options after `--branch` are optional. Omit any flags that do not apply to the tool.

This creates `config/tools/grafana.json`. Any project can then enable it with
`{ "tools": ["grafana"] }`.

---

## Copying a tool config into a project (offline / standalone)

For projects that cannot reference the plugin path directly, copy the config into
the project with `enable-tool.sh`:

```bash
# Run from the plugin directory, passing the target project path
./scripts/enable-tool.sh filebrowser /path/to/my-project
```

This copies `config/tools/filebrowser.json` into
`/path/to/my-project/.claude-plugin/tools/filebrowser.json`.

The reference skills check `.claude-plugin/tools/` first, then fall back to the
plugin-relative `config/tools/` path.

---

## Bundled tool definitions

| Tool | Description |
|------|-------------|
| `filebrowser` | Web-based file manager for self-hosted environments |
| `navidrome` | Self-hosted music streaming server compatible with the Subsonic API |
| `caddy` | Fast, extensible multi-platform web server with automatic HTTPS |
| `fail2ban` | Security daemon that blocks IPs conducting repeated failed login attempts |
| `nginx` | High-performance HTTP server, reverse proxy, and load balancer |
| `docker` | Docker Engine CLI, Dockerfile authoring, image building, and registry management |
| `docker-compose` | Multi-container application definition and orchestration using compose.yaml |
| `docker-buildx` | Extended image building with BuildKit: multi-platform builds, cache backends, and build secrets |
| `prometheus` | Open-source monitoring and alerting toolkit — metrics collection, PromQL querying, and alerting rules |
| `grafana` | Open-source observability platform — dashboards, alerting, and data source integrations for metrics, logs, and traces |
| `elasticsearch` | Distributed search and analytics engine — full-text search, structured queries, aggregations, and vector search |
| `kibana` | Data visualisation and exploration UI for Elasticsearch — dashboards, Discover, Lens, Maps, and alerting |
| `kafka` | Distributed event streaming platform — high-throughput message queues, topics, partitions, consumer groups, and Kafka Streams |
| `rabbitmq` | Message broker supporting AMQP, MQTT, and STOMP — exchanges, queues, bindings, routing, and clustering |
| `redis` | In-memory data structure store — caching, pub/sub, sorted sets, streams, Lua scripting, and Redis Cluster |
| `postgres` | Advanced open-source relational database — SQL, JSONB, full-text search, partitioning, extensions, and replication |
| `mongodb` | Document-oriented NoSQL database — flexible schemas, aggregation pipelines, Atlas Search, transactions, and sharding |
| `clickhouse` | Column-oriented OLAP database — high-performance analytical queries, MergeTree engines, materialized views, and distributed tables |
| `kubernetes` | Container orchestration — workloads, services, ingress, RBAC, config maps, persistent volumes, and cluster management |
| `helm` | Kubernetes package manager — chart authoring, values, templating, releases, hooks, and repository management |
| `traefik` | Cloud-native reverse proxy and load balancer — routers, middlewares, services, TLS, and Let's Encrypt auto-certs |
| `github-actions` | CI/CD automation — workflows, jobs, reusable actions, secrets, environments, and self-hosted runners |
| `logstash` | Server-side data processing pipeline — inputs, filters, outputs, codecs, and Elastic Stack ingest |
| `opentelemetry` | Observability framework — distributed tracing, metrics, and logs SDK, collector config, and instrumentation |
| `sentry` | Error tracking and performance monitoring — SDK integration, issue grouping, traces, alerts, and source maps |
| `terraform` | Infrastructure as code — providers, resources, modules, state management, workspaces, and remote backends |
| `ansible` | Agentless IT automation — playbooks, roles, inventories, modules, handlers, Vault secrets, and collections |
| `rustfs` | S3-compatible object storage written in Rust — buckets, objects, multipart uploads, access policies, and high-throughput storage |
| `vault` | Secrets management — dynamic secrets, PKI, encryption as a service, auth methods, policies, and audit logging |
| `minio` | High-performance S3-compatible object storage — buckets, IAM policies, lifecycle rules, replication, and Kubernetes operator |
| `icecast` | Open-source streaming media server — mount points, relay, source clients, listener auth, and live audio/video broadcasting |
| `liquidsoap` | Audio and video streaming scripting language — sources, operators, outputs, scheduling, and live radio automation |
| `plex` | Plex Media Server — media library organisation, streaming, transcoding, remote access, and client management |
| `neo4j` | Graph database platform — Cypher queries, graph data modeling, indexes, constraints, and graph algorithms |
| `sqlite` | Embedded relational database — SQL queries, schema design, FTS5 full-text search, WAL mode, and JSON functions |
| `mysql` | Open-source relational database — SQL, stored procedures, replication, InnoDB engine, and partitioning |
| `mailserver` | Full-featured mail server in Docker — SMTP, IMAP, DKIM, SPF, DMARC, spam filtering, and TLS configuration |
| `keycloak` | Open-source identity and access management — SSO, OAuth2, OIDC, SAML, realms, clients, and user federation |
| `celery` | Distributed task queue — async tasks, periodic tasks, brokers, result backends, routing, and worker scaling |
| `loki` | Log aggregation system by Grafana — LogQL queries, label-based indexing, log streams, and ruler alerting |
| `tempo` | Distributed tracing backend by Grafana — trace ingestion, TraceQL queries, search, and metrics generation |
| `wireguard` | Modern VPN protocol — tunnel configuration, peer setup, key management, routing, and kernel integration |
| `tailscale` | Zero-config mesh VPN — device authentication, ACL policies, subnet routing, exit nodes, and MagicDNS |
| `pihole` | Network-level DNS ad blocker — blocklists, allowlists, DHCP server, query logging, and custom DNS records |
| `adguard-home` | Network-wide DNS ad blocker and privacy guard — filtering rules, DHCP, encrypted DNS, and parental controls |
| `portainer` | Container management UI — Docker and Kubernetes environments, stacks, registries, users, and RBAC |
| `crowdsec` | Collaborative security engine — behavior detection, bouncers, scenarios, hub collections, and CAPI sharing |
| `trivy` | Comprehensive vulnerability and misconfiguration scanner — containers, IaC, SBOMs, and secret detection |
