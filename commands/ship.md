Run the full pre-commit quality pipeline on this project. Report pass/fail for each check. Do not skip any step.

## Pipeline

### 1. Lint
- Python: `ruff check .`
- JS/TS: `npx eslint .` (if eslint config exists)
- Report: file, line, rule, message for each error

### 2. Type Check
- Python: `mypy .` (if mypy config exists in pyproject.toml or mypy.ini)
- TS: `npx tsc --noEmit` (if tsconfig.json exists)
- Report: file, line, error for each failure

### 3. Tests
- Python: `pytest --tb=short -q`
- JS/TS: `npm test` or `npx vitest run` (whichever is configured)
- Report: passed, failed, skipped counts. Show full output for failures.

### 4. Build (if applicable)
- JS/TS: `npm run build` or `pnpm build` (if build script exists)
- Python: skip unless there's a build step in pyproject.toml
- Report: success or error output

## Output

```
SHIP CHECK RESULTS
==================
Lint:       PASS/FAIL (N errors)
Types:      PASS/FAIL/SKIP (N errors)
Tests:      PASS/FAIL (N passed, N failed, N skipped)
Build:      PASS/FAIL/SKIP

Verdict:    READY TO SHIP / BLOCKED (list blockers)
```

If any check fails, list the specific errors and offer to fix them.

$ARGUMENTS
