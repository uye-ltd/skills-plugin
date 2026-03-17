#!/usr/bin/env bash
# release.sh — Cut a new plugin release.
#
# Usage:
#   ./scripts/release.sh <version>
#
# Example:
#   ./scripts/release.sh 2.1.0
#
# Does:
#   1. Validates plugin structure
#   2. Bumps version in .claude-plugin/plugin.json
#   3. Prepends a CHANGELOG.md entry with commits since the last tag
#   4. Prints next steps (commit + tag)

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-}"

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 2.1.0"
  exit 1
fi

# Validate semver format
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
  echo "Error: '$VERSION' is not a valid semver (expected MAJOR.MINOR.PATCH)" >&2
  exit 1
fi

PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"
CHANGELOG="$PLUGIN_DIR/CHANGELOG.md"
TODAY=$(date +%Y-%m-%d)

# ── 1. Validate ───────────────────────────────────────────────────────────────
echo "Validating plugin..."
if ! "$PLUGIN_DIR/scripts/validate.sh" > /dev/null 2>&1; then
  echo ""
  echo "Validation failed. Fix errors before releasing:"
  "$PLUGIN_DIR/scripts/validate.sh"
  exit 1
fi
echo "  ✔ Validation passed"

# ── 2. Check current version ──────────────────────────────────────────────────
CURRENT_VERSION=$(python3 -c "import json; print(json.load(open('$PLUGIN_JSON'))['version'])" 2>/dev/null)
echo "  Current version: $CURRENT_VERSION → $VERSION"

# ── 3. Bump version in plugin.json ────────────────────────────────────────────
python3 - "$PLUGIN_JSON" "$VERSION" << 'PYEOF'
import sys, json
path, version = sys.argv[1], sys.argv[2]
with open(path) as f:
    data = json.load(f)
data["version"] = version
with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PYEOF
echo "  ✔ Bumped version in plugin.json"

# ── 4. Get commits since last tag ─────────────────────────────────────────────
cd "$PLUGIN_DIR"
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -n "$LAST_TAG" ]; then
  COMMITS=$(git log "$LAST_TAG"..HEAD --oneline --no-merges 2>/dev/null || echo "")
else
  COMMITS=$(git log --oneline --no-merges 2>/dev/null | head -20 || echo "")
fi

# ── 5. Prepend CHANGELOG entry ────────────────────────────────────────────────
TMPFILE=$(mktemp)

cat > "$TMPFILE" << ENTRY
## [$VERSION] - $TODAY

### Added
- TODO: list new skills, agents, or features

### Changed
- TODO: list modified behaviour

### Fixed
- TODO: list bug fixes

### Commits since $LAST_TAG
$(echo "$COMMITS" | sed 's/^/- /')

ENTRY

# Prepend after the header (first line "# Changelog" + blank line + "All notable...")
HEAD_LINES=4
head -n $HEAD_LINES "$CHANGELOG" >> "$TMPFILE" 2>/dev/null || true
echo "" >> "$TMPFILE"
tail -n +$((HEAD_LINES + 1)) "$CHANGELOG" >> "$TMPFILE" 2>/dev/null || true
mv "$TMPFILE" "$CHANGELOG"

echo "  ✔ Prepended CHANGELOG entry for v$VERSION"

# ── 6. Summary ────────────────────────────────────────────────────────────────
echo ""
echo "Release v$VERSION prepared. Next steps:"
echo ""
echo "  1. Edit CHANGELOG.md — fill in Added / Changed / Fixed sections"
echo "  2. Review changes:"
echo "     git diff"
echo "  3. Commit and tag:"
echo "     git add .claude-plugin/plugin.json CHANGELOG.md"
echo "     git commit -m \"chore: release v$VERSION\""
echo "     git tag v$VERSION"
echo "  4. Push and update org repos:"
echo "     git push && git push --tags"
echo "     ./scripts/update.sh --from-file repos.txt"
