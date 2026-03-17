#!/usr/bin/env bash
# format-python.sh — PostToolUse hook: run ruff format + ruff check --fix on Python files.
#
# Triggered by: PostToolUse on Write|Edit tools
# Input: JSON on stdin with tool_name and tool_input.file_path
# Requires: ruff (pip install ruff)

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")

# Only process Python files
if [[ "$FILE_PATH" != *.py ]] && [[ "$FILE_PATH" != *.pyi ]]; then
  exit 0
fi

if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

if ! command -v ruff &> /dev/null; then
  # ruff not installed — exit silently to avoid breaking the workflow
  exit 0
fi

# Format (equivalent to black)
ruff format "$FILE_PATH" 2>/dev/null || true

# Lint + auto-fix safe fixable issues
ruff check --fix --silent "$FILE_PATH" 2>/dev/null || true
