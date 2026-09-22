# Instructor notes

This branch carries the solutions. It does not exist on `main`, so
participants who clone the repository do not see it unless they look for it.

| File | Lab |
|---|---|
| `lab2-solution.md` | Lab 2, the audit of the bloated CLAUDE.md: what gets cut and why |

## Answers to have ready

**Lab 2 (c), who wins.** There is no reliable winner. The vendor's memory
documentation says that when two rules contradict each other the model may
pick one arbitrarily; the features overview says more specific instructions
typically take precedence. Those are two different claims. The engineering
answer is to stop relying on the outcome: scope the general rule so the
specific case sits outside it. Whoever "guessed right" guessed. Also point out
the starting directory: a session started inside `services/api` loads that
file plus every ancestor, one started at the root loads the nested file only
when the agent reads there.

**Lab 3, reading variant.** The lines are the two checks at the end of
`code/ch05/.devcontainer/init-firewall.sh`: if `https://example.com` is
reachable the script exits 1 with "the policy is not in force"; if
`https://api.github.com/zen` is not reachable it exits 1 with "the allowlist is
wrong". Only then does it print `egress policy in force`. `devcontainer.json`
waits for that `postStartCommand`, so a firewall that did not take effect
never hands over a ready container.

## Things to say before they ask

**Lab 3, step (a).** They try to reopen a deny from a project file and cannot.
Say beforehand that this is the expected behaviour, otherwise they call you
over thinking they made a mistake. Make sure everyone runs the reset at the
end: the floor turns the sandbox on for every project they open.

**Lab 3, step (b).** The time goes into the image build. Start it at the
beginning of the lab and have them read the Dockerfile meanwhile.

**Lab 4.** Never cut it. On step (c) have everyone watch the moment the agent
gets the failing test's output back and resumes on its own. On step (d) have
them run it more than once: the race does not always show.

**Lab 5.** The suite points at `code/ch06-pristine`, not at the Lab 4 copy. If
someone repoints it at `code/ch06` they will see red for their own Lab 4
changes, not for the point of the exercise.

**If you fall behind,** cut from labs 2, 3 and 5. Never from 4.
