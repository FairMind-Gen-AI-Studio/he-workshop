# Lab 4: The enforcement layer

**Time:** 35 minutes · **Where:** `code/ch06/` · **You need:** `claude`,
`bash`, `jq`, `pnpm`, `npx`

**Goal:** see a hook make a decision the agent cannot talk its way out of,
and learn the one ordering trap that bites in production.

`code/ch06/` holds eight hooks wired in `.claude/settings.json`. This lab uses
four of them: `gate-aws-cli.sh` (a `PreToolUse` classifier for the AWS CLI),
`on-stop.sh` (the single `Stop` hook), `stop-gate.sh` (the definition-of-done
gate `on-stop.sh` calls) and `log-bash.sh` (one JSON line per shell command).
`package.json`, `src/` and `test/` are a minimal project so that `stop-gate.sh`
has a real `pnpm test`, `pnpm typecheck` and `pnpm lint` to run.

You do not need AWS credentials or even the AWS CLI: the gate decides before
anything runs.

## a) Try the gate by hand, no session

Every hook reads its event payload as JSON on stdin, so you can call it like a
function.

1. From the repository root:

   ```bash
   cd code/ch06
   ```

2. Send the four payloads, one at a time, and **read the JSON, not the exit
   code**. All four exit 0.

   ```bash
   echo '{"tool_input":{"command":"aws ssm get-parameter --name /prod/db-password"}}' \
     | .claude/hooks/gate-aws-cli.sh
   ```

   ```json
   {
     "hookSpecificOutput": {
       "hookEventName": "PreToolUse",
       "permissionDecision": "deny",
       "permissionDecisionReason": "Credential reads are blocked in agent sessions. Ask the operator."
     }
   }
   ```

   ```bash
   echo '{"tool_input":{"command":"aws ssm get-parameters-by-path --path /prod"}}' \
     | .claude/hooks/gate-aws-cli.sh
   ```

   Expected: the same `deny`.

   ```bash
   echo '{"tool_input":{"command":"aws rds delete-db-instance --db-instance-identifier prod-main"}}' \
     | .claude/hooks/gate-aws-cli.sh
   ```

   ```json
   {
     "hookSpecificOutput": {
       "hookEventName": "PreToolUse",
       "permissionDecision": "ask",
       "permissionDecisionReason": "aws verb 'delete-db-instance' is not in the read-only class. Confirm this write."
     }
   }
   ```

   ```bash
   echo '{"tool_input":{"command":"aws s3 ls s3://reports/"}}' \
     | .claude/hooks/gate-aws-cli.sh
   ```

   Expected: **nothing at all**.
3. Explain the fourth answer to yourself. The gate never says `allow`. On a
   read-only verb it stays silent and the permission rules decide. The
   difference between answering `ask` and answering nothing is the whole design
   of the gate: it subtracts, it never grants.
4. Open `.claude/hooks/gate-aws-cli.sh` and find the two legs: the credential
   deny, and the verb classifier.

## b) Register it as PreToolUse

The gate is already registered in `code/ch06/.claude/settings.json`. Read the
registration before you trust it:

1. Find it:

   ```bash
   jq '.hooks.PreToolUse' .claude/settings.json
   ```

   It sits under `PreToolUse` with `"matcher": "Bash"`, next to `log-bash.sh`
   and `check-env-consistency.sh`. If you copy the gate into your own project,
   this block is what you copy with it.
2. Start a session in `code/ch06` and type `/hooks`. Check that the three
   `PreToolUse` hooks on `Bash` are listed, then leave the menu.
3. Ask the agent to run the first payload's command:

   ```text
   Run exactly this shell command and report what happened, including any hook
   message: aws ssm get-parameter --name /prod/db-password
   ```

   **Expected:** the command never runs. The agent reports a `PreToolUse:Bash`
   hook error carrying the gate's reason, "Credential reads are blocked in agent
   sessions. Ask the operator."
4. Ask for the delete command too. **Expected:** Claude Code asks you to
   confirm. Say no.
5. Check the record the logger kept, including the denied call:

   ```bash
   tail -n 2 .claude/logs/bash-audit.jsonl | jq .
   ```

## c) Wire on-stop.sh and break a test

`on-stop.sh` is already wired as the only `Stop` hook. It formats the changed
files, then runs `stop-gate.sh`, then updates the ticket only if the gate
passed. Without `CLICKUP_TOKEN` the ticket step exits quietly.

1. Check the project is green and the gate is silent:

   ```bash
   pnpm test
   echo '{}' | CLAUDE_PROJECT_DIR="$PWD" .claude/hooks/stop-gate.sh
   ```

   `pnpm test` reports `# pass 1`; the gate prints nothing.
2. Break the test:

   ```bash
   sed -i.bak 's/sum(2, 3), 5/sum(2, 3), 6/' test/sum.test.js && rm test/sum.test.js.bak
   echo '{}' | CLAUDE_PROJECT_DIR="$PWD" .claude/hooks/stop-gate.sh | jq -r .decision
   ```

   The gate now prints `block`.
3. Start a session in `code/ch06` and ask the agent to finish:

   ```text
   Nothing to do here, just reply "done".
   ```

4. Watch. The agent does not get to stop. What comes back to it is the output
   of the failing command, starting with
   `Definition of done not met: 'pnpm test' failed. Fix this before finishing:`
   followed by the assertion (`expected: 6`, `actual: 5`), not a verdict. It
   then goes back to work on its own. That is the loop closing.
5. Look at what it changed (`git diff test/ src/`) and decide whether the fix
   is the right one.

## d) The trap: two sibling Stop hooks

Hooks registered on the same event run in parallel, with no ordering. That is
why `on-stop.sh` is a single hook that sequences its steps inside itself.

1. Install two sibling `Stop` hooks, "format" and "gate", where the gate
   expects the format step to be finished. They only write to a log:

   ```bash
   cp ../../kit/lab4/sibling-stop-hooks.json .claude/settings.local.json
   ```

2. Run a few turns:

   ```bash
   for i in 1 2 3; do claude -p "Reply with the word ok." > /dev/null; done
   cat .claude/logs/stop-order.log
   ```

3. Read the order. You will see lines like:

   ```text
   gate: start (expects format to be finished)
   format: start
   gate: end
   format: end
   ```

   The gate started before the format step ended, and sometimes before it
   started. Run it more than once: the race does not always show, which is
   exactly why it is dangerous.

## Done when

- You got `deny`, `deny`, `ask` and silence by hand, and can say why the last
  one is silence and not `allow`.
- A real session refused the credential read with the gate's reason.
- The agent was stopped by the broken test and resumed on its own.
- You saw two sibling Stop hooks start out of order.

Finished early? Write a consistency gate for your own environment, modelled on
`.claude/hooks/check-env-consistency.sh`.

## Reset

```bash
cd "$(git rev-parse --show-toplevel)/code/ch06"
rm -f .claude/settings.local.json
rm -rf .claude/logs node_modules pnpm-lock.yaml
git checkout -- .
```
