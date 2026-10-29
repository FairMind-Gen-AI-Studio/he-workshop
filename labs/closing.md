# Closing: Back to your sheets

**Time:** 10 minutes · **Where:** your own files, on your own · **You need:** your
[Exercise 1](exercise-1.md) sheet and your [Lab 1](lab-1.md) matrix

**Goal:** turn the failure you wrote this morning into one artifact you will
build, with a name, a holder and a way to see it fail.

## Steps

1. **Place the day on your matrix.** Each lab built artifacts for one or more
   cells. Add them to your Lab 1 matrix, marked apart from this morning's entries, with `comp`
   or `inf`:

   | Lab | Artifact | Cell | Kind |
   |---|---|---|---|
   | [Lab 2](lab-2.md) | Trimmed CLAUDE.md, nested contract | System prompt and context · Guide | inf |
   | [Lab 2](lab-2.md) | `verify-done` skill | Tools and descriptions · Guide | inf |
   | [Lab 3](lab-3.md) | User deny floor, sandbox | Infrastructure · Boundary | comp |
   | [Lab 3](lab-3.md) | Dev container egress firewall | Infrastructure · Boundary | comp |
   | [Lab 4](lab-4.md) | `gate-aws-cli.sh` | Hooks and middleware · Boundary | comp |
   | [Lab 4](lab-4.md) | `stop-gate.sh` through `on-stop.sh` | Hooks and middleware · Sensor | comp |
   | [Lab 4](lab-4.md) | `log-bash.sh` | Hooks and middleware · Record | comp |
   | [Lab 5](lab-5.md) | Adversarial suite, eval-set scorer | Sensor on the harness itself | comp |

   These are the workshop's artifacts, not yours. The question is which of
   your empty cells now has a shape you know how to fill.
2. **Go back to your three empty cells.** For each one, write the primitive
   that would fill it, by its precise name: contract, skill, permission rule,
   hook, sandbox. If you cannot name one, write "not yet" and leave it.
3. **Read your Exercise 1 failure again.** Answer the question on the sheet,
   "Check whether you now know how to close it", with one of:
   - **Yes:** name the artifact, the file it lives in, and the cell it fills.
   - **Partly:** name what you would build and what you still do not know.
   - **No:** write what is missing. That is an honest answer, and a useful one.
4. **Check the holder.** If the failure is one you routed as "no going back"
   in [Exercise 2](exercise-2.md), the artifact must be `comp`. A line in
   CLAUDE.md for an irreversible failure raises a probability; it does not
   close the failure. Route it again.
5. **Write how you will see it fail.** One line: the payload, the broken copy
   or the test that proves your artifact can say no. [Lab 5](lab-5.md) is the
   reason: an instrument you have never seen fail proves nothing.

## Done when

- The day's artifacts are on your matrix, each with `comp` or `inf`.
- Each of your three empty cells has a primitive or an explicit "not yet".
- Your Exercise 1 failure has a yes, partly or no, and a next artifact.
- You wrote how you will see that artifact fail.

## A worked example

The closing for the failure carried through the day's examples, "it declares
an endpoint done when it mocked the response". Do your own first.

- **Empty cells** (from the [Lab 1](lab-1.md) example):
  1. Boundary: a `PreToolUse` hook on `Edit` that denies mock imports outside
     `test/`, shaped like `gate-aws-cli.sh` from [Lab 4](lab-4.md).
  2. Record: a `PostToolUse` hook that logs every check command and its exit
     code, shaped like `log-bash.sh`.
  3. Guide: not needed, empty by decision.
- **The failure: yes.** The [Exercise 2](exercise-2.md) answer was a hook. The
  artifact is a `Stop` gate like `stop-gate.sh`, called from a single
  `on-stop.sh`, that runs the integration tests against a real database
  instead of the unit tests alone. It strengthens the Sensor cell that the
  Lab 1 example had filled with a check that missed the failure. Kind: comp.
- **The holder:** the failure is recoverable, but the CLAUDE.md line in
  [Lab 2](lab-2.md) was already ignored, so the holder is the hook, not the
  file.
- **How it will fail:** replace one handler with a hard-coded response, as in
  Lab 4 step c.2, and check the gate prints `block`. Then a red run in the
  style of [Lab 5](lab-5.md): the same check against a copy of the gate with
  the integration step removed, which must come back silent.

## Take it home

Keep both sheets. The first artifact to build on Monday is the one on the
first line of your three empty cells.
