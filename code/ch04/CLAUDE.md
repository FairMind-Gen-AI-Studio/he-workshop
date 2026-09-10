# Fairmind Studio

Monorepo: apps/studio (Next.js), services/api (FastAPI), packages/shared.
Run commands from the package directory, never from the root.

## Commands
- Test one package: `pnpm --filter <pkg> test` (the root `pnpm test`
  runs everything and takes about twenty minutes)
- Type check before every commit: `pnpm --filter <pkg> typecheck`

## Conventions
- Database access goes through the repository layer in `services/api/repos/`.
  Never write raw SQL in a route handler.
- Errors returned to the client use the envelope in `packages/shared/errors.ts`.

## Workflow
- Every task starts from a ticket and the branch is named for it.
- Local and staging testing: the path-scoped rule in
  `.claude/rules/testing.md` carries the procedure.

## Definition of done
- Tests pass: `pnpm --filter <pkg> test`
- Types check: `pnpm --filter <pkg> typecheck`
- Lint is clean: `pnpm --filter <pkg> lint`
- Review agents in CI have posted and their comments are addressed
  (the scheduled checks this chapter opened with wait for them)
- The ticket is updated (held by the Stop hook, not by this file)
- Reviewed by a human before merge (ours to do, not the agent's)
