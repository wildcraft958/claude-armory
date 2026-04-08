You are helping retire a software project cleanly and completely. Walk through every layer of cleanup in the correct order (secrets first, then data, then code, then infra).

Project name / path from arguments: $ARGUMENTS
If no argument: ask the user which project before proceeding.

**Do NOT skip steps silently. For each step: run it or explain why it doesn't apply.**

---

## Step 1 — Pre-Retirement Audit (do this before deleting anything)

Run `/audit` to surface any security issues that need fixing before the code is archived. A retired codebase with unfixed injection bugs is still a liability if the repo is public.

Check what's in MemPalace for this project:
```
mempalace search "[project name]" 2>/dev/null
mempalace wake-up --wing wing_[project_wing] 2>/dev/null
```

Export key decisions to a permanent doc before session history is deleted:
```bash
# Summarize the palace wing for archival
mempalace search "decision OR architecture OR chose OR switched" --wing wing_[name] 2>/dev/null > /tmp/[project]-decisions.txt
```

---

## Step 2 — Secrets Rotation (MOST CRITICAL — do this before archiving the repo)

This must happen first. If secrets are in git history and the repo goes public, they are permanently compromised.

```bash
# Scan git history for committed secrets
git log --all --full-history -- "*.env" 2>/dev/null
grep -rn --include="*.{py,js,ts,json,yaml,yml,sh}" \
  -E "(api_key|secret|password|token)\s*[=:]\s*['\"][^'\"]{8,}" . \
  | grep -v -E "example|test|mock|placeholder"
```

For each secret found or used during development:
- [ ] Rotate the API key (invalidate old, generate new)
- [ ] Revoke OAuth tokens / service account credentials
- [ ] Rotate Supabase `service_role` key (Settings > API > Reset)
- [ ] Rotate any database passwords
- [ ] Remove secrets from `.env` files and document what was there (not the values)
- [ ] If secrets were committed to git history: use `git filter-repo` to purge, then force-push

---

## Step 3 — MemPalace Wing Cleanup

Three options — choose based on whether you might revisit this project:

**Option A: Keep wing (recommended if any chance of revisiting)**
Do nothing. Wing stays searchable, ~50-200MB, stops growing once mining stops. Cross-project searches still surface it.

**Option B: Compress (good middle ground)**
```bash
mempalace compress --wing wing_[name]
```
AAAK-compresses drawers to ~30% original size. Slightly lower recall (84% vs 97%) but still useful.

**Option C: Delete wing (final, irreversible)**
```bash
# No built-in delete-wing command — do it via Python
python3 -c "
import chromadb
client = chromadb.PersistentClient(path='/home/bakasur/.mempalace/palace')
col = client.get_collection('mempalace_drawers')
results = col.get(where={'wing': 'wing_[name]'})
if results['ids']:
    col.delete(ids=results['ids'])
    print(f'Deleted {len(results[\"ids\"])} drawers from wing_[name]')
else:
    print('Wing not found or already empty')
"
```

---

## Step 4 — Claude Code Full Cleanup (sessions + file-history + worktrees)

Claude Code creates three separate stores while you work. Clean all three.

```bash
PROJECT_DIR=$(ls ~/.claude/projects/ | grep -i "[project_slug]" | head -1)
PROJECT_PATH="$(pwd)"  # absolute path of the project
echo "Project dir: ~/.claude/projects/$PROJECT_DIR"
echo "Project path: $PROJECT_PATH"

# Export MEMORY.md before deleting anything
cp ~/.claude/projects/$PROJECT_DIR/memory/MEMORY.md /tmp/[project]-claude-memory.txt 2>/dev/null && \
  echo "Memory exported"

# 4a. Delete session JSONL files (bulk of the session size) — keep memory/
find ~/.claude/projects/$PROJECT_DIR/ -name "*.jsonl" -delete 2>/dev/null
echo "Session JSONL files deleted"

# 4b. file-history — Claude Code snapshots every file it edits here.
#     Find entries that belong to this project by path stored inside them.
#     WARNING: this dir has a known 300GB bug — always clean it per-project.
echo "Scanning ~/.claude/file-history for this project's entries..."
python3 - <<'PYEOF'
import os, json, shutil

file_history = os.path.expanduser("~/.claude/file-history")
project_path = os.getcwd()  # run from inside the project directory
removed = 0

for entry in os.listdir(file_history):
    entry_path = os.path.join(file_history, entry)
    if not os.path.isdir(entry_path):
        continue
    # Each entry dir contains JSON files with a "path" field
    for fname in os.listdir(entry_path):
        fpath = os.path.join(entry_path, fname)
        try:
            with open(fpath) as f:
                data = json.load(f)
            if str(data.get("path", "")).startswith(project_path):
                shutil.rmtree(entry_path)
                removed += 1
                break
        except Exception:
            pass

print(f"Removed {removed} file-history entries for {project_path}")
PYEOF

# 4c. Worktrees — Claude Code creates these under ~/.claude-worktrees/
#     They accumulate if sessions end improperly.
echo "Checking for stale worktrees..."
WORKTREE_DIR="$HOME/.claude-worktrees"
if [ -d "$WORKTREE_DIR" ]; then
    for wt in "$WORKTREE_DIR"/*/; do
        # A worktree is stale if its linked repo path starts with our project path
        linked=$(git -C "$wt" rev-parse --show-toplevel 2>/dev/null || echo "")
        if [[ "$linked" == "$PROJECT_PATH"* ]]; then
            git worktree remove --force "$wt" 2>/dev/null || rm -rf "$wt"
            echo "Removed worktree: $wt"
        fi
    done
fi

# 4d. Shell snapshots for this project's sessions
find ~/.claude/shell-snapshots/ -name "*.json" 2>/dev/null | while read f; do
    grep -l "$PROJECT_PATH" "$f" 2>/dev/null
done | xargs rm -f 2>/dev/null
echo "Shell snapshots cleaned"

# Optional: delete entire project dir (loses all memory too)
# rm -rf ~/.claude/projects/$PROJECT_DIR/
```

---

## Step 5 — Local Repository Cleanup

```bash
# Dependencies (venv/node_modules — the big ones)
rm -rf node_modules/ .pnpm-store/ 2>/dev/null
rm -rf .venv/ venv/ env/ .virtualenv/ 2>/dev/null

# Build outputs
rm -rf dist/ build/ out/ .next/ .nuxt/ .svelte-kit/ 2>/dev/null
rm -rf .turbo/ .parcel-cache/ .webpack/ 2>/dev/null

# Python bytecode
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -o -name "*.pyo" | xargs rm -f 2>/dev/null || true

# Test + coverage artifacts
rm -rf .pytest_cache/ coverage/ htmlcov/ .nyc_output/ .coverage 2>/dev/null

# Generated / temp files created during development
find . -name "*.log" -o -name "*.log.*" | xargs rm -f 2>/dev/null || true
find . -name "*.tmp" -o -name "*.temp" | xargs rm -f 2>/dev/null || true
rm -rf uploads/ media/ static/uploads/ tmp/ temp/ 2>/dev/null

# Local dev databases (SQLite files in project dir)
find . -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" | \
  grep -v "node_modules\|venv\|.venv" | xargs rm -f 2>/dev/null || true

# .env files (only after secrets are rotated in Step 2)
find . -name ".env*" ! -name ".env.example" ! -name ".env.sample" | xargs rm -f 2>/dev/null || true
echo "Local .env files removed"

# Docker: stop containers, remove named volumes for this project
if [ -f "docker-compose.yml" ] || [ -f "compose.yml" ]; then
    docker compose down -v 2>/dev/null || true
    docker image prune -f 2>/dev/null || true
fi

# Check remaining size after cleanup
du -sh .

# 5a. Globally installed packages (if no venv was used)
#     List packages that match project name or known deps — confirm before uninstalling
echo ""
echo "=== Global packages to review (confirm before uninstalling) ==="
# Replace with actual project-specific package names
pip show [main-package-name] 2>/dev/null | grep -E "Name|Location"
npm list -g --depth=0 2>/dev/null | grep -i "[project]" || true
echo "Run: pip uninstall [package] OR npm uninstall -g [package] for each above"

---

## Step 6 — Git Cleanup

```bash
# Tag final state before archiving
git tag v$(date +%Y.%m)-final 2>/dev/null || git tag final-$(date +%Y%m%d)
git push origin --tags 2>/dev/null

# Delete merged branches (keep main/master)
git branch --merged main | grep -v "^\*\|main\|master" | xargs git branch -d 2>/dev/null || true

# Push cleanup
git push origin --prune 2>/dev/null || true

echo "Final commit: $(git log -1 --oneline)"
echo "Tags: $(git tag -l)"
```

---

## Step 7 — GitHub / Remote Archival

Do ONE of these:

**Archive (recommended — keeps code searchable, read-only)**
```bash
gh repo archive [owner]/[repo] --yes 2>/dev/null && echo "Repo archived on GitHub"
```

**Keep private but rename**
```bash
gh repo rename [repo]-archived --yes 2>/dev/null
```

**Delete (irreversible)**
```bash
# gh repo delete [owner]/[repo] --yes
# Don't run this automatically — confirm with user first
echo "MANUAL STEP: gh repo delete [owner]/[repo] --yes"
```

---

## Step 8 — Cloud / Infra Teardown

Check and teardown each resource that was used:

```bash
# Supabase: list projects (requires supabase CLI)
supabase projects list 2>/dev/null | grep -i "[project]"
# Then: supabase projects delete [project-ref] (requires confirmation in dashboard)

# Vercel deployments
# vercel rm [project] --yes 2>/dev/null

# Railway
# railway down 2>/dev/null

# AWS (careful — list first)
# aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE
```

Report which cloud resources exist and require manual teardown (don't auto-delete infra).

---

## Step 9 — Dependency Registry Cleanup

```bash
# If you published to npm
npm deprecate [package]@"*" "Project retired $(date +%Y-%m-%d)" 2>/dev/null || true

# If you published to PyPI — note: PyPI doesn't support deletion
# Best practice: yank all versions
pip index versions [package] 2>/dev/null | head -5
echo "To yank from PyPI: pip yank [package]==[version] for each version"
```

---

## Step 10 — MCP Server Cleanup

```bash
# List registered MCP servers
claude mcp list 2>/dev/null

# Remove any project-specific ones
# claude mcp remove [server-name]
```

Remove the wing from wing_config.json if you chose Option C (delete):
```bash
python3 -c "
import json
path = '/home/bakasur/.mempalace/wing_config.json'
config = json.load(open(path))
wing_key = 'wing_[name]'
if wing_key in config.get('wings', {}):
    del config['wings'][wing_key]
    json.dump(config, open(path, 'w'), indent=2)
    print(f'Removed {wing_key} from wing_config.json')
"
```

---

## Final Checklist

Print a retirement summary:
```
Project: [name]
Retired: [date]
Secrets rotated: YES/NO (list which ones)
Git tagged: [tag name]
Repo status: Archived / Private / Deleted
MemPalace wing: Kept / Compressed / Deleted
Claude sessions: Cleared (JSONL deleted, memory kept/deleted)
Claude file-history: N entries removed
Claude worktrees: N stale worktrees removed
Local deps: node_modules / .venv removed
Local generated files: logs, uploads, tmp, .env removed
Local dev DBs: N SQLite files removed
Docker volumes: removed / N/A
Global packages: reviewed (list any manually uninstalled)
Cloud resources: Cleaned / Pending (list remaining)
Exported decisions: /tmp/[project]-decisions.txt
```

$ARGUMENTS
