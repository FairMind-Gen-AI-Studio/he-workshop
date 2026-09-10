---
paths:
  - "apps/**"
  - "services/**"
  - "packages/**"
---

# Testing locally and on staging

- Local: bring the stack up with `docker compose up -d` from the repository
  root, then run the changed package's tests with `pnpm --filter <pkg> test`.
  The `/local-testing` skill carries the full procedure.
- Staging: never test against staging from a feature branch without a ticket;
  the deploy workflow owns staging state.
