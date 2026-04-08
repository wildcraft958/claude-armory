# Context Management & Edit Safety

> **Stack:** Any. These rules apply to all projects regardless of language or framework.

Detailed rules for safe file editing and context management. These are enforced by hooks but understanding them helps avoid blocked operations.

## Context Management

- Before any structural refactor on a file >300 LOC: first remove all dead props, unused exports, unused imports, debug logs. Commit cleanup separately.
- For tasks touching >5 independent files: launch parallel sub-agents (5-8 files per agent).
- After 10+ messages in a conversation: re-read any file before editing it. File contents may have drifted.
- Each file read is capped at 2,000 lines. For files over 500 LOC: use offset and limit to read in chunks.
- Tool results over 50K chars get truncated to a 2KB preview. If results look suspiciously small: read the full file or re-run with narrower scope.

## Edit Safety

- Before every file edit: re-read the file. After editing: read it again to verify.
- On any rename or signature change, search separately for:
  - Direct calls (`functionName(`)
  - Type references (`type X = ReturnType<typeof functionName>`)
  - String literals (`"functionName"` in configs, tests, dynamic imports)
  - Dynamic imports (`import("./module")`)
  - `require()` calls
  - Re-exports and barrel files (`export { functionName } from`)
  - Test mocks (`vi.mock`, `jest.mock`, `@patch`)
- Never delete a file without verifying nothing references it.

## When Hooks Block You

Hooks run automatically on tool calls. You cannot skip them.

### post-edit-verify (runs after Write/Edit)
- Runs eslint (JS/TS) or ruff (Python) on the specific file you just edited.
- If it blocks: fix the lint errors shown in the output, then continue.
- Does NOT run type checking (that happens at Stop to avoid delays).

### stop-verify (runs when you try to finish)
- Runs full project verification: tsc, eslint, mypy, ruff, pytest, cargo check.
- If it blocks: fix ALL type errors, lint errors, and test failures before trying to complete again.
- If `stop_hook_active` is true, the hook lets you through (prevents infinite loops).

### block-destructive (runs before Bash commands)
- Blocks: `rm -rf /`, `rm -rf ~`, force pushes, hard resets, DROP TABLE, .env file reads.
- If it blocks: do NOT retry the same command. Tell the user to run it manually if it's intentional.

### truncation-check (runs after Grep/Bash)
- Warns when tool output was truncated (>50K chars to 2KB preview).
- If it warns: narrow your search scope or read the full output file it points to.
- Also warns when grep returns suspiciously few results for a broad pattern.
