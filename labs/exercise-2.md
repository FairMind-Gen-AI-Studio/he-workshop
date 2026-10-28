# Exercise 2: Route a failure

**Time:** 3 minutes · **Where:** whole room, two volunteers
· **Sheet:** [`kit/exercise-2.md`](../kit/exercise-2.md) · **You need:** your
[Exercise 1](exercise-1.md) sheet

**Goal:** route a real failure to the Claude Code primitive that addresses it,
by consequence rather than by content.

## Steps

Answer the two questions **in this order**. The first one does the work.

1. **What does it cost if the agent ignores it?** If the answer is "little", a
   guide is enough: an instruction, a skill. If the answer is "no going back"
   (money, data, production, compliance), you need a boundary.
2. **Which primitive, then?** Name it precisely: contract (CLAUDE.md), skill,
   permission rule, hook, sandbox. The precise name, not the category.

If you are doing this alone, write both answers on `kit/exercise-2.md` before
reading on.

## Check your answer

Most failures that a room routes to an instruction actually want a boundary.
The reflex is understandable: writing a sentence costs thirty seconds, changing
a scope costs a discussion. But a sentence only raises a probability. If the
failure is irreversible, raising a probability is not an answer.

If your answer to question 1 was "no going back" and your answer to question 2
was a line in CLAUDE.md, route it again.

## Two worked examples

| Failure | 1. Cost if ignored | 2. Primitive |
|---|---|---|
| It declares an endpoint done when it mocked the response | Recoverable: caught in review, at the price of a review cycle | A **hook**: a `Stop` hook that runs the integration tests, because a line in CLAUDE.md is what it already ignores. A **skill** (`verify-done`) is enough only if the failure is rare |
| It runs the migration against the production database | No going back: data | A **permission rule** that denies the production credentials, or a **sandbox** with no route to production. Never only a contract line |

The first row shows that a recoverable failure can still want something
stronger than an instruction once the instruction has been tried and ignored.
The second shows the rule: when the cost is "no going back", the answer is a
boundary.
