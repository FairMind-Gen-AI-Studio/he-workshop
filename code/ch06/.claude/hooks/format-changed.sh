#!/usr/bin/env bash
# Stop hook: format only what this session changed, before the work leaves
# the developer's machine. Never blocks the turn and never rewrites code
# anywhere downstream; the pipeline validates, the session formats.
set -uo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

changed=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(ts|tsx|js|jsx)$')
[[ -n "$changed" ]] || exit 0

# shellcheck disable=SC2086
npx prettier --write $changed >/dev/null 2>&1
# shellcheck disable=SC2086
npx eslint --fix $changed >/dev/null 2>&1

exit 0
