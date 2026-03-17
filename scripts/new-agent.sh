#!/usr/bin/env bash
# new-agent.sh — Scaffold a new agent from a template.
#
# Usage:
#   ./scripts/new-agent.sh <agent-name>
#
# Examples:
#   ./scripts/new-agent.sh security-reviewer
#   ./scripts/new-agent.sh data-engineer

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_NAME="${1:-}"

if [ -z "$AGENT_NAME" ]; then
  echo "Usage: $0 <agent-name>"
  echo "Example: $0 security-reviewer"
  exit 1
fi

AGENT_FILE="$PLUGIN_DIR/agents/$AGENT_NAME.md"

if [ -f "$AGENT_FILE" ]; then
  echo "Error: agent '$AGENT_NAME' already exists at $AGENT_FILE" >&2
  exit 1
fi

cat > "$AGENT_FILE" << EOF
---
name: $AGENT_NAME
description: TODO: describe this agent's specialisation and when Claude should invoke it. Be specific — Claude uses this description to decide when to hand off to this agent.
---

You are a TODO: [role and seniority level] with expertise in TODO: [domain].

Your strengths:
- TODO: list key areas of expertise
- TODO: ...

When working:
1. TODO: describe approach and methodology
2. TODO: list specific behaviours or constraints
3. TODO: note any conventions to follow
EOF

echo "Created: $AGENT_FILE"
echo ""
echo "Next steps:"
echo "  1. Edit $AGENT_FILE"
echo "  2. Test with: claude --plugin-dir $PLUGIN_DIR"
