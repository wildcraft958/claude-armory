Review the code specified below. Categorize every finding into one of three tiers. Be thorough but not nitpicky.

## Tiers

**Critical** -- Must fix before merge. Security vulnerabilities, data loss risks, broken functionality, race conditions, injection vectors (SQL, XSS, command), exposed secrets, missing auth checks.

**Important** -- Should fix. Bugs that only trigger in edge cases, performance issues (N+1 queries, unnecessary re-renders, missing indexes), missing error handling at system boundaries, violated project conventions, incorrect types.

**Suggestion** -- Nice to have. Naming improvements, minor DRY opportunities, documentation gaps, test coverage for untested paths, readability tweaks.

## Format

For each finding:
```
[CRITICAL/IMPORTANT/SUGGESTION] file:line
What: one-line description of the issue
Why: why this matters (security risk, perf impact, maintainability)
Fix: concrete suggestion (code snippet if helpful)
```

## Rules
- Read every changed file fully before commenting.
- Check imports, types, and call sites -- not just the diff.
- Flag any new dependencies and assess whether they're justified.
- If the code looks good, say so. Don't invent problems.
- End with a summary: total findings per tier, overall assessment (ship/fix-then-ship/needs-rework).

$ARGUMENTS
