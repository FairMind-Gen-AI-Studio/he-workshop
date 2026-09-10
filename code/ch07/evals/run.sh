#!/usr/bin/env bash
# Two commands, because the halves cost different things.
#
#   predict  runs the agent against every task and writes down what happened,
#            including the raw signals rather than the buckets they fall into.
#            This is the half that costs money or a GPU.
#   score    reads that file and computes the metrics. It consults nothing,
#            runs in a second, and is the reason a run recorded last month can
#            be re-scored against a criterion that did not exist at the time.
set -uo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo=$(cd "$here/../../.." && pwd)

usage() {
  cat <<'EOF'
# the half that costs money or a GPU
./run.sh predict --backend <target> --dataset <dir> --split <name> --out predictions.jsonl

# the half that is arithmetic over stored output
./run.sh score   --dataset <dir> --predictions predictions.jsonl
EOF
}

cmd=${1:-}
shift || true

case "$cmd" in
  score)
    exec python3 "$here/score.py" "$@"
    ;;
  predict)
    # Deliberately not implemented here. Running the tasks needs an agent and a
    # target repository, and every harness wires that differently: Claude Code
    # in headless mode, a CI job, Harbor, your own runner. What this file fixes
    # is the contract, so that whatever produces predictions.jsonl can be
    # swapped without touching the scorer.
    cat >&2 <<EOF
predict needs an agent and a target repository, so it is not wired here.

Emit one JSON object per line to --out, with these fields:

  {"task_id": "<id from the task yaml>",
   "outcome": "answered" | "abstained" | "oversize" | "error",
   "passed": true | false,          # only meaningful when outcome is answered
   "confidence": 0.0-1.0,           # store the raw signal, never the bucket
   "notes": "free text"}

Store the confidence itself rather than the verdict it produced: one stored
run then answers what would have happened at every other threshold.

Then: ./run.sh score --dataset $here/tasks --predictions <out>
EOF
    exit 64
    ;;
  ""|-h|--help|help)
    usage
    ;;
  *)
    echo "unknown command: $cmd" >&2
    usage >&2
    exit 64
    ;;
esac
