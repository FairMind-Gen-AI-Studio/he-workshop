# Lab 2: the solution, for the instructor

`kit/lab2/CLAUDE.md` is 191 lines. Applying the test "can the repository say
it for itself?", about 20 survive.

## What gets cut, and why

| Section | Lines | Verdict |
|---|---|---|
| Welcome preamble | 7 | **Out.** It tells the agent nothing. |
| Project overview | 7 | **Out.** Adjectives. "Production-grade" and "best-in-class" change no decision. |
| Technology stack | 17 | **Out.** It lives in the manifests, with the right versions instead of the ones from six months ago. |
| Repository structure | 62 | **Out.** It is an `ls -R`. The most expensive part of the file and the most useless. |
| Architecture | 14 | **Out.** The agent works it out by reading. And this version already lags behind the code. |
| Key files | 9 | **Out.** Same, and it ages at the first rename. |
| Dependencies | 8 | **Out.** It duplicates the manifests and drifts from them. |
| Development workflow | 14 | **Almost all out.** Ports and docker compose belong in the README. The paragraph on SOLID and variable names is generic advice the model already has. |
| Commands | 9 | **Half stays.** Only the commands with a trap or a choice behind them. |
| Conventions | 11 | **Two lines stay.** The repository layer and the error envelope: no file declares them. The linter enforces the rest. |
| Testing | 3 | **Out.** Deducible. |
| Deployment | 5 | **Out**, unless the agent deploys. |
| Contributing | 4 | **Out.** It is for humans. |

## The lines that survive

The two header lines on the monorepo and on running commands from the package
directory. The two commands with their reason beside them: the test filter,
with the twenty minutes of the root test run, and the typecheck before every
commit. The two conventions no file declares. The workflow tied to the ticket.
And the definition of done, which the bloated file did not have at all.

They are exactly the 32 lines of `code/ch04/CLAUDE.md`.

## The teaching moment

Ask how long they spent deciding on the `Repository structure` section. Almost
nobody cuts it straight away: it looks like the most useful part, and it is
the part measured as useless. It is the heart of module 4.

## Metric to collect

Lines left over lines at the start. The reference contract
(`code/ch04/CLAUDE.md`) has 32 lines. Whoever lands between 30 and 45 has
understood the test. Whoever stays above 80 has cut words instead of
paragraphs.
