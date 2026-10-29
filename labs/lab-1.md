# Lab 1: Diagnose a harness

**Time:** 20 minutes · **Where:** your own file · **Sheet:** [`kit/matrix-5x4.md`](../kit/matrix-5x4.md)
· **You need:** your [Exercise 1](exercise-1.md) sheet

**Goal:** fill in one row of the 5x4 matrix completely and find the three
empty cells that cost you the most.

The matrix has five components on the rows (system prompt and context, tools
and descriptions, infrastructure, orchestration, hooks and middleware) and four
roles on the columns:

| Column | The question |
|---|---|
| Guide | What raises the odds of a good first attempt |
| Sensor | What notices a bad attempt |
| Boundary | What the agent cannot do even if it tries |
| Record | What survives the session as evidence |

You fill in **one row**, not twenty cells. In twenty minutes one row done well
is worth more than twenty sketched cells.

## Steps

1. Copy `kit/matrix-5x4.md` into a file of your own, next to your Exercise 1
   answers, or draw five rows and four columns on paper. It takes a minute.
2. **Choose the row.** Take the failure from Exercise 1 and pick the row where
   it lives. If the agent reads the wrong thing, it is probably context; if it
   runs something it should not, probably tools or infrastructure; if nothing
   stopped it at the end of the session, probably hooks.
3. **Fill in its four cells.** For each column, write the artifacts your
   harness has today in that row. Deliberate artifacts only: a file you wrote,
   a rule you set, a hook you registered. Runtime defaults do not count.
   If you have your own repository at hand, use it instead of guessing from
   memory.
4. **Mark each entry comp or inf.** `comp` if its outcome is deterministic
   (a permission rule, a hook that exits with a code), `inf` if it depends on
   the model's judgment (an instruction in CLAUDE.md, a skill description).
   This tells you what you can trust under pressure.
5. **Name the cells left empty.** For each empty cell, write whether it is
   empty by **decision** or by **accident**. Write it down, do not just think
   it.
6. **Order three empty cells by risk.** At the bottom of the sheet write three
   lines, one per empty cell: which cell, the failure it would have caught,
   what that failure costs. Put the most expensive first. "By risk" means the
   cost of what gets through while the cell is empty, not how empty the cell
   is: an empty Record column on a two-person prototype costs little, the same
   column on a production system costs an incident nobody can reconstruct.

## Done when

- One row has all four cells filled or explicitly named as empty.
- Every entry carries `comp` or `inf`.
- Three empty cells are listed, most expensive first, each with its failure
  and its cost.

## A worked example

Fill in your own row before reading this. It is one possible answer, for the
failure used as an example in Exercise 1: "it declares an endpoint done when
it mocked the response". Nothing stopped it at the end of the session, so the
row is **hooks and middleware**.

| Guide | Sensor | Boundary | Record |
|---|---|---|---|
| Empty, by decision: the definition of done lives in CLAUDE.md, the context row | `Stop` hook runs `pnpm test` (comp). It passes: the unit tests run against the same mock | Empty, by accident | Empty, by accident |

The sensor is filled and still misses the failure. That is worth writing down:
a cell with an artifact in it is not a cell that covers your failure.

The three empty cells, most expensive first:

1. **Boundary.** Would have caught: a mock written into endpoint code outside
   `test/`, refused by a `PreToolUse` hook on `Edit`. Cost: the mock reaches
   staging and a day of QA goes into a feature that never worked.
2. **Record.** Would have caught: which checks actually ran before "done".
   Cost: every review re-runs everything by hand, and review becomes the
   bottleneck.
3. **Guide.** Would have caught: little the contract does not already say.
   Cost: low, which is why it is empty by decision.

## Keep the sheet

You pick it up again at the [closing](closing.md), to see which cells the day filled and
which you now know how to fill.
