#!/usr/bin/env bash
# add-tool.sh — Add a new tool definition to config/tools/.
#
# Usage:
#   ./scripts/add-tool.sh \
#     --name <tool-name> \
#     --description "<description>" \
#     --docs-url <url> \
#     --github <org/repo> \
#     --branch <branch> \
#     [--sections "section1,section2,..."] \
#     [--examples "example1,example2,..."] \
#     [--api-url <url>] \
#     [--aliases "alias1,alias2,..."] \
#     [--config-paths "path1,path2,..."] \
#     [--related-repos "org1/repo1,org2/repo2,...]
#
# Example:
#   ./scripts/add-tool.sh \
#     --name grafana \
#     --description "Metrics dashboarding and alerting platform" \
#     --docs-url "https://grafana.com/docs/grafana/latest/" \
#     --github grafana/grafana \
#     --branch main \
#     --api-url "https://grafana.com/docs/grafana/latest/developers/http_api/" \
#     --examples "dashboard provisioning,alerting rules,data sources"

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

NAME=""
DESCRIPTION=""
DOCS_URL=""
GITHUB_SLUG=""
BRANCH=""
SECTIONS=""
EXAMPLES=""
API_URL=""
ALIASES=""
CONFIG_PATHS=""
RELATED_REPOS=""

usage() {
  echo "Usage: $0 --name <name> --description <desc> --docs-url <url> --github <org/repo> --branch <branch> [--sections <s1,s2>] [--examples <e1,e2>] [--api-url <url>] [--aliases <a1,a2>] [--config-paths <p1,p2>] [--related-repos <org1/repo1,org2/repo2>]"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)          NAME="$2";          shift 2 ;;
    --description)   DESCRIPTION="$2";   shift 2 ;;
    --docs-url)      DOCS_URL="$2";      shift 2 ;;
    --github)        GITHUB_SLUG="$2";   shift 2 ;;
    --branch)        BRANCH="$2";        shift 2 ;;
    --sections)      SECTIONS="$2";      shift 2 ;;
    --examples)      EXAMPLES="$2";      shift 2 ;;
    --api-url)       API_URL="$2";       shift 2 ;;
    --aliases)       ALIASES="$2";       shift 2 ;;
    --config-paths)  CONFIG_PATHS="$2";  shift 2 ;;
    --related-repos) RELATED_REPOS="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [ -z "$NAME" ] || [ -z "$DESCRIPTION" ] || [ -z "$DOCS_URL" ] || [ -z "$GITHUB_SLUG" ] || [ -z "$BRANCH" ]; then
  usage
fi

if [[ "$GITHUB_SLUG" != */* ]]; then
  echo "Error: --github must be in <org>/<repo> format" >&2
  exit 1
fi

ORG="${GITHUB_SLUG%%/*}"
REPO="${GITHUB_SLUG##*/}"

CONFIG_DIR="$PLUGIN_DIR/config/tools"
mkdir -p "$CONFIG_DIR"

OUTPUT="$CONFIG_DIR/$NAME.json"

if [ -f "$OUTPUT" ]; then
  echo "Error: config/tools/$NAME.json already exists" >&2
  exit 1
fi

python3 - "$OUTPUT" "$NAME" "$DESCRIPTION" "$DOCS_URL" "$ORG" "$REPO" "$BRANCH" "$SECTIONS" "$EXAMPLES" "$API_URL" "$ALIASES" "$CONFIG_PATHS" "$RELATED_REPOS" << 'PYEOF'
import sys, json

output, name, description, docs_url, org, repo, branch, sections_raw, examples_raw, api_url, aliases_raw, config_paths_raw, related_repos_raw = sys.argv[1:]

sections      = [s.strip() for s in sections_raw.split(",")      if s.strip()] if sections_raw      else []
examples      = [e.strip() for e in examples_raw.split(",")      if e.strip()] if examples_raw      else []
aliases       = [a.strip() for a in aliases_raw.split(",")       if a.strip()] if aliases_raw       else []
config_paths  = [p.strip() for p in config_paths_raw.split(",")  if p.strip()] if config_paths_raw  else []

related_repos = []
if related_repos_raw:
    for slug in related_repos_raw.split(","):
        slug = slug.strip()
        if "/" in slug:
            r_org, r_repo = slug.split("/", 1)
            related_repos.append({"org": r_org.strip(), "repo": r_repo.strip()})

data = {
    "name": name,
    "description": description,
    "docs": {
        "url": docs_url,
        "sections": sections
    },
    "github": {
        "org": org,
        "repo": repo,
        "branch": branch
    },
    "examples": examples
}

if api_url:
    data["docs"]["api_url"] = api_url

if aliases:
    data["aliases"] = aliases

if config_paths:
    data["config"] = {"paths": config_paths}

if related_repos:
    data["github"]["related_repos"] = related_repos

with open(output, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PYEOF

echo "Created: config/tools/$NAME.json"
echo ""
echo "Projects can now enable this tool by adding \"$NAME\" to the tools array in settings.json:"
echo "  { \"tools\": [\"$NAME\"] }"
