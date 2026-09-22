# Harness Engineering with Claude Code: workshop kit

Classroom material for the workshop. Two exercises and five labs, a sample
repository for each lab, and the sheets to print. Every lab has step-by-step
instructions in [`labs/`](labs/), so you can also do it on your own.

The code accompanies chapters 4 to 7 of *Harness Engineering with Claude Code*
(Packt, Alexio Cassani). It really runs: the Lab 5 suites run against the Lab 4
hooks, not against mock-ups.

## Setup, now

```bash
git clone https://github.com/FairMind-Gen-AI-Studio/he-workshop.git
cd he-workshop
ls code kit
claude --version
```

### Prerequisites

| You need | For |
|---|---|
| `claude` (Claude Code), signed in | Labs 2, 3, 4 |
| `bash`, `git`, `jq` | Labs 3, 4, 5 |
| `pnpm` (`corepack enable` gives you one) | Lab 4 |
| `npx` with `prettier` | Lab 4 |
| `python3` with `pyyaml` | Lab 5 |
| `docker` and `@devcontainers/cli` | Lab 3, optional |

No Docker? Lab 3 has a reading variant, open to anyone whose build fails too.
The container is verified on Docker 28.3 for macOS; elsewhere it is untested
ground.

Quick check:

```bash
for c in claude bash git jq pnpm npx python3 docker devcontainer; do
  printf '%-13s %s\n' "$c" "$(command -v $c || echo MISSING)"
done
python3 -c 'import yaml; print("pyyaml ok")'
```

## The day

| # | Activity | Time | Instructions | Where |
|---|---|---|---|---|
| 1 | Exercise 1: Your plateau | 5' | [labs/exercise-1.md](labs/exercise-1.md) | paper, `kit/exercise-1.md` |
| 2 | Lab 1: Diagnose a harness | 20' | [labs/lab-1.md](labs/lab-1.md) | paper, `kit/matrix-5x4.md` |
| 3 | Exercise 2: Route a failure | 3' | [labs/exercise-2.md](labs/exercise-2.md) | paper, `kit/exercise-2.md` |
| 4 | Lab 2: A contract that changes behavior | 30' | [labs/lab-2.md](labs/lab-2.md) | `kit/lab2/`, `code/ch04/` |
| 5 | Lab 3: Boundaries, as files | 30' | [labs/lab-3.md](labs/lab-3.md) | `code/ch05/` |
| 6 | Lab 4: The enforcement layer | 35' | [labs/lab-4.md](labs/lab-4.md) | `code/ch06/` |
| 7 | Lab 5: Watching the instruments fail | 25' | [labs/lab-5.md](labs/lab-5.md) | `code/ch07/` |

Every lab file has the same shape: goal, numbered steps with the exact
commands, the output to expect, a "done when" checklist and a reset section
that puts the repository back as you found it. Run every command from the
repository root unless the step says otherwise.

## What is inside

| Folder | Lab | What it holds |
|---|---|---|
| `labs/` | all | Step-by-step instructions, one file per activity |
| `kit/` | 1, 2, 3, 4 | The printable sheets, the bloated CLAUDE.md in `kit/lab2/`, the settings merge in `kit/lab3/`, the sibling-hooks snippet in `kit/lab4/` |
| `code/ch04/` | 2 | A real repository contract: CLAUDE.md, rules, three skills, the nested layer in `services/api/` |
| `code/ch05/` | 3 | The personal deny floor, the dev container with an egress firewall, the domain allowlist |
| `code/ch06/` | 4 | Eight hooks: the gate classifier, the contrasting blocklist, the Stop orchestrator, the command log; plus a minimal `pnpm` project for the Stop gate to check |
| `code/ch06-pristine/` | 5 | An intact copy of the above. Do not touch it |
| `code/ch07/` | 5 | The adversarial suite for the hooks and the eval-set scorer |

Every `code/` folder has its own README with a file-by-file map.

**`code/ch06-pristine/` exists for a reason.** The Lab 5 suite sends its
payloads to the Lab 4 `gate-aws-cli.sh`. If it pointed at the copy you just
changed, anyone who broke something in Lab 4 would see a red run that teaches
nothing. It points at the intact copy instead.

## License

The chapter code accompanies the book and is distributed with Packt's
companion repository. The classroom material belongs to FairMind.
