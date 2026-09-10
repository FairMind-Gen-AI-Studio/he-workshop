#!/usr/bin/env bash
# Moves the ClickUp task on when the session's turn ends, so the board
# reflects reality without the model having to remember anything.
# Without CLICKUP_TOKEN and CLICKUP_TASK_ID it exits quietly.
set -euo pipefail

if [ -z "${CLICKUP_TOKEN:-}" ] || [ -z "${CLICKUP_TASK_ID:-}" ]; then
  exit 0
fi

curl -s -X PUT "https://api.clickup.com/api/v2/task/${CLICKUP_TASK_ID}" \
  -H "Authorization: ${CLICKUP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"status": "in review"}' > /dev/null
