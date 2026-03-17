#!/usr/bin/env bash
# format-js.sh — PostToolUse hook: run prettier or eslint --fix on JS/TS files.
#
# Triggered by: PostToolUse on Write|Edit tools
# Input: JSON on stdin with tool_name and tool_input.file_path
# Requires: prettier (global or ./node_modules/.bin/prettier) or eslint with --fix

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")

# Only process JS/TS files
case "$FILE_PATH" in
  *.js|*.jsx|*.ts|*.tsx) ;;
  *) exit 0 ;;
esac

if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Resolve prettier: prefer local project binary, fall back to global
PRETTIER=""
if [ -x "./node_modules/.bin/prettier" ]; then
  PRETTIER="./node_modules/.bin/prettier"
elif command -v prettier &> /dev/null; then
  PRETTIER="prettier"
fi

if [ -n "$PRETTIER" ]; then
  "$PRETTIER" --write "$FILE_PATH" 2>/dev/null || true
  exit 0
fi

# Fallback: resolve eslint with --fix
ESLINT=""
if [ -x "./node_modules/.bin/eslint" ]; then
  ESLINT="./node_modules/.bin/eslint"
elif command -v eslint &> /dev/null; then
  ESLINT="eslint"
fi

if [ -n "$ESLINT" ]; then
  "$ESLINT" --fix "$FILE_PATH" 2>/dev/null || true
  exit 0
fi

# Neither tool found — exit silently to avoid breaking the workflow
exit 0
