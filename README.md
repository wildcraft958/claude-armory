# claude-armory

```
   \   |   /         claude-armory
    \  |  /          your full loadout for serious dev work
     \ | /           ──────────────────────────────────────────────────
  ----\|/----        Commands   11   /debug /review /ship /test
  ----/|\----                        /explain /agent /init /audit
     / | \                           /retire /caveman /caveman-compress
    /  |  \          Hooks       7   block-destructive    PreToolUse
   /   |   \                         post-edit-verify     PostToolUse
       |                             truncation-check     PostToolUse
   C L A U D E                       stop-verify          Stop
   A R M O R Y                       mempal-save          Stop
                                     mempal-precompact    PreCompact
                                     mempal-maintenance   (cron)
                    Memory           MemPalace — local ChromaDB palace
                    Agent Docs  7   debug · arch · ml_patterns
                                     api · database · safety · axon
                    MCP         7   github · supabase · playwright
                                     axon · repomix · ddgs · langchain
                    Stack            Python · TypeScript · Rust
                    Effort           alwaysThinking=true  level=high
```

Custom slash commands, safety hooks, deep-dive agent docs, caveman token compression, and MCP config — a production-grade Claude Code setup that keeps the agent accountable to senior-dev standards.

Built and battle-tested by [Animesh Raj](https://github.com/wildcraft958).

---

## What's Inside

| Layer | What it does |
|-------|-------------|
| `CLAUDE.md` | Global rules for every project — workflow, code style, git, planning |
| `hooks/` | Auto-run safety checks on every tool call — Claude cannot skip them |
| `commands/` | Custom slash commands (`/debug`, `/review`, `/ship`, and more) |
| `agent_docs/` | Deep-dive reference docs Claude reads before starting work on a topic |
| `commands/caveman.md` | `/caveman` — cuts output tokens ~75%, Claude talks like caveman, brain still big |
| `commands/caveman-compress.md` | `/caveman-compress <file>` — compresses CLAUDE.md / memory files, cuts input tokens ~45% |
| `commands/audit.md` | `/audit` — 6-phase codebase security and logic audit, OWASP Top 10, no explore agent |
| `commands/retire.md` | `/retire` — 10-step project retirement: secrets, data, code, infra in correct order |
| `hooks/mempal_save_hook.sh` | Auto-saves session to MemPalace on Stop (every 15 human messages) |
| `hooks/mempal_precompact_hook.sh` | Emergency save to MemPalace before context compression |
| `hooks/mempal_maintenance.sh` | Weekly ChromaDB WAL cleanup, SQLite VACUUM, bloat alert (run via cron) |
| `settings.json` | Hooks wiring, status line, model config |

---

## Caveman — Token Compression

Bundled from [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) — the viral skill that cuts ~75% of output tokens without losing technical accuracy.

**Before** (69 tokens):
> "The reason your React component is re-rendering is likely because you're creating a new object reference on each render cycle. When you pass an inline object as a prop, React's shallow comparison sees it as a different object every time, which triggers a re-render. I'd recommend using useMemo to memoize the object."

**After** (19 tokens):
> "New object ref each render. Inline object prop = new ref = re-render. Wrap in `useMemo`."

Same fix. 75% fewer tokens. Brain still big.

| Skill | Trigger | What it cuts | Savings |
|-------|---------|-------------|---------|
| `caveman` | `/caveman` or "talk like caveman" | Output tokens (Claude's responses) | ~65-75% |
| `caveman-compress` | `/caveman-compress CLAUDE.md` | Input tokens (memory files per session) | ~45% |

**Intensity levels** — `/caveman lite`, `/caveman full` (default), `/caveman ultra`

Stop with: "stop caveman" or "normal mode"

Credit: [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) — MIT license

---

## Slash Commands

| Command | What it does |
|---------|-------------|
| `/debug` | 5-step debug protocol: gather, read, diagnose, fix, prevent |
| `/review` | Code review with tiered findings (Critical / Important / Suggestion) |
| `/ship` | Full pre-commit quality pipeline: lint, type-check, tests, build |
| `/test` | Write tests following TDD rules (pytest / vitest) |
| `/explain` | Explain code at 4 levels: TL;DR, How it works, Connections, Gotchas |
| `/agent` | Scaffold a LangGraph agent with safety rails |
| `/init` | Scaffold a project-level Claude Code setup for any stack |
| `/audit` | 6-phase security + logic audit: OWASP Top 10, scanners, dead code, test gaps |
| `/retire` | 10-step project retirement checklist — secrets first, then data, code, infra |
| `/caveman` | Talk like caveman — drop filler, keep full accuracy. Supports `lite`, `full`, `ultra` |
| `/caveman-compress` | Compress a CLAUDE.md or memory file to save input tokens per session |

**`/audit` vs `/review`**: `/review` is PR-bounded (changed files only, merge decision). `/audit` is systemic — runs bandit, pip-audit, npm audit, grep for injection/XSS/weak crypto across the whole codebase.

---

## Hooks

These run automatically on every tool call. Claude cannot skip them.

| Event | Hook | What it does |
|-------|------|-------------|
| `PreToolUse (Bash)` | `block-destructive.sh` | Blocks `rm -rf /`, DB drops, force pushes, `.env` reads |
| `PostToolUse (Write/Edit)` | `post-edit-verify.sh` | Runs eslint or ruff on every edited file — blocks if lint fails |
| `PostToolUse (Grep/Bash)` | `truncation-check.sh` | Warns when output was truncated (>50K chars) |
| `Stop` | `stop-verify.sh` | Blocks "Done" unless the project compiles, lints, and tests pass |
| `Stop` | `mempal_save_hook.sh` | Auto-saves session to MemPalace every 40 human messages |
| `PreCompact` | `mempal_precompact_hook.sh` | Emergency save to MemPalace before context compression |
| `cron (Sun 2am)` | `mempal_maintenance.sh` | ChromaDB WAL cleanup, SQLite VACUUM, 300GB bug alert |

**Why hooks matter**

Without hooks, Claude can declare "Done!" after writing code that doesn't compile. With `stop-verify.sh`, the agent is blocked from completing until `tsc`, `ruff`, `mypy`, `pytest`, or `cargo check` all pass — depending on your stack. It's a CI gate that runs before Claude is allowed to declare victory.

**The MemPalace hooks** build persistent memory automatically. Every session is saved to a local ChromaDB palace and recalled at session start. No manual steps after setup.

**`mempal_wing_detect.sh`** is called at session start in CLAUDE.md. It greps `~/.mempalace/wing_config.json` for keywords matching the current project directory name and git remote URL. If a wing matches, MemPalace history is loaded. If not, palace calls are skipped entirely — no wasted time loading ChromaDB on unrecognized projects.

**Lite mode (low-resource machines)**

Create `~/.claude/.lite` to reduce hook overhead:

```bash
touch ~/.claude/.lite   # enable lite mode
rm ~/.claude/.lite      # disable (restore full verification)
```

When `.lite` is present:
- `post-edit-verify.sh` skips per-edit linting (saves 2-5s per edit)
- `stop-verify.sh` skips the test suite (keeps type-check + lint, skips pytest/npm test/cargo test)

Type-checking and linting still run at Stop. This is not "no verification" — it's "no tests on every save".

---

## Agent Docs

Claude reads these before starting work on a topic. They save you from re-explaining your conventions on every session.

Each doc has a `> Stack:` line at the top. Claude skips docs whose stack doesn't match the current project — no noise for plain CRUD apps from LangGraph patterns.

| File | Stack | Read when... |
|------|-------|-------------|
| `debug_guide.md` | Python / FastAPI / LangGraph / React / Supabase | Debugging errors |
| `architecture.md` | FastAPI + React (full-stack) | Building features, project structure |
| `ml_patterns.md` | LangGraph, RAG, pgvector, HuggingFace | Building AI features |
| `api_conventions.md` | FastAPI (Python) | Building or modifying API endpoints |
| `database.md` | Supabase + pgvector | Working with the database layer |
| `context_and_safety.md` | Any | Context management, edit safety, hook behavior |
| `axon_guide.md` | Any | Refactors, renames, blast-radius analysis |

---

## Key Behaviors (from CLAUDE.md)

- **TDD**: tests first, then implement
- **Planning**: plan only when asked, no code until told to proceed — non-trivial features need clarification first
- **Refactors**: max 5 files per response, never all at once
- **Commits**: after every change, no co-author, never stage `.claude/` or personal files
- **Self-correction**: after any mistake, log it to `gotchas.md` and convert it to a rule
- **MCP-first**: if an MCP tool exists for a task, use it — don't guess or rely on training data
- **Demand-driven loading**: `axon analyze` only runs before structural work (refactors, blast-radius, architecture). MemPalace is only queried when the current project matches a known palace wing. Neither runs on simple Q&A sessions.

---

## MemPalace — Persistent Memory

The three MemPalace hooks wire autonomous session memory into Claude Code. Every conversation is mined into a local ChromaDB palace and surfaced at the start of the next session.

**What gets saved**: technical decisions, architectural choices, debugging sessions, code patterns — organized by project wing.

**How it works**:
1. `mempal_save_hook.sh` fires on Stop, checkpoints every 15 human messages
2. `mempal_precompact_hook.sh` fires on PreCompact (emergency save before context compression)
3. `mempal_maintenance.sh` runs weekly via cron — cleans ChromaDB WAL, vacuums SQLite, alerts if `~/.claude/file-history/` exceeds 500MB (known catastrophic growth bug)

**Setup** (optional — hooks work without it, but recall requires the palace):

```bash
pip install mempalace chromadb-ops hnswlib
mempalace init ~/projects/
claude mcp add mempalace -- python3 -m mempalace.mcp_server

# Wire cron for weekly maintenance (Sunday 2am)
(crontab -l 2>/dev/null; echo "0 2 * * 0 /bin/bash ~/.claude/hooks/mempal_maintenance.sh >> ~/.claude/mempal_maintenance.log 2>&1") | crontab -
```

**Note on the Stop hook "error" display**: Claude Code may show `mempal_save_hook.sh` as an error in the status bar. This is intentional — the hook outputs `{"decision": "block", "reason": "AUTO-SAVE checkpoint..."}` to force Claude to save memory before completing. It is working correctly.

---

## Install

```bash
git clone https://github.com/wildcraft958/claude-armory
cd claude-armory
bash install.sh
```

The installer:
1. Copies `CLAUDE.md` and `gotchas.md` to `~/.claude/` (backs up existing files)
2. Copies hooks to `~/.claude/hooks/` and makes them executable
3. Copies slash commands to `~/.claude/commands/`
4. Copies agent docs to `~/.claude/agent_docs/`
5. Copies caveman skills to `~/.claude/skills/`
6. Generates `~/.claude/settings.json` with correct absolute paths

Restart Claude Code after installing.

---

## Adapting to Your Setup

**CLAUDE.md** — Edit the `Author` section and the `Session Start` steps to match your MCP servers and tools. The workflow, code style, and git rules are generic and work for any project.

**agent_docs/** — These are tuned for a Python + FastAPI + LangGraph + Supabase + React stack. Strip the docs you don't need. Add your own.

**hooks/** — The hooks auto-detect your stack (Node, Python, Rust) and run the right linter/type-checker. They work out of the box for most projects.

---

## MCP Servers Referenced

The `CLAUDE.md` references these MCP servers. Install what fits your stack:

| Server | Use for |
|--------|---------|
| `github` | PRs, issues, file ops on GitHub |
| `supabase` | DB queries, migrations, RLS, edge functions |
| `playwright` | Browser automation, screenshots, testing |
| `axon` | Codebase analysis, blast radius, refactor impact |
| `repomix` | Pack and analyze large codebases |
| `ddgs` | Web search and page fetch |
| `docs-langchain` | LangChain / LangGraph live docs |

---

## Stack Coverage

The hooks and agent docs are tuned for:
- **Python** — FastAPI, LangGraph, pytest, ruff, mypy
- **TypeScript / JavaScript** — React, Next.js, vitest, eslint, tsc
- **Rust** — cargo check, cargo test

---

## License

MIT
