#!/usr/bin/env bash
# update.sh — Re-install the uye plugin across multiple org repos.
#
# Usage:
#   ./scripts/update.sh /path/to/repo1 /path/to/repo2 ...
#   ./scripts/update.sh --from-file repos.txt
#
# repos.txt format: one repo path per line, # for comments
#
# This re-runs `claude plugin install` at project scope in each repo,
# updating .claude/settings.json to point to the latest plugin version.

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

REPOS=()
FROM_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --from-file)
      FROM_FILE="$2"
      shift 2
      ;;
    -*)
      echo "Unknown flag: $1" >&2
      exit 1
      ;;
    *)
      REPOS+=("$1")
      shift
      ;;
  esac
done

# Load repos from file
if [ -n "$FROM_FILE" ]; then
  if [ ! -f "$FROM_FILE" ]; then
    echo "Error: repos file '$FROM_FILE' not found" >&2
    exit 1
  fi
  while IFS= read -r line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    REPOS+=("$line")
  done < "$FROM_FILE"
fi

if [ ${#REPOS[@]} -eq 0 ]; then
  echo "Usage: $0 /path/to/repo1 /path/to/repo2 ..."
  echo "       $0 --from-file repos.txt"
  exit 1
fi

PLUGIN_VERSION=$(python3 -c "import json; print(json.load(open('$PLUGIN_DIR/.claude-plugin/plugin.json'))['version'])" 2>/dev/null || echo "unknown")

echo "Updating uye plugin v$PLUGIN_VERSION across ${#REPOS[@]} repo(s)..."
echo "Plugin: $PLUGIN_DIR"
echo ""

SUCCESS=0
FAILED=0

for repo in "${REPOS[@]}"; do
  if [ ! -d "$repo" ]; then
    printf "\033[31m✘ %-50s not found\033[0m\n" "$repo"
    ((FAILED++)) || true
    continue
  fi

  if (claude plugin marketplace add "$PLUGIN_DIR" --scope user > /dev/null 2>&1 && cd "$repo" && claude plugin install uye --scope project > /dev/null 2>&1); then
    printf "\033[32m✔ %-50s updated\033[0m\n" "$repo"
    ((SUCCESS++)) || true
  else
    printf "\033[31m✘ %-50s failed\033[0m\n" "$repo"
    ((FAILED++)) || true
  fi
done

echo ""
echo "Done: $SUCCESS updated, $FAILED failed"

if [ "$FAILED" -gt 0 ]; then
  echo "Run manually for failed repos:"
  echo "  claude plugin marketplace add '$PLUGIN_DIR' --scope user"
  echo "  cd <repo> && claude plugin install uye --scope project"
  exit 1
fi
