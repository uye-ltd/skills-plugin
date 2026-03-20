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
#     [--examples "example1,example2,..."]
#
# Example:
#   ./scripts/add-tool.sh \
#     --name grafana \
#     --description "Metrics dashboarding and alerting platform" \
#     --docs-url "https://grafana.com/docs/grafana/latest/" \
#     --github grafana/grafana \
#     --branch main \
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

usage() {
  echo "Usage: $0 --name <name> --description <desc> --docs-url <url> --github <org/repo> --branch <branch> [--sections <s1,s2>] [--examples <e1,e2>]"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)        NAME="$2";        shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --docs-url)    DOCS_URL="$2";    shift 2 ;;
    --github)      GITHUB_SLUG="$2"; shift 2 ;;
    --branch)      BRANCH="$2";      shift 2 ;;
    --sections)    SECTIONS="$2";    shift 2 ;;
    --examples)    EXAMPLES="$2";    shift 2 ;;
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

python3 - "$OUTPUT" "$NAME" "$DESCRIPTION" "$DOCS_URL" "$ORG" "$REPO" "$BRANCH" "$SECTIONS" "$EXAMPLES" << 'PYEOF'
import sys, json

output, name, description, docs_url, org, repo, branch, sections_raw, examples_raw = sys.argv[1:]

sections = [s.strip() for s in sections_raw.split(",") if s.strip()] if sections_raw else []
examples = [e.strip() for e in examples_raw.split(",") if e.strip()] if examples_raw else []

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

with open(output, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PYEOF

echo "Created: config/tools/$NAME.json"
echo ""
echo "Projects can now enable this tool by adding \"$NAME\" to the tools array in settings.json:"
echo "  { \"tools\": [\"$NAME\"] }"
