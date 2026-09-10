#!/usr/bin/env bash
# PostToolUse invariant on Edit|Write: database access goes through the
# repository layer. Raw SQL in application code is reported back to Claude
# as a blocking reason, so it gets fixed while the edit is still the
# current task. The file has already been written; this hook cannot and
# does not undo it.
set -euo pipefail

input=$(cat)
file=$(jq -r '.tool_input.file_path // empty' <<<"$input")

# The data-access layer is allowed to contain SQL; everything else is not.
[[ -n "$file" && -f "$file" ]] || exit 0
case "$file" in
  */src/db/*|*/migrations/*) exit 0 ;;
  *.ts|*.js|*.py) ;;
  *) exit 0 ;;
esac

if grep -n -E "(SELECT|INSERT INTO|UPDATE|DELETE FROM)[^\"']*(FROM|VALUES|SET|WHERE)" "$file" |
   grep -v -E "^\s*(//|#|\*)" > /tmp/raw-sql-hits.$$ 2>/dev/null; then
  hits=$(head -3 /tmp/raw-sql-hits.$$)
  rm -f /tmp/raw-sql-hits.$$
  jq -n --arg reason "Raw SQL found in $file. Database access goes through the repository layer under src/db/; rewrite these lines to use it: $hits" \
    '{decision: "block", reason: $reason}'
  exit 0
fi

rm -f /tmp/raw-sql-hits.$$ 2>/dev/null
exit 0
