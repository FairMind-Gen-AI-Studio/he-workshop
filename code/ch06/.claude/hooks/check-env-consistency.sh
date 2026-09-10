#!/usr/bin/env bash
# PreToolUse consistency gate: before any mutating infrastructure command,
# verify that the sources of truth agree about which environment is live.
# Git branch, kubectl context and terraform backend each imply an
# environment; if they disagree, the command does not run and the
# disagreement goes back to Claude spelled out.
set -o pipefail

input=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$input")

# Only infrastructure commands are judged.
[[ "$command" =~ (terraform|kubectl|flux|helm) ]] || exit 0

# Read-only forms pass without a check.
if [[ "$command" =~ (terraform (init|output|show|validate|fmt|state list)) ]] ||
   [[ "$command" =~ (kubectl (get|describe|logs|top|config)) ]] ||
   [[ "$command" =~ (flux (get|logs)) ]] ||
   [[ "$command" =~ (helm (list|status|show|get)) ]]; then
  exit 0
fi

# Each source of truth votes on the environment.
branch=$(git -C "${CLAUDE_PROJECT_DIR:-.}" rev-parse --abbrev-ref HEAD 2>/dev/null)
case "$branch" in
  main) git_env="prod" ;;
  dev)  git_env="dev" ;;
  *)    git_env="unknown" ;;
esac

context=$(kubectl config current-context 2>/dev/null || echo "")
case "$context" in
  *-prod*) kube_env="prod" ;;
  *-dev*)  kube_env="dev" ;;
  *)       kube_env="unknown" ;;
esac

bucket=$(jq -r '.backend.config.bucket // empty' \
  "${CLAUDE_PROJECT_DIR:-.}/.terraform/terraform.tfstate" 2>/dev/null)
case "$bucket" in
  *-prod) tf_env="prod" ;;
  *-dev)  tf_env="dev" ;;
  *)      tf_env="unknown" ;;
esac

# Any two known votes that disagree block the command.
for pair in "git:$git_env kubectl:$kube_env" \
            "git:$git_env terraform:$tf_env" \
            "kubectl:$kube_env terraform:$tf_env"; do
  read -r a b <<<"$pair"
  ea=${a#*:}; eb=${b#*:}
  if [[ "$ea" != "unknown" && "$eb" != "unknown" && "$ea" != "$eb" ]]; then
    echo "Blocked: ${a%%:*} says '$ea' but ${b%%:*} says '$eb'." \
         "Align branch, kubectl context and terraform backend to the same" \
         "environment before running mutating commands." >&2
    exit 2
  fi
done

exit 0
