#!/bin/bash
# verify-changed.sh
# Stop hook. Lints only the files this session actually changed, then gets out of the way.
#
# Scope is deliberately narrow. Type checking is left to the LSP plugins, which already report
# diagnostics inline as files are edited. Tests and builds are left to /verify and /ship, which
# are invoked on purpose. The one job here is that Claude cannot claim a task is finished while
# a file it just touched fails its linter.
#
# There is deliberately no ~/.claude/.lite bypass. Lite mode exists to skip the 10-30s
# whole-project checks the predecessor of this script ran; a changed-files lint costs ~200ms and
# short-circuiting it would leave the hook with no job at all. Set CLAUDE_ARMORY_SKIP_VERIFY=1
# to disable it for a session.
#
# Contract: exit 2 with {"decision":"block","reason":...} blocks the stop and hands the errors
# back to Claude. exit 0 lets it finish.

INPUT=$(cat)

[ -n "$CLAUDE_ARMORY_SKIP_VERIFY" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

# Claude Code sets stop_hook_active=true on the retry after this hook blocked once. Without this
# guard the block-fix-block cycle never terminates.
if [ "$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false')" = "true" ]; then
  exit 0
fi

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Only files this working tree has actually modified: tracked changes plus new untracked files.
CHANGED=$(
  {
    git diff --name-only --diff-filter=ACMR HEAD 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | sort -u
)
[ -z "$CHANGED" ] && exit 0

# Keep only files that still exist and that a linter available here can check.
PY_FILES=""
JS_FILES=""
while IFS= read -r f; do
  [ -f "$f" ] || continue
  case "$f" in
    *.py)                      PY_FILES="${PY_FILES}${f}"$'\n' ;;
    *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs) JS_FILES="${JS_FILES}${f}"$'\n' ;;
  esac
done <<< "$CHANGED"

ERRORS=""
CHECKS_RUN=0

if [ -n "$PY_FILES" ] && command -v ruff >/dev/null 2>&1; then
  CHECKS_RUN=$((CHECKS_RUN + 1))
  RUFF_OUTPUT=$(printf '%s' "$PY_FILES" | xargs -d '\n' -r ruff check 2>&1)
  RUFF_RC=$?
  if [ "$RUFF_RC" -ne 0 ]; then
    ERRORS="${ERRORS}ruff:
$(printf '%s' "$RUFF_OUTPUT" | head -40)

"
  fi
fi

if [ -n "$JS_FILES" ]; then
  # Only run eslint where the project configures it, otherwise npx would try to fetch it.
  HAS_ESLINT=0
  for cfg in .eslintrc .eslintrc.js .eslintrc.cjs .eslintrc.json .eslintrc.yml \
             eslint.config.js eslint.config.mjs eslint.config.cjs eslint.config.ts; do
    [ -f "$cfg" ] && HAS_ESLINT=1 && break
  done
  if [ "$HAS_ESLINT" -eq 1 ]; then
    CHECKS_RUN=$((CHECKS_RUN + 1))
    ESLINT_OUTPUT=$(printf '%s' "$JS_FILES" | xargs -d '\n' -r npx --no-install eslint --quiet 2>&1)
    ESLINT_RC=$?
    if [ "$ESLINT_RC" -ne 0 ]; then
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
