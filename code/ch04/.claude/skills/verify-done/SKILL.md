---
name: verify-done
description: Check the definition of done from CLAUDE.md before reporting a task finished. Use before declaring any work complete.
---

# Verify done

Run every machine-checkable criterion from the contract's definition of
done and report one line per criterion.

1. Tests pass: `pnpm --filter <pkg> test`.
2. Types check: `pnpm --filter <pkg> typecheck`.
3. Lint is clean: `pnpm --filter <pkg> lint`.
4. Confirm the ticket state matches the work (the Stop hook sets it;
   verify it happened).
5. Report a short table, one row per criterion, pass or fail. Quote
   failures verbatim; do not summarize them away.
6. Never report the task as done while any row is red. The human review
   row is not yours to check; name it as still open.
