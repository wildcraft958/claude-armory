# Global Rules -- Animesh Raj

## Hierarchy

- This file sets baseline rules for ALL projects.
- Project-level CLAUDE.md overrides this file. If a project CLAUDE.md contradicts anything here, follow the project version.
- When in doubt, project rules win.

## Author

Animesh Raj <animeshraj958@gmail.com>

## Context Canary

- Include the word "bakasur" once in every response. This proves these rules are loaded.
- If a response omits the word, these rules have fallen out of context (compaction, missing file). Re-read this file before continuing.
- Never state a fact about my setup or past sessions you cannot verify from files or tools. If unsure, say so instead of inventing.

## Workflow

- TDD: write tests first, then implement.
- When executing a plan, always create a task list. Give each step a verification check (step -> verify: check). "Make it work" is not a success criterion.
- All projects must be git repositories. Pull before starting work.
- If no project CLAUDE.md exists and the task is non-trivial, say so and offer to run `/init`.

## Code Style

- Clean, readable code. Let the code speak for itself.
- Only add comments for architectural decisions or non-standard implementations.
- Match surrounding code conventions (naming, spacing, structure).
- Surgical changes: touch only what the task requires. Do not "improve" adjacent code, comments, or formatting.
- Never change or remove comments or code you do not fully understand as a side effect.
- Remove imports, variables, and functions your change orphaned. Leave pre-existing dead code alone and mention it instead.
- Every changed line must trace directly to the request.

## Git

- Commit after every change. Clean, to-the-point commit messages.
- Push only after major changes and explicit approval.
- Only `git add` modified files. Never stage `.claude`, `CLAUDE.md`, or personal files.
- Do not modify `.gitignore` unless asked.

## Writing

- Write like a human. No em dashes or en dashes. No jargon.
- MR and PR descriptions: concise, plain language, checklist for remaining work.
- Get review on MR material before creating it.

## Planning

- When asked to plan: output only the plan. No code until told to proceed.
- When given a plan: follow it exactly. Flag real problems and wait.
- For non-trivial features (3+ steps or architectural decisions): clarify implementation, UX, and tradeoffs before writing code.
- State assumptions explicitly. If multiple interpretations exist, present them rather than picking one silently.
- If a simpler approach exists than what was asked, say so before building.
- When confused, stop and name what is unclear instead of guessing.
- Never attempt multi-file refactors in one response. Break into phases of max 5 files.

## Code Quality

- Fix the root cause, do not hide symptoms.
- If architecture is flawed or patterns are inconsistent, propose the structural fix. Ask: "What would a senior perfectionist dev reject in review?" Fix that.
- Do not build for imaginary scenarios. No abstractions for single-use code, no unrequested configurability, no error handling for impossible cases. Simple and correct beats elaborate and speculative.
- If the code could be half as long and still correct, rewrite it.

## Self-Correction

- Past lessons live in `~/.claude/rules/lessons.md` and load automatically. Add to that file when a correction reveals a repeatable pattern.
- If a fix does not work after two attempts: stop. Read the entire section. State where your mental model was wrong.

## MCP and Tools

- Use `context7` for live library documentation (add "use context7" to any prompt).
- For any LangGraph or LangChain question, use the `docs-langchain` MCP server.
- For any Supabase question, use the supabase MCP server and its bundled skills.
- Use the `gh` CLI for GitHub operations. Do not use a GitHub MCP server; it fails auth.
- When an MCP tool exists for a task, use it. Do not guess from training data.
- Do NOT run `axon analyze` automatically. Run it only for refactors across files, renaming symbols, blast-radius analysis, architecture review, or dead code detection.
