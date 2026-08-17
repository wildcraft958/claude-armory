#!/bin/bash
# verify-changed.sh
# Stop hook. Lints only the files this session actually changed, then gets out of the way.
#
# Scope is deliberately narrow. Type checking is left to the LSP plugins, which already report
# diagnostics inline as files are edited. Tests and builds are left to /verify and /ship, which
# are invoked on purpose. The one job here is that Claude cannot claim a task is finished while
# a file it just touched fails its linter.
#
# Contract: exit 2 with {"decision":"block","reason":...} blocks the stop and hands the errors
# back to Claude. exit 0 lets it finish.

INPUT=$(cat)

# Claude Code sets stop_hook_active=true on the retry after this hook blocked once. Without this
# guard the block-fix-block cycle never terminates.
if [ "$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false')" = "true" ]; then
  exit 0
fi

# Lite mode escape hatch for low-resource machines: touch ~/.claude/.lite
[ -f "$HOME/.claude/.lite" ] && exit 0

command -v jq >/dev/null 2>&1 || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Only files this working tree has actually modified. Tracked changes plus new untracked files.
CHANGED=$(
  {
    git diff --name-only --diff-filter=ACMR HEAD 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | sort -u
)

[ -z "$CHANGED" ] && exit 0

# Keep only files that still exist and that a linter here can actually check.
PY_FILES=$(printf '%s\n' "$CHANGED" | grep -E '\.py$' | while read -r f; do [ -f "$f" ] && printf '%s\n' "$f"; done)
JS_FILES=$(printf '%s\n' "$CHANGED" | grep -E '\.(ts|tsx|js|jsx|mjs|cjs)$' | while read -r f; do [ -f "$f" ] && printf '%s\n' "$f"; done)

ERRORS=""
CHECKS_RUN=0

if [ -n "$PY_FILES" ] && command -v ruff >/dev/null 2>&1; then
  CHECKS_RUN=$((CHECKS_RUN + 1))
  RUFF_OUTPUT=$(printf '%s\n' "$PY_FILES" | xargs -r ruff check 2>&1)
  if [ $? -ne 0 ]; then
    ERRORS="${ERRORS}ruff:
$(printf '%s' "$RUFF_OUTPUT" | head -40)

"
  fi
fi

if [ -n "$JS_FILES" ]; then
  # Only run eslint if this project actually configures it, otherwise npx would try to install it.
  if ls .eslintrc .eslintrc.js .eslintrc.json .eslintrc.yml .eslintrc.cjs \
        eslint.config.js eslint.config.mjs eslint.config.cjs eslint.config.ts >/dev/null 2>&1; then
    CHECKS_RUN=$((CHECKS_RUN + 1))
    ESLINT_OUTPUT=$(printf '%s\n' "$JS_FILES" | xargs -r npx --no-install eslint --quiet 2>&1)
    if [ $? -ne 0 ]; then
      ERRORS="${ERRORS}eslint:
$(printf '%s' "$ESLINT_OUTPUT" | head -40)

"
    fi
  fi
fi

if [ -n "$ERRORS" ]; then
  jq -n --arg reason "Lint failed on files changed this session. Fix before finishing:

${ERRORS}" '{decision: "block", reason: $reason}'
  exit 2
fi

# Nothing was checkable. Say so rather than letting silence read as a passing build.
if [ "$CHECKS_RUN" -eq 0 ]; then
  jq -n '{additionalContext: "No linter ran on the changed files (none installed, or no supported file types). Completion is unverified - say so instead of implying the change is validated. Run /verify for a real build-and-run check."}'
fi

exit 0
