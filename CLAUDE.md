# Global Rules

## Hierarchy

- This file sets baseline rules for ALL projects.
- Project-level CLAUDE.md overrides this file. If a project CLAUDE.md contradicts anything here, follow the project version.
- When in doubt, project rules win.

## Session Start

1. Read the project CLAUDE.md if it exists. Its rules override this file.
2. Read gotchas.md if it exists. Apply past lessons.
3. If the project is a git repo, run `axon analyze --no-embeddings` in background.
4. Check which MCP servers are connected. Note what's available.
5. Pull latest changes before starting work.
6. If the task matches an agent doc topic, read the relevant file from `~/.claude/agent_docs/`.

## Author

Your Name <your@email.com>

## Workflow

- TDD: write tests first, then implement.
- When executing a plan, always create a task list to track progress.
- All projects must be git repositories.
- Use slash commands: `/debug`, `/review`, `/ship`, `/test`, `/explain`, `/agent`.

## Code Style

- Clean, readable code. Let the code speak for itself.
- Only add comments for architectural decisions or non-standard implementations.
- Match surrounding code conventions (naming, spacing, structure).

## Git

- Commit after every change. Clean, to-the-point commit messages.
- Pull before starting any work. Push only after major changes and explicit approval.
- Never add Claude as co-author. Only use git add for modified files.
- Never stage or commit .claude, CLAUDE.md, or personal files.
- Do not modify .gitignore unless asked.

## Writing

- Write like a human. No em dashes or en dashes. No jargon.
- MR/PR descriptions: concise, plain language, checklist for remaining work.
- Get review on MR material before creating it.

## MCP

- Before planning any task, check which MCP servers are connected. Use them first.
- Use `context7` for live, up-to-date library documentation (add "use context7" to any prompt).
- For ANY question about LangGraph, use the langgraph-docs-mcp server.
- For ANY question about Supabase, use the supabase MCP server.
- For Axon usage details, see `~/.claude/agent_docs/axon_guide.md`.
- When an MCP tool exists for a task, use it. Don't guess or rely on training data.

## Planning

- When asked to plan: output only the plan. No code until told to proceed.
- When given a plan: follow it exactly. Flag real problems and wait.
- For non-trivial features (3+ steps or architectural decisions): clarify implementation, UX, and tradeoffs before writing code.
- Never attempt multi-file refactors in one response. Break into phases of max 5 files.

## Code Quality

- If architecture is flawed or patterns are inconsistent: propose the structural fix. Ask: "What would a senior perfectionist dev reject in review?" Fix that.
- Don't build for imaginary scenarios. Simple and correct beats elaborate and speculative.

## Self-Correction

- After any correction: log the pattern to gotchas.md. Convert mistakes into rules.
- Review gotchas.md at session start.
- If a fix doesn't work after two attempts: stop. Read the entire section. State where your mental model was wrong.

## Deep-Dive Docs (~/.claude/agent_docs/)

Read the relevant doc BEFORE starting work on that topic:
- `debug_guide.md` -- debugging errors (Python, FastAPI, LangGraph, React, Supabase)
- `architecture.md` -- building features, project structure
- `ml_patterns.md` -- LangGraph agents, RAG, embeddings, model loading
- `api_conventions.md` -- FastAPI routes, auth, error formats
- `database.md` -- Supabase queries, RLS, migrations, pgvector
- `context_and_safety.md` -- context management, edit safety, hook behavior
- `axon_guide.md` -- Axon MCP tools for refactors, renames, blast-radius analysis
