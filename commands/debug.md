Debug the issue described below using this 5-step protocol. Do not skip steps.

## Step 1: Gather
- Read the error message, stack trace, or user description carefully.
- Identify the file(s), line number(s), and function(s) involved.
- Check git blame/log for recent changes to those files.
- List what you know and what you don't know yet.

## Step 2: Read
- Read the full function/module where the error occurs (use offset/limit for large files).
- Read the test file for that module if one exists.
- Trace the call chain: who calls this function? What calls does it make?
- Check related config files, env vars, or dependency versions if relevant.

## Step 3: Diagnose
- State the root cause in one sentence.
- Explain WHY it fails, not just WHERE.
- If unsure, list the top 2-3 hypotheses ranked by likelihood.
- For each hypothesis, describe what evidence would confirm or rule it out.
- Run the minimal test/command that reproduces the bug.

## Step 4: Fix
- Write the smallest change that fixes the root cause.
- Do not refactor surrounding code. Do not add unrelated improvements.
- If the fix touches a public API or shared interface, check all callers.
- Run the failing test/command to confirm the fix works.
- Run the full test suite to check for regressions.

## Step 5: Prevent
- If this bug class could recur, add a test that catches it.
- If the root cause was a missing validation, add the validation.
- Log the pattern to gotchas.md if it represents a non-obvious lesson.
- State what you changed and why in 2-3 sentences.

$ARGUMENTS
