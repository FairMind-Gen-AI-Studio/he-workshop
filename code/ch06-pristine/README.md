# Chapter 6 companion configuration

The hooks Chapter 6 builds, wired together in one project configuration.
Copy the pieces you need; every script is self-contained.

## Layout

| File | Event | Pattern |
|---|---|---|
| `.claude/hooks/block-aws-blocklist.sh` | PreToolUse (Bash) | Pre-action gate, blocklist form: blocks dangerous and secret-leaking AWS CLI commands by pattern, exit 2 |
| `.claude/hooks/gate-aws-cli.sh` | PreToolUse (Bash) | Pre-action gate, classifier form: deny credential reads, ask on writes, stay silent on read-only verbs so the permission rules decide (`hookSpecificOutput.permissionDecision`) |
| `.claude/hooks/check-env-consistency.sh` | PreToolUse (Bash) | Pre-action consistency gate: blocks mutating infrastructure commands when git branch, kubectl context and terraform backend disagree |
| `.claude/hooks/check-raw-sql.sh` | PostToolUse (Edit\|Write) | Post-action invariant: raw SQL outside the data-access layer is reported back as a blocking reason |
| `.claude/hooks/on-stop.sh` | Stop | The single registered Stop hook: sequences format, then gate, then ticket update. Sibling hooks run in parallel with no ordering, so dependent steps live in one script |
| `.claude/hooks/format-changed.sh` | called by `on-stop.sh` | Post-action invariant: prettier and eslint over the session's changed files only, never blocks |
| `.claude/hooks/stop-gate.sh` | called by `on-stop.sh` | Self-correction gate: blocks the turn until the definition-of-done commands pass, failing output as the reason |
| `.claude/hooks/log-bash.sh` | PreToolUse (Bash) | Record: one JSON line per shell command, with session id and ticket id as join keys |
| `scripts/update-clickup-end.sh` | called by `on-stop.sh` | Post-action invariant with failure visibility: ticket update that reports its own failure instead of vanishing, and runs only after the gate has passed |
| `.claude/settings.json` | | Wires all of the above, plus a ConfigChange audit log and deny rules protecting the hooks themselves |

`package.json`, `src/` and `test/` are a minimal project with no
dependencies, so that `stop-gate.sh` has a real `pnpm test`, `pnpm typecheck`
and `pnpm lint` to run. Break `test/sum.test.js` to watch the gate block.

`scripts/update-clickup-start.sh` is unchanged from `code/ch04/scripts/`
and is referenced by the settings file for completeness.

## Requirements

`bash`, `jq`, `git`; `npx` with `prettier` and `eslint` for
`format-changed.sh`; a `pnpm` project for `stop-gate.sh` (edit the
`checks` array for other stacks); `kubectl` and `terraform` only if you
use the consistency gate; `CLICKUP_TOKEN` and `CLICKUP_TASK_ID` in the
environment for the ticket scripts.

## Trying a hook by hand

Every hook reads its event payload from stdin, so you can test one
without a session:

```bash
echo '{"tool_input": {"command": "aws rds delete-db-instance --db-instance-identifier prod-main"}}' \
  | .claude/hooks/gate-aws-cli.sh
```

Expected: a JSON `permissionDecision` of `ask` (or `deny` for a
credential read), and exit code 2 with a stderr message from the
blocklist form.
