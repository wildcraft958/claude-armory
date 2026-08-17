# claude-armory

```
   \   |   /         claude-armory  v2.0.0
    \  |  /          a small loadout that gets out of the way
     \ | /           ──────────────────────────────────────────────────
  ----\|/----        Skills     12   /debug-protocol /test /ship /explain
  ----/|\----                        /retire /tdd /langgraph-agent
     / | \                           /caveman /caveman-compress
    /  |  \                          + api-conventions, project-architecture,
   /   |   \                           axon  (model-loaded, not typed)
       |
   C L A U D E       Hooks       1   verify-changed   Stop   ~40ms
   A R M O R Y
                     Permissions     27 deny globs, 4 ask, 5 intent rules
                     Memory          native auto memory
                     Context cost    ~1,042 tok always-on
                     Stack           Python · TypeScript
                     Effort          alwaysThinking=true  effortLevel=xhigh
```

A personal Claude Code setup, rebuilt in August 2026 around one rule: **if Anthropic ships an
official implementation, use theirs and delete ours.**

Version 1 of this repo hand-rolled a memory system, a verification hook, a destructive-command
blocker, a docs-loading ritual, and eleven slash commands. Claude Code now does most of that
natively and does it better. Version 2 is what is left after removing everything that had an
official equivalent: six hooks became one, three memory systems became one, and the whole thing
costs about a thousand tokens per session instead of a session-start ritual that read seven
markdown files.

## Install

Skills and the hook come from the plugin:

```
/plugin marketplace add wildcraft958/claude-armory
/plugin install armory@claude-armory
```

Three files cannot live in a plugin, because Claude Code loads them from fixed paths in
`~/.claude/`. Those are in `personal/`:

```bash
git clone https://github.com/wildcraft958/claude-armory
bash claude-armory/personal/install.sh
```

It backs up anything it replaces and refuses to overwrite `settings.json`, printing the keys you
are missing instead. That file is machine-specific: your model, theme, and enabled plugins have
nothing to do with this repo.

| File | Goes to | Why not in the plugin |
|---|---|---|
| `personal/CLAUDE.md` | `~/.claude/CLAUDE.md` | User instructions load from a fixed path |
| `personal/lessons.md` | `~/.claude/rules/lessons.md` | Plugins do not load a `rules/` directory |
| `personal/settings.json` | merge by hand | Contains machine-specific keys |

Optional MCP servers:

```bash
claude mcp add --scope user repomix -- npx -y repomix --mcp
claude mcp add --scope user axon -- axon mcp      # needs the axon binary installed
```

Update later with the **qualified** name:

```bash
claude plugin update armory@claude-armory
```

The bare `armory` resolves for `plugin list` and `plugin details` but not for `plugin update`,
which reports "Plugin not found". To pick up a new commit, refresh the marketplace cache first:

```bash
claude plugin marketplace update claude-armory
claude plugin update armory@claude-armory
```

**Prerequisites:** `jq` and `git` for the hook, `ruff` for Python linting, `gh` for GitHub work.
Everything degrades gracefully: a missing linter makes the hook say "unverified" rather than fail.

**Not your setup?** `personal/CLAUDE.md` carries my name, email, and canary word. Change the
Author and Context Canary sections, or skip that file and keep your own.

## What is in here

### Skills (12)

Nine are typed as `/name`. Three are model-loaded only, so they never clutter the `/` menu.

| Skill | Invoked by | What it is |
|---|---|---|
| `/debug-protocol` | you or Claude | Five-step debugging protocol. Bundles a `reference.md` of Python, FastAPI, LangGraph, React, and Supabase failure modes that loads only when the bug is in that stack |
| `/test` | you or Claude | Write tests in strict Arrange-Act-Assert, one behavior each, no mocking internals |
| `/tdd` | you or Claude | Build a feature test-first in Red-Green-Refactor vertical slices |
| `/explain` | you or Claude | Explain code at four depths, from TL;DR to what could break |
| `/langgraph-agent` | you or Claude | Scaffold a LangGraph ReAct agent. Reference covers RAG, embeddings, streaming |
| `/ship` | you only | Pre-commit gate. Sequences `/verify`, `/code-review high`, `/security-review` and reports one verdict |
| `/retire` | you only | Decommission a project in dependency order: secrets, data, code, infra |
| `/caveman` | you only | Compressed responses at lite, full, or ultra intensity |
| `/caveman-compress` | you only | Rewrite a markdown file into caveman-speak, keeping code and URLs exact |
| `api-conventions` | Claude only | FastAPI routes, DI, auth, error formats |
| `project-architecture` | Claude only | FastAPI and React project layout, where new code belongs |
| `axon` | Claude only | Driving the Axon MCP tools for refactors and blast-radius analysis |

Skill descriptions cost context; bodies do not load until used. `/retire` is 4.3k tokens and
`/tdd` is 3.5k, and you pay neither until you invoke them. Run `claude plugin details armory`
for the current per-skill numbers.

### One hook

`verify-changed.sh` on `Stop`. Lints only the files the session actually changed, using
`git diff HEAD` plus untracked files, and blocks the turn if one fails. Measured at 30-70ms
across seven cases. If no linter applies it says completion is unverified rather than staying
silent, because silence reads as a passing build.

It does not type-check (the LSP plugins already do, inline), does not run tests, and does not
build. Those are `/verify` and `/ship`, invoked on purpose.

Set `CLAUDE_ARMORY_SKIP_VERIFY=1` to disable it for a session.

### Permissions instead of a blocker script

`personal/settings.json` carries 27 `permissions.deny` globs, 4 `ask` rules, and 5
`autoMode.hard_deny` intent rules. See "Why permissions beat a hook" below.

## What was removed, and why

Everything here was deleted because something official replaced it. Nothing was dropped for
being merely unfashionable.

| Removed | Replaced by |
|---|---|
| **MemPalace**: MCP server, 4 scripts, weekly cron, 2 hooks, `/skip-precompact` | **Native auto memory** (`~/.claude/projects/<project>/memory/`). On by default, per-repo, exempt from the retention sweep |
| `gotchas.md` | `~/.claude/rules/lessons.md`. User-level rules load in *every* project; auto memory is per-repo and would have stopped loading outside one directory |
| `mempal_maintenance.sh` weekly cron | `cleanupPeriodDays` already sweeps `file-history/`, `paste-cache/`, `image-cache/`, `shell-snapshots/`, `debug/`, `tasks/` |
| `block-destructive.sh` (bash + jq per Bash call) | `permissions.deny` + `autoMode.hard_deny` |
| `post-edit-verify.sh` | `pyright-lsp`, `typescript-lsp`, `clangd-lsp` plugins report diagnostics inline |
| `truncation-check.sh` | Native persisted-output already prints the saved path. Its Grep low-result heuristic fired on almost every narrow grep and injected noise |
| `stop-verify.sh` (whole-project checks every turn) | `/verify`, which builds, runs, watches signals, loops on failure, and records the recipe. Plus the thin hook above, because `/verify` is invoke-only |
| `mempal_precompact_hook.sh` | Nothing. The hook was the problem |
| `/review` | `/code-review` (multi-agent, adversarial verification, `--fix`, `--comment`) |
| `/audit` | `/code-review high` + `/security-review` |
| `/init` | Built-in `/init`, **which ours was shadowing.** A user skill overrides a bundled one of the same name, so a static checklist had been winning over a multi-phase flow that explores with a subagent and reads Cursor and Copilot rules |
| `/debug` name | Renamed to `/debug-protocol`; the old name collided with the bundled `/debug` |
| `/agent` name | Renamed to `/langgraph-agent`; read as a typo for built-in `/agents` |
| `agent_docs/database.md` | Bundled `supabase:supabase-postgres-best-practices` skill |
| `agent_docs/context_and_safety.md` | Described the hooks that are now gone |
| CLAUDE.md's 7-step Session Start ritual | CLAUDE.md and auto memory both load automatically. The ritual asked the model to remember to do what the harness already does |
| CLAUDE.md "never add Claude as co-author" | `includeCoAuthoredBy: false`. A setting the harness enforces beats a rule the model must recall |
| `context7` MCP | `context7@claude-plugins-official`. The old entry pointed at `@context7/mcp`, which 404s on npm; the real package is `@upstash/context7-mcp`. It had never once connected |
| `playwright` MCP | `playwright@claude-plugins-official` |
| `github` MCP | `gh` CLI. `@modelcontextprotocol/server-github` is npm-deprecated and the plugin variant fails auth |
| `ddgs` MCP | Native `WebSearch` and `WebFetch`, plus `/deep-research` |
| `install.sh` | Plugin and marketplace. No file copying, no `CLAUDE_DIR` placeholder substitution |
| `skills/TDD.md` | Now `skills/tdd/SKILL.md`. A bare file at the skills root never loads, so this one had been dead since it was written |

## Why permissions beat a hook

`block-destructive.sh` matched regexes against raw Bash command text. During this rewrite it
denied two attempts to **write a JSON file** because the file's string contents contained
`rm -rf /*`. No command was executed either time. Regex over raw text cannot distinguish a
command from a quoted payload; a deny rule matched against parsed tool input can.

The honest trade: `permissions.deny` is glob matching, not regex, so it is a slightly coarser net
for exotic `rm -rf` spellings. In exchange the SQL rules moved to `autoMode.hard_deny`, where a
classifier reads intent instead of pattern-matching `DELETE FROM`, which is broader coverage than
the regex had. Net result is cheaper and mostly stronger, marginally weaker on one axis.

## What Claude Code now does natively

Worth knowing before writing anything custom:

| Instead of building | Use |
|---|---|
| A memory MCP server | Auto memory, on by default |
| A verification hook that guesses your build | `/verify` |
| A review command | `/code-review`, `/security-review`, `/simplify` |
| A "run the app" script | `/run` |
| A research pipeline | `/deep-research` |
| A codebase-wide refactor loop | `/batch` |
| A polling wrapper | `/loop`, `/schedule` |
| Undo scaffolding | `/rewind`, checkpoints |
| Context accounting | `/context`, `/usage` |
| A type-check hook | The LSP plugins |
| An onboarding doc index | Skills, which load on demand |

Marketplace plugins worth a look: `remember` (tiered conversation memory, an alternative to auto
memory), `session-report` and the built-in `/insights` (usage and cache analysis),
`commit-commands`, `chrome-devtools-mcp`.

## On caveman

Kept by request, and cheap to keep: `disable-model-invocation: true` means it costs nothing until
typed. But the advertised number does not hold for coding work.

JetBrains measured **8.5%** output-token saving on real agentic tasks with the skill force-enabled,
which is the ceiling rather than the typical case. The widely-quoted 65% comes from chat-style prose.
Agentic output is dominated by code, diffs, tool calls, and exact error strings, and caveman
correctly leaves all of that verbatim, so only the narration between tool calls compresses and
there is not much of it. Treat it as a style preference, not a cost lever.

Maintained upstream, if you want a version someone else keeps current:
[JuliusBrussee/caveman](https://github.com/juliusbrussee/caveman).

## Known rough edges

- **`npx -y ccstatusline@latest`** in `statusLine` re-resolves `latest` from the registry on
  render. Pin a version or `npm i -g ccstatusline` and call the binary directly.
- **Plugins do not load a `rules/` directory.** It gets copied into the plugin cache and then
  ignored, which is the same trap as a bare `SKILL.md` at the skills root. Path-scoped rules only
  work from `~/.claude/rules/` or `.claude/rules/`, so `api-conventions` ships as a skill instead.
  To get automatic path-scoped loading, symlink it yourself:
  `ln -s ~/.claude/plugins/cache/claude-armory/armory/*/skills/api-conventions/SKILL.md ~/.claude/rules/api-conventions.md`
- **Auto memory is machine-local** and does not sync. Anything that must exist on both machines
  belongs in `CLAUDE.md` in this repo, not in auto memory.
- **`plugin update` needs the qualified name**, `armory@claude-armory`. The bare `armory` works for
  `plugin list` and `plugin details` but reports "Plugin not found" on update.
- A local-path marketplace re-reads from disk rather than supporting update, which is fine for
  development but means the source must be repointed at GitHub before the checkout is deleted.

## Layout

```
claude-armory/
├── .claude-plugin/
│   ├── marketplace.json      # marketplace listing, source "./"
│   └── plugin.json           # plugin manifest
├── skills/<name>/SKILL.md    # 12 skills, 2 with a reference.md alongside
├── hooks/hooks.json          # one Stop hook
├── scripts/verify-changed.sh
├── personal/                 # the parts a plugin cannot install
│   ├── CLAUDE.md
│   ├── lessons.md
│   ├── settings.json
│   └── install.sh
└── README.md
```

MIT. Animesh Raj <animeshraj958@gmail.com>
