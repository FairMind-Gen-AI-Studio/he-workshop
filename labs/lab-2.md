# Lab 2: A contract that changes behavior

**Time:** 30 minutes · **Where:** `kit/lab2/` and `code/ch04/` · **You need:**
`claude`

**Goal:** cut a bloated CLAUDE.md down to what the repository cannot say for
itself, give it a definition of done, and see what a contract can and cannot
enforce.

`kit/lab2/CLAUDE.md` is a 191-line instruction file for a fictional monorepo,
Fairmind Studio. `code/ch04/` is the reference contract for the same monorepo:
32 lines, a definition of done, a `verify-done` skill and a nested file in
`services/api/`. You work on the first and compare against the second. Neither
directory contains application code, only the contract files.

## a) Cut the bloated CLAUDE.md

1. From the repository root:

   ```bash
   cd kit/lab2
   wc -l CLAUDE.md        # 191 CLAUDE.md
   claude
   ```

2. In the session, paste the content of `code/ch04/prompts/audit-claude-md.txt`:

   ```text
   Read CLAUDE.md. For each line, answer three questions.
   1. If you ignored this line, what would it cost: something
      unacceptable (money, data, production) or something recoverable?
   2. Does every session need it, or only work on certain paths?
   3. Could you have worked it out from the code alone?
   Return a table with one row per line and a verdict for each:
   keep, move to a rule, move to a skill, become a hook, delete.
   Change nothing yet.
   ```

   The prompt says "Read CLAUDE.md" and in this folder that file is the bloated
   one, so it runs unchanged.
3. Read the table. Then **decide yourself**, section by section, with one test:
   *can the repository say this for itself?* A directory tree, a stack list, a
   dependency list: the repository says them, and says them more accurately.
   A command with a trap behind it, a convention no file declares: the
   repository cannot, so they stay.
4. Edit `kit/lab2/CLAUDE.md` by hand (or ask the agent to apply your verdicts)
   and delete what fails the test.
5. Measure:

   ```bash
   wc -l CLAUDE.md
   ```

   The reference contract, `code/ch04/CLAUDE.md`, has 32 lines. If you land
   between 30 and 45 you have understood the test. Above 80, you cut words
   instead of paragraphs: go back to step 3. Write down your number, not
   "I shortened it".

## b) Write the definition of done

1. Add a `## Definition of done` section to your trimmed `kit/lab2/CLAUDE.md`.
   List the checks that must pass before the agent may call a task finished.
2. Next to each criterion, mark who holds it: **the file** (the agent reads it
   and may comply), **a hook** (a script enforces it), or **the human**.
3. Compare with the reference:

   ```bash
   sed -n '/## Definition of done/,$p' ../../code/ch04/CLAUDE.md
   ```

   The reference names its holders in brackets: the ticket update is "held by
   the Stop hook, not by this file", the human review is "ours to do, not the
   agent's".
4. Wire the definition of done into a skill. Copy the reference skill next to
   your contract and edit its numbered steps so they match your criteria:

   ```bash
   mkdir -p .claude/skills
   cp -R ../../code/ch04/.claude/skills/verify-done .claude/skills/
   $EDITOR .claude/skills/verify-done/SKILL.md
   ```

5. Restart `claude` in `kit/lab2` and type `/verify-done`. The skill should be
   offered. Its steps must name the same checks as your contract, one row per
   criterion.

## c) Add the nested level

1. Read the two layers of the reference contract:

   ```bash
   cd ../../code/ch04
   cat CLAUDE.md services/api/CLAUDE.md
   ```

2. Add one line to `services/api/CLAUDE.md` that **contradicts** the root file.
   For example, the root says to test with `pnpm --filter <pkg> test`; add:

   ```text
   - Run the tests with `pytest -q` from this directory.
   ```

3. **Before trying**, write on paper which instruction you expect the agent to
   follow, and why.
4. Check it, twice, from two starting points:

   ```bash
   cd services/api && claude -p "How do I run the tests for this package? Reply with the command only."
   cd ../.. && claude -p "How do I run the tests for services/api? Reply with the command only."
   ```

   Run each one two or three times. Compare with your prediction. Starting
   inside a package loads that package's file plus every ancestor; starting at
   the root loads the root file, and the nested one only arrives when the agent
   reads files there. Whatever you saw, ask yourself whether you could rely on
   it.

## d) Ask for something that breaks the definition of done

1. Still in `code/ch04`, start `claude` and ask for a change followed by an
   immediate "done", for example:

   ```text
   Add a one-line comment at the top of services/api/CLAUDE.md, then tell me
   the task is done. Do not run any checks.
   ```

2. Watch what it does. Does it run the definition of done? Does it load the
   `verify-done` skill? Does it say "done" anyway?

At this level the agent can still ignore the contract. That is not a failure of
the lab, it is the observation the lab exists to produce: [Lab 4](lab-4.md)
adds the layer that does not depend on the agent agreeing.

## Done when

- You have a line count for your trimmed file (target 30 to 45).
- Your contract has a definition of done with a holder next to each criterion,
  and a `verify-done` skill that matches it.
- You wrote a prediction for the nested contradiction before testing it.
- You saw with your own eyes what the agent did with an instruction to skip
  the checks.

## Reset

```bash
cd "$(git rev-parse --show-toplevel)"
git checkout -- kit/lab2 code/ch04
git clean -fd kit/lab2 code/ch04
```
