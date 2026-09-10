#!/usr/bin/env bash
# PreToolUse logger: one JSON line per shell command, before it runs.
# Exit 0 always; the record must never interfere with the work. If a
# sibling guardrail hook denies the call, this line is still written,
# which is exactly what a record is for.
set -uo pipefail

log_dir="${CLAUDE_PROJECT_DIR:-.}/.claude/logs"
mkdir -p "$log_dir"

jq -c '{
  ts: (now | todate),
  session: .session_id,
  cwd: .cwd,
  ticket: (env.CLICKUP_TASK_ID // null),
  command: .tool_input.command
}' >> "$log_dir/bash-audit.jsonl"

exit 0
