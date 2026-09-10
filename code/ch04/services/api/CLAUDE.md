# services/api

- New endpoint tests go in `tests/api/`, one file per route,
  using the factories in `tests/factories/`.
- Migrations are append-only. Never edit a file already merged
  to main; add a new one.
