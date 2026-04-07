Scaffold a project-level Claude Code setup for the current directory. Follow these steps exactly.

## Step 1: Detect Stack

Run these checks and note what's present:
- `package.json` -> Node.js (check for react, next, vitest/jest, typescript)
- `pyproject.toml` or `setup.py` -> Python (check for fastapi, django, flask, pytest, langchain, langgraph)
- `Cargo.toml` -> Rust
- `go.mod` -> Go
- `supabase/` directory or supabase references -> Supabase
- `tsconfig.json` -> TypeScript
- `.eslintrc*` or `eslint.config.*` -> ESLint
- `docker-compose.yml` or `Dockerfile` -> Docker
- Existing `CLAUDE.md` -> read it, don't overwrite

## Step 2: Generate Project CLAUDE.md

Create a `CLAUDE.md` at the project root (or update the existing one). Keep it under 50 lines. Include:

```markdown
# [Project Name]

## Stack
[List detected technologies, e.g. "Python 3.12 + FastAPI + Supabase + LangGraph"]

## Quick Commands
[Fill in based on what exists]
- Dev: `[npm run dev / uvicorn app.main:app --reload / etc.]`
- Test: `[pytest / npm test / cargo test]`
- Lint: `[ruff check . / npx eslint . / etc.]`
- Type check: `[mypy . / npx tsc --noEmit / etc.]`
- Build: `[npm run build / etc.]`

## Architecture
[2-3 sentences on how the project is organized. Read the top-level directories to figure this out.]

## Key Decisions
[Leave empty for the user to fill in. Add a comment: "Document non-obvious architectural choices here."]
```

## Step 3: Copy Relevant Agent Docs

Create a project-level `agent_docs/` directory and copy only the relevant docs from `~/.claude/agent_docs/`:
- Python project -> `debug_guide.md`, `api_conventions.md`, `architecture.md`
- Python + LangGraph -> also `ml_patterns.md`
- Supabase -> also `database.md`
- Any project -> `context_and_safety.md`
- Skip `axon_guide.md` (always available globally)

Customize copied docs to match the actual project structure and conventions you observe.

## Step 4: Create Project gotchas.md

Create a `gotchas.md` at project root with the same template as the global one but scoped to this project.

## Step 5: Report

Print a summary of what was created and any manual steps needed (e.g. "Fill in the Key Decisions section").

$ARGUMENTS
