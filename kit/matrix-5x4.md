# The 5x4 matrix

Print one copy each. You need it in Lab 1 and again at the closing.

Five components on the rows, four roles on the columns. Every deliberate
artifact of your harness sits in one cell. Runtime defaults are not artifacts:
counting them fills the grid and hides the shape the exercise is meant to
reveal.

Next to each entry write **comp** if its outcome is deterministic, **inf** if
it depends on the model's judgment. That tells you which cells you can trust
under pressure.

|                            | Guide | Sensor | Boundary | Record |
|----------------------------|-------|--------|----------|--------|
| System prompt and context  |       |        |          |        |
| Tools and descriptions     |       |        |          |        |
| Infrastructure             |       |        |          |        |
| Orchestration              |       |        |          |        |
| Hooks and middleware       |       |        |          |        |

## The four questions, one per column

| Column | The question |
|---|---|
| Guide | What raises the odds of a good first attempt |
| Sensor | What notices a bad attempt |
| Boundary | What the agent cannot do even if it tries |
| Record | What survives the session as evidence |

## The three empty cells

At the end of Lab 1, hand in three empty cells ordered by risk, most expensive
first. Next to each one write the failure it would have caught and what that
failure costs. "By risk" means the cost of what gets through while the cell is
empty, not how empty the cell is.

1. ________________________________________________________________

2. ________________________________________________________________

3. ________________________________________________________________
