---
name: ship
description: Pre-commit gate. Sequences the built-in verification and review skills, then reports one verdict. Use before committing or opening a PR on work that is believed finished.
argument-hint: [optional scope or path]
disable-model-invocation: true
---

Run the pre-commit gate. Do not skip a step. Do not commit anything as part of this skill.

Each step below delegates to a built-in skill rather than reimplementing it. The built-ins know
this project's build and test commands, record what worked, and run adversarial verification. A
hand-written pipeline here would be a worse copy that drifts.

## 1. Verify it actually runs

Invoke `/verify`. It builds the project, runs it, and watches type-checker, linter, and test
signals, looping on failure. On first run it records the working recipe to
`.claude/skills/verify/SKILL.md` so later runs and other agents reuse it.

If `/verify` cannot determine how to build or run this project, say so plainly rather than
substituting a guess, and fall back to whatever the project's own README documents.

## 2. Review the diff for correctness

Invoke `/code-review high`. Report only findings it confirms after verification. Do not pad the
list with style opinions it did not raise.

## 3. Review the diff for security

Invoke `/security-review`. Treat anything it flags as a blocker until explicitly waived.

## 4. Report one verdict

```
SHIP CHECK
==========
Verify:     PASS / FAIL / UNKNOWN (reason)
Review:     N confirmed findings
Security:   N findings
Uncommitted: N files

Verdict:    READY / BLOCKED (list blockers)
```

Rules for the verdict:

- `UNKNOWN` is not `PASS`. If a step could not run, the verdict is BLOCKED until it does or the
  gap is explicitly accepted.
- List every blocker with its file and line. Offer to fix them; do not fix them unprompted.
- Never report READY on output you did not actually see. If a command produced no output, say that
  rather than inferring success.

$ARGUMENTS
