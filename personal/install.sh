#!/bin/bash
# personal/install.sh
# Installs the three files that cannot live inside the plugin, because Claude Code loads them
# from fixed paths in ~/.claude/ rather than from a plugin directory.
#
# Everything else (skills, the hook) comes from the plugin itself:
#   /plugin marketplace add wildcraft958/claude-armory
#   /plugin install armory@claude-armory
#
# This script never overwrites. It backs up anything it would replace, and it refuses to clobber
# settings.json, which is machine-specific (model, theme, enabled plugins) and must be merged.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
STAMP="$(date +%Y%m%d-%H%M%S)"

backup() {
  if [ -f "$1" ]; then
    cp "$1" "$1.bak-$STAMP"
    echo "  backed up $(basename "$1") -> $(basename "$1").bak-$STAMP"
  fi
}

mkdir -p "$CLAUDE_DIR/rules"

echo "Installing personal files into $CLAUDE_DIR"

backup "$CLAUDE_DIR/CLAUDE.md"
cp "$HERE/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "  CLAUDE.md"

backup "$CLAUDE_DIR/rules/lessons.md"
cp "$HERE/lessons.md" "$CLAUDE_DIR/rules/lessons.md"
echo "  rules/lessons.md"

# settings.json is merged, never replaced. Yours carries model, theme, and enabledPlugins that
# this repo has no business overwriting.
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  echo ""
  echo "  settings.json already exists and was NOT touched."
  echo "  Merge these keys into it by hand: permissions, autoMode, includeCoAuthoredBy."
  echo "  Reference copy: $HERE/settings.json"
  if command -v jq >/dev/null 2>&1; then
    echo ""
    echo "  Keys you are missing:"
    jq -n --slurpfile a "$CLAUDE_DIR/settings.json" --slurpfile b "$HERE/settings.json" \
      '($b[0] | keys) - ($a[0] | keys) | if length == 0 then "    (none)" else .[] | "    " + . end' -r
  fi
else
  cp "$HERE/settings.json" "$CLAUDE_DIR/settings.json"
  echo "  settings.json (created)"
fi

echo ""
echo "Done. Next:"
echo "  1. /plugin marketplace add wildcraft958/claude-armory"
echo "  2. /plugin install armory@claude-armory"
echo "  3. Optional MCP servers:"
echo "       claude mcp add --scope user repomix -- npx -y repomix --mcp"
echo "       claude mcp add --scope user axon -- axon mcp"
echo "  4. Restart Claude Code, then run /context to confirm CLAUDE.md and rules loaded."
