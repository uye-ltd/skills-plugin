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
    "sections": ["configuration", "installation", "docker", "api"]
  },
  "github": {
    "org": "filebrowser",
    "repo": "filebrowser",
    "branch": "master"
  },
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
| `docs.sections` | no | Known sub-paths appended to `docs.url` for targeted fetches |
| `github.org` | yes | GitHub organisation or user |
| `github.repo` | yes | Repository name |
| `github.branch` | yes | Default branch for raw file fetches |
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
  --examples "dashboard provisioning,alerting rules,data sources,plugins"
```

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
