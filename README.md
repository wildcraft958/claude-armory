# claude-armory

Your full loadout for serious dev work.

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
| `skills/caveman/` | Cuts output tokens ~75% — Claude talks like caveman, brain still big |
| `skills/caveman-compress/` | Compresses your CLAUDE.md / memory files to cut input tokens ~45% |
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

---

## Hooks

These run automatically on every tool call. Claude cannot skip them.

| Event | Hook | What it does |
|-------|------|-------------|
| `PreToolUse (Bash)` | `block-destructive.sh` | Blocks `rm -rf /`, DB drops, force pushes, `.env` reads |
| `PostToolUse (Write/Edit)` | `post-edit-verify.sh` | Runs eslint or ruff on every edited file — blocks if lint fails |
| `PostToolUse (Grep/Bash)` | `truncation-check.sh` | Warns when output was truncated (>50K chars) |
| `Stop` | `stop-verify.sh` | Blocks "Done" unless the project compiles, lints, and tests pass |

**Why hooks matter**

Without hooks, Claude can declare "Done!" after writing code that doesn't compile. With `stop-verify.sh`, the agent is blocked from completing until `tsc`, `ruff`, `mypy`, `pytest`, or `cargo check` all pass — depending on your stack. It's a CI gate that runs before Claude is allowed to declare victory.

---

## Agent Docs

Claude reads these before starting work on a topic. They save you from re-explaining your conventions on every session.

| File | Read when... |
|------|-------------|
| `debug_guide.md` | Debugging Python, FastAPI, LangGraph, React, Supabase |
| `architecture.md` | Building features, understanding project structure |
| `ml_patterns.md` | LangGraph agents, RAG pipelines, embeddings |
| `api_conventions.md` | FastAPI routes, auth patterns, error formats |
| `database.md` | Supabase queries, RLS policies, migrations, pgvector |
| `context_and_safety.md` | Context management, edit safety, hook behavior |
| `axon_guide.md` | Axon MCP tools for refactors and blast-radius analysis |

---

## Key Behaviors (from CLAUDE.md)

- **TDD**: tests first, then implement
- **Planning**: plan only when asked, no code until told to proceed — non-trivial features need clarification first
- **Refactors**: max 5 files per response, never all at once
- **Commits**: after every change, no co-author, never stage `.claude/` or personal files
- **Self-correction**: after any mistake, log it to `gotchas.md` and convert it to a rule
- **MCP-first**: if an MCP tool exists for a task, use it — don't guess or rely on training data

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
