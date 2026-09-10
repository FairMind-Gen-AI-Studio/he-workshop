#!/usr/bin/env bash
# PreToolUse classifier for the AWS CLI: default-deny instead of
# enumerate-the-bad. Credential reads are denied, everything that is not a
# read-only verb asks a human, and a read-only verb gets no answer at all:
# the hook exits 0 and the permission rules decide. The gate subtracts, it
# never grants. Uses the current PreToolUse decision field
# (hookSpecificOutput.permissionDecision); the older top-level decision and
# reason fields are deprecated for this event.
set -euo pipefail

input=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$input")

# Only judge commands that invoke the AWS CLI.
[[ "$command" == *aws\ * || "$command" == aws\ * ]] || exit 0

decide () {
  jq -n --arg d "$1" --arg r "$2" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: $d,
      permissionDecisionReason: $r
    }
  }'
  exit 0
}

# Leg 1: credential reads are denied outright, whatever else the command
# looks like. "ssm get-parameter" catches every Parameter Store verb that
# returns a value; the decrypt flag is not the test, because a secret
# stored as a plain String comes back in clear without it.
if [[ "$command" == *"get-secret-value"* \
   || "$command" == *"ssm get-parameter"* \
   || "$command" == *"--with-decryption"* ]]; then
  decide deny "Credential reads are blocked in agent sessions. Ask the operator."
fi

# Leg 2: classify the service verb. aws <service> <action> [args...]
verb=$(awk '{for (i=1; i<NF; i++) if ($i=="aws") {print $(i+2); exit}}' <<<"$command")

case "$verb" in
  describe-*|get-*|list-*|ls|head-*|lookup-*)
    # Read-only verb: say nothing and let the permission rules decide.
    exit 0
    ;;
  ""|help|--version)
    exit 0
    ;;
  *)
    # Everything else is a write until proven otherwise: a human decides.
    decide ask "aws verb '$verb' is not in the read-only class. Confirm this write."
    ;;
esac
