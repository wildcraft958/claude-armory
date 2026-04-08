#!/bin/bash
# mempal_wing_detect.sh
# Detects which MemPalace wing matches the current project.
# Checks current directory name + git remote URL against wing keywords.
# Prints the matched wing name and exits 0. Exits 1 if no match.
#
# Usage in CLAUDE.md session start:
#   WING=$(bash ~/.claude/hooks/mempal_wing_detect.sh)
#   [ -n "$WING" ] && call mempalace_kg_query for $WING

WING_CONFIG="$HOME/.mempalace/wing_config.json"

if [ ! -f "$WING_CONFIG" ]; then
    exit 1
fi

# Build search string: directory name + git remote repo name
PROJECT_DIR=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')
GIT_REMOTE=$(git remote get-url origin 2>/dev/null \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's|.*[/:]||' \
    | sed 's/\.git$//')
SEARCH="${PROJECT_DIR} ${GIT_REMOTE}"

python3 - "$WING_CONFIG" "$SEARCH" <<'PYEOF'
import json, sys

config = json.load(open(sys.argv[1]))
search = sys.argv[2].lower()

for wing_name, wing_data in config.get("wings", {}).items():
    for kw in wing_data.get("keywords", []):
        if kw and kw.lower() in search:
            print(wing_name)
            sys.exit(0)

sys.exit(1)
PYEOF
