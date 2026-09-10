#!/usr/bin/env bash
# Stop hook: mark the ClickUp task done when the session's work ends.
# Hardened form of the Chapter 4 script: a session with no ticket attached
# still passes silently, but a FAILED update is reported into the loop
# instead of vanishing. The hook never blocks the turn.
set -uo pipefail

if [ -z "${CLICKUP_TOKEN:-}" ] || [ -z "${CLICKUP_TASK_ID:-}" ]; then
  exit 0
fi

update () {
  curl --silent --fail --max-time 10 -X PUT \
    "https://api.clickup.com/api/v2/task/${CLICKUP_TASK_ID}" \
    -H "Authorization: ${CLICKUP_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"status": "review"}' > /dev/null
}

if update || { sleep 2 && update; }; then
  exit 0
fi

# The invariant did not hold and someone has to know. Non-error feedback
# keeps the conversation going without a hook-error notice.
jq -n --arg ctx "The ClickUp update for task ${CLICKUP_TASK_ID} failed twice. The board no longer reflects reality: tell the user to update the ticket by hand." \
  '{hookSpecificOutput: {hookEventName: "Stop", additionalContext: $ctx}}'
exit 0
