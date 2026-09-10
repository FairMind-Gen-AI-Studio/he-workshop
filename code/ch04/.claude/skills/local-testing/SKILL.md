---
name: local-testing
description: Bring up the local stack and run one package's tests. Use when asked to test a change locally.
---

# Local testing

1. Start the stack: `docker compose up -d` from the repository root.
2. Wait until the API answers: `curl -sf localhost:8000/health`.
3. Run the tests for the package that changed:
   `pnpm --filter <pkg> test`.
4. Report failing tests verbatim; do not summarize them away.
