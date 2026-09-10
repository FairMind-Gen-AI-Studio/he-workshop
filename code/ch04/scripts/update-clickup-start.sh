#!/usr/bin/env bash
# Sets the ClickUp task status when a session starts working on a ticket.
# Without CLICKUP_TOKEN and CLICKUP_TASK_ID it exits quietly, so a session
# with no ticket attached is never blocked by this hook.
set -euo pipefail

if [ -z "${CLICKUP_TOKEN:-}" ] || [ -z "${CLICKUP_TASK_ID:-}" ]; then
  exit 0
fi

curl -s -X PUT "https://api.clickup.com/api/v2/task/${CLICKUP_TASK_ID}" \
  -H "Authorization: ${CLICKUP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"status": "in progress"}' > /dev/null
