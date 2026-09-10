#!/usr/bin/env bash
# The session's single Stop hook. Sibling hooks on one event run in
# parallel with no ordering, so steps that depend on each other are
# sequenced here instead: format what changed, then run the gate, then
# update the ticket only if the gate passed. One hook, one order.
set -uo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
input=$(cat)

# 1. Restore the formatting invariant on the session's changed files.
"$dir/format-changed.sh" <<<"$input"

# 2. The definition-of-done gate. If it blocks, print its JSON verdict
#    and stop here: the turn is not ending, so the ticket must not move.
verdict=$("$dir/stop-gate.sh" <<<"$input")
if [ -n "$verdict" ]; then
  printf '%s\n' "$verdict"
  exit 0
fi

# 3. The work is done and verified: now the board may say so.
"$dir/../../scripts/update-clickup-end.sh" <<<"$input"
