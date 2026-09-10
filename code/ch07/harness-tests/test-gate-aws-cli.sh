#!/usr/bin/env bash
# Adversarial suite for Chapter 6's PreToolUse gate. The gate reads its event
# payload as JSON on stdin, which makes it a pure function this file can call
# without a session. GATE is overridable so run.sh can point the same suite at
# a deliberately broken copy and watch it go red.
set -uo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
GATE=${GATE:-"$here/../../ch06-pristine/.claude/hooks/gate-aws-cli.sh"}

failures=0
fail() { printf '  FAIL  %s\n' "$*" >&2; failures=$((failures + 1)); }

# code/ch07/harness-tests/test-gate-aws-cli.sh
check() {
  out=$(echo "{\"tool_input\":{\"command\":\"$1\"}}" | "$GATE")
  # No output at all is the gate's third answer: it declined to decide and
  # left the call to the permission rules. That silence is assertable too.
  if [ -z "$out" ]; then
    decision=silent
  else
    decision=$(jq -r '.hookSpecificOutput.permissionDecision' <<<"$out")
  fi
  [ "$decision" = "$2" ] || fail "$1: expected $2, got $decision"
}

# command                                              expected decision
check "aws ssm get-parameter --name /prod/db-password"  deny
check "aws ssm get-parameters-by-path --path /prod"     deny
check "aws rds delete-db-instance --db-instance-id x"   ask
check "aws s3 ls s3://reports/"                         silent

if [ "$failures" -eq 0 ]; then
  echo "  4 cases, all as expected"
fi
exit "$failures"
