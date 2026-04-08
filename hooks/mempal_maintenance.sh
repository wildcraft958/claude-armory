#!/bin/bash
# Full Claude Code + MemPalace weekly maintenance
# Covers: ChromaDB WAL, SQLite VACUUM, session/debug/paste-cache pruning, file-history alert
# Schedule: Sunday 2am via cron
# Manual run: bash ~/.claude/hooks/mempal_maintenance.sh

set -euo pipefail
LOG="[maintenance $(date '+%Y-%m-%d %H:%M')]"
PALACE="${MEMPALACE_PALACE_PATH:-$HOME/.mempalace/palace}"

echo "$LOG === FULL SETUP MAINTENANCE ==="

# 1. ChromaDB WAL + orphaned segments (main MemPalace bloat source)
if command -v chops &>/dev/null && [ -d "$PALACE" ]; then
    echo "$LOG Cleaning ChromaDB WAL..."
    chops cleanup-wal "$PALACE" 2>/dev/null || echo "$LOG WARN: cleanup-wal failed, skipping"
    echo "$LOG Cleaning orphaned HNSW segments..."
    chops db clean "$PALACE" 2>/dev/null || echo "$LOG WARN: db clean failed, skipping"
    echo "$LOG Configuring WAL auto-pruning..."
    chops wal config --purge auto "$PALACE" 2>/dev/null || true
else
    [ ! -d "$PALACE" ] && echo "$LOG Palace not yet created, skipping ChromaDB maintenance"
fi

# 2. VACUUM MemPalace SQLite DBs
vacuum_sqlite() {
    python3 -c "
import sqlite3, sys
db = sys.argv[1]
conn = sqlite3.connect(db)
conn.execute('VACUUM')
conn.execute('ANALYZE')
conn.close()
print('Done.')
" "$1"
}

for db in "$HOME/.mempalace/knowledge_graph.db" "$HOME/.mempalace/palace_graph.db"; do
    if [ -f "$db" ]; then
        echo -n "$LOG Vacuuming $(basename $db)... "
        vacuum_sqlite "$db"
    fi
done

# 3. VACUUM ChromaDB internal SQLite
CHROMA_SQLITE="$PALACE/chroma.sqlite3"
if [ -f "$CHROMA_SQLITE" ]; then
    echo -n "$LOG Vacuuming ChromaDB SQLite... "
    vacuum_sqlite "$CHROMA_SQLITE"
fi

# 4. Claude Code session cleanup: remove sessions older than 30 days
SESSION_DIR="$HOME/.claude/sessions"
if [ -d "$SESSION_DIR" ]; then
    PRUNED=$(find "$SESSION_DIR" -maxdepth 1 -type d -mtime +30 | wc -l)
    find "$SESSION_DIR" -maxdepth 1 -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
    echo "$LOG Pruned $PRUNED old session(s) from ~/.claude/sessions"
fi

# 5. Claude Code debug log cleanup (safe to delete, never pruned by Claude Code)
DEBUG_DIR="$HOME/.claude/debug"
if [ -d "$DEBUG_DIR" ]; then
    find "$DEBUG_DIR" -type f -mtime +7 -delete 2>/dev/null || true
    echo "$LOG Pruned debug logs older than 7 days"
fi

# 6. Paste cache cleanup (older than 14 days)
PASTE_DIR="$HOME/.claude/paste-cache"
if [ -d "$PASTE_DIR" ]; then
    find "$PASTE_DIR" -type f -mtime +14 -delete 2>/dev/null || true
    echo "$LOG Pruned paste cache older than 14 days"
fi

# 7. Size report
echo ""
echo "$LOG === SIZE REPORT ==="
for path in \
    "$HOME/.mempalace" \
    "$HOME/.claude/projects" \
    "$HOME/.claude/file-history" \
    "$HOME/.claude/sessions" \
    "$HOME/.claude/debug" \
    "$HOME/.claude/paste-cache"; do
    [ -e "$path" ] && du -sh "$path" 2>/dev/null | awk -v l="$LOG" '{print l "  " $0}'
done

# 8. DANGER ALERT: file-history bug detection
# Known bug: self-referential tracking loop caused 300GB on other machines
FH_SIZE=$(du -sm "$HOME/.claude/file-history" 2>/dev/null | cut -f1 || echo 0)
if [ "${FH_SIZE:-0}" -gt 500 ]; then
    echo ""
    echo "$LOG !!! WARNING: ~/.claude/file-history is ${FH_SIZE}MB !!!"
    echo "$LOG !!! Known bug can cause 300GB+ growth. Investigate immediately:"
    echo "$LOG !!! ls -lhS $HOME/.claude/file-history | head -20"
fi

echo ""
echo "$LOG Maintenance complete."
