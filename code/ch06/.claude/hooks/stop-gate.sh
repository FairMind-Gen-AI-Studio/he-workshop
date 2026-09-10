#!/usr/bin/env bash
# Stop hook: the definition-of-done gate. Runs the checks the contract
# names and blocks the turn from ending until they pass, with the failing
# output as the reason so the agent has something to act on. Claude Code
# overrides the hook after 8 consecutive blocks; raise the cap with
# CLAUDE_CODE_STOP_HOOK_BLOCK_CAP only if a check legitimately needs more.
set -uo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

checks=(
  "pnpm test"
  "pnpm typecheck"
  "pnpm lint"
)

for check in "${checks[@]}"; do
  if ! output=$($check 2>&1); then
    tail=$(printf '%s\n' "$output" | tail -20)
    jq -n --arg reason "Definition of done not met: '$check' failed. Fix this before finishing:
$tail" '{decision: "block", reason: $reason}'
    exit 0
  fi
done

exit 0
