# Chapter 7 companion code

The instruments Chapter 7 builds, pointed at the harness Chapter 6 shipped.
Copy the pieces you need; every script is self-contained.

## Layout

| File | What it is |
|---|---|
| `harness-tests/test-gate-aws-cli.sh` | The adversarial suite: four payloads fed to `code/ch06-pristine`'s `gate-aws-cli.sh` on stdin, asserting deny, deny, ask and silence |
| `harness-tests/run.sh` | Runs that suite twice, green against the real gate and red against a copy with the credential-deny leg removed |
| `.claude/settings.json` | The read-only control: deny `Edit` and `Write` under test directories while the agent is implementing |
| `evals/run.sh` | The eval-set runner, split into `predict` and `score` |
| `evals/score.py` | The scorer, with four outcomes instead of two |
| `evals/tasks/*.yaml` | Task definitions |
| `evals/runs/example-predictions.jsonl` | Stored output, so `score` runs without an agent |

## Requirements

`bash`, `jq` and `awk` for the harness tests; `python3` with `pyyaml` for the
scorer. Nothing else, and nothing to install for the gate suite.

## Watching the suite fail

The point of `run.sh` is the second half. A suite that has only ever been seen
green proves nothing, so the script cuts the credential-deny branch out of a
copy of the gate and runs the same four cases again:

```
$ bash harness-tests/run.sh
green run: the gate as shipped
  4 cases, all as expected

red run: the same suite against a gate with its deny leg removed
  FAIL  aws ssm get-parameter --name /prod/db-password: expected deny, got silent
  FAIL  aws ssm get-parameters-by-path --path /prod: expected deny, got silent

both runs behaved: green against the real gate, red on both deny cases
against the broken one. The suite has now been observed failing.
```

Read the failure text rather than the word FAIL. With its deny leg removed the
gate does not answer `allow`, it answers nothing: `get-parameter` falls through
to the read-only class and the hook exits silently. A gate that has quietly
stopped denying looks exactly like a gate that is working, which is the whole
reason the red run exists. If `run.sh` ever reports a green red-run, that is a
build failure and the script exits non-zero.

## The read-only control

`.claude/settings.json` denies writes to test directories. Merge it into the
project settings of the repository the agent works in, not into this one. Lift
it deliberately, in a separate session, when the job actually is to write
tests: a rule that is never lifted gets deleted by whoever hits it on a Friday.

## Running the eval-set

`score` runs today, against output that was recorded earlier:

```
$ bash evals/run.sh score --dataset evals/tasks --predictions evals/runs/example-predictions.jsonl
  tasks in dataset   2
  answered 2  abstained 1  oversize 1  error 1
  attempted          4  (oversize held out)
  pass rate          25%
```

Four outcomes, and `oversize` is the one worth arguing about. It means the case
never reached the model, usually because the rendered request did not fit the
context budget, and it is held out of the denominator rather than counted as a
wrong answer. Add three more oversize rows to the predictions file and the pass
rate stays at 25%: a plumbing problem upstream cannot masquerade as a drop in
model quality. `abstained` and `error` stay separate for the same reason. Both
mean escalate to a human, and they mean entirely different things about your
configuration.

`predict` is not wired here, because running the tasks needs an agent and a
target repository and every harness wires that differently. What this directory
fixes is the contract: emit one JSON object per line with `task_id`, `outcome`,
`passed`, `confidence` and `notes`, and any runner can be swapped in without
touching the scorer. `bash evals/run.sh predict` prints that contract.

Store the confidence itself rather than the verdict it produced. One stored run
then answers what would have happened at every other threshold, and no amount
of re-running the model recovers that if the only thing written down was the
yes or the no.

## The two tasks

`tasks/gate-denies-credential-read.yaml` runs against this repository, so the
format is demonstrably real rather than a mock-up. `tasks/ticket-sync-on-stop.yaml`
is the shape from the chapter and points at a repository you supply: it expects
a `pnpm` project, a ClickUp token and a failing test three commits back. Both
grade with commands that return an exit code, which is the same discipline
Chapter 6 required of a Stop hook and for the same reason.

Note the last check in the ticket task. It asserts that the agent did not edit
the harness while completing the work, which is the read-only principle above
expressed as a test instead of a permission rule. The rule stops the edit; the
check tells you when the rule has stopped working.
