#!/bin/bash
# install.sh — sets up ~/.claude/ from claude-armory
# Usage: bash install.sh

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "claude-armory installer"
echo "========================"
echo "Target: $CLAUDE_DIR"
echo ""

mkdir -p "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/commands" "$CLAUDE_DIR/agent_docs" "$CLAUDE_DIR/skills/caveman" "$CLAUDE_DIR/skills/caveman-compress"

# CLAUDE.md
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  cp "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.bak"
  echo "  backed up existing CLAUDE.md -> CLAUDE.md.bak"
fi
cp "$REPO_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "  CLAUDE.md"

# gotchas.md — don't overwrite if it already has entries
if [ ! -f "$CLAUDE_DIR/gotchas.md" ]; then
  cp "$REPO_DIR/gotchas.md" "$CLAUDE_DIR/gotchas.md"
  echo "  gotchas.md"
else
  echo "  gotchas.md already exists, skipping"
fi

# Hooks
for hook in "$REPO_DIR/hooks/"*.sh; do
  name=$(basename "$hook")
  cp "$hook" "$CLAUDE_DIR/hooks/$name"
  chmod +x "$CLAUDE_DIR/hooks/$name"
  echo "  hooks/$name"
done

# Slash commands
for cmd in "$REPO_DIR/commands/"*.md; do
  name=$(basename "$cmd")
  cp "$cmd" "$CLAUDE_DIR/commands/$name"
  echo "  commands/$name"
done

# Agent docs
for doc in "$REPO_DIR/agent_docs/"*.md; do
  name=$(basename "$doc")
  cp "$doc" "$CLAUDE_DIR/agent_docs/$name"
  echo "  agent_docs/$name"
done

# Caveman skills
cp "$REPO_DIR/skills/caveman/SKILL.md" "$CLAUDE_DIR/skills/caveman/SKILL.md"
echo "  skills/caveman/SKILL.md"
cp "$REPO_DIR/skills/caveman-compress/SKILL.md" "$CLAUDE_DIR/skills/caveman-compress/SKILL.md"
echo "  skills/caveman-compress/SKILL.md"

# settings.json — replace CLAUDE_DIR placeholder with real path
SETTINGS_DST="$CLAUDE_DIR/settings.json"
if [ ! -f "$SETTINGS_DST" ]; then
  sed "s|CLAUDE_DIR|$CLAUDE_DIR|g" "$REPO_DIR/settings.json" > "$SETTINGS_DST"
  echo "  settings.json (created)"
else
  cp "$SETTINGS_DST" "$SETTINGS_DST.bak"
  echo "  settings.json already exists — backed up to settings.json.bak"
  echo "  reference config saved to settings.json.armory-example"
  sed "s|CLAUDE_DIR|$CLAUDE_DIR|g" "$REPO_DIR/settings.json" > "$CLAUDE_DIR/settings.json.armory-example"
  echo "  Manually merge hooks from settings.json.armory-example if needed"
fi

echo ""
echo "Done. Restart Claude Code for changes to take effect."
echo ""
echo "Next steps:"
echo "  1. Edit ~/.claude/CLAUDE.md — update Author section with your name/email"
echo "  2. Review ~/.claude/agent_docs/ — remove docs for stacks you don't use"
echo "  3. Add your MCP servers via: claude mcp add <server>"
