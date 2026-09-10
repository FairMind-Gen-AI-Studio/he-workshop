#!/usr/bin/env bash
# PreToolUse guard for the Bash tool: block dangerous AWS CLI commands by
# pattern. The first, incident-closing form. Exit 2 blocks the call and
# sends stderr back to Claude as the explanation.
set -euo pipefail

input=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$input")

# Not a bash call carrying an aws command: stay out of the way.
[[ "$command" == *aws\ * || "$command" == aws\ * ]] || exit 0

blocked_patterns=(
  "delete-"          # aws rds delete-db-instance, aws s3api delete-bucket...
  "terminate-"       # aws ec2 terminate-instances
  "stop-db-instance"
  "put-bucket-policy"
  "rm "              # aws s3 rm
  "get-secret-value" # aws secretsmanager get-secret-value
  "--with-decryption" # aws ssm get-parameter --with-decryption
)

for pattern in "${blocked_patterns[@]}"; do
  if [[ "$command" == *"$pattern"* ]]; then
    echo "Blocked: '$pattern' matches a command this project does not allow" \
         "the agent to run. Use the read-only form (describe-*, get-*, list-*," \
         "ls) or ask the operator to run it." >&2
    exit 2
  fi
done

exit 0
