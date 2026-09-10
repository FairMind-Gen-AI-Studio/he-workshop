# Fairmind Studio

> Materiale didattico per il Lab 2a. Questo file va tagliato, non copiato.
> Contiene circa 20 righe che valgono e oltre 170 che il repository sa dire da solo.

Welcome to the Fairmind Studio codebase! This document provides a comprehensive
overview of our project architecture, conventions, and development workflow. It
is intended to help both human contributors and AI assistants understand the
structure and purpose of every part of the system. Please read it carefully
before making any changes.

## Project overview

Fairmind Studio is a modern, scalable, production-grade platform built with a
best-in-class technology stack. It follows industry-standard patterns and
leverages a robust monorepo architecture to maximise code reuse and developer
velocity. The project is under active development and the team is committed to
maintaining high standards of code quality throughout.

## Technology stack

- **Frontend**: Next.js 15 with the App Router, React 19, TypeScript 5.6
- **Styling**: Tailwind CSS 4, with design tokens defined in the shared package
- **Backend**: FastAPI 0.115 running on Python 3.12
- **Database**: PostgreSQL 16, accessed through SQLAlchemy 2.0
- **Migrations**: Alembic
- **Cache**: Redis 7
- **Queue**: Celery with Redis as the broker
- **Package manager**: pnpm 9 with workspaces
- **Testing**: Vitest for the frontend, pytest for the backend
- **Linting**: ESLint 9 with the flat config, Ruff for Python
- **Formatting**: Prettier 3, Ruff format
- **Type checking**: tsc for TypeScript, mypy for Python
- **CI**: GitHub Actions
- **Containerisation**: Docker and Docker Compose
- **Orchestration**: Kubernetes with FluxCD
- **Observability**: OpenTelemetry, Grafana, Loki

## Repository structure

```
.
├── apps/
│   └── studio/                  # The Next.js frontend application
│       ├── app/                 # App Router pages and layouts
│       │   ├── (auth)/          # Authenticated route group
│       │   │   ├── dashboard/   # The main dashboard page
│       │   │   ├── projects/    # Project list and detail pages
│       │   │   ├── sessions/    # Work session pages
│       │   │   └── settings/    # User and workspace settings
│       │   ├── (public)/        # Public route group
│       │   │   ├── login/       # Login page
│       │   │   └── signup/      # Signup page
│       │   ├── api/             # Route handlers
│       │   ├── layout.tsx       # Root layout
│       │   └── page.tsx         # Landing page
│       ├── components/          # React components
│       │   ├── ui/              # Primitive UI components
│       │   ├── forms/           # Form components
│       │   └── charts/          # Chart components
│       ├── hooks/               # Custom React hooks
│       ├── lib/                 # Frontend utilities
│       ├── public/              # Static assets
│       ├── next.config.ts       # Next.js configuration
│       ├── tailwind.config.ts   # Tailwind configuration
│       ├── tsconfig.json        # TypeScript configuration
│       └── package.json         # Frontend dependencies
├── services/
│   └── api/                     # The FastAPI backend service
│       ├── routers/             # API route handlers
│       │   ├── auth.py          # Authentication endpoints
│       │   ├── projects.py      # Project endpoints
│       │   ├── sessions.py      # Session endpoints
│       │   └── users.py         # User endpoints
│       ├── repos/               # Repository layer
│       ├── models/              # SQLAlchemy models
│       ├── schemas/             # Pydantic schemas
│       ├── services/            # Business logic
│       ├── migrations/          # Alembic migrations
│       ├── tests/               # Backend tests
│       ├── main.py              # Application entry point
│       └── pyproject.toml       # Backend dependencies
├── packages/
│   └── shared/                  # Shared TypeScript package
│       ├── src/
│       │   ├── errors.ts        # Error envelope definitions
│       │   ├── types.ts         # Shared type definitions
│       │   └── index.ts         # Package entry point
│       └── package.json
├── infra/                       # Infrastructure as code
├── docs/                        # Documentation
├── .github/workflows/           # CI pipelines
├── docker-compose.yml           # Local development stack
├── pnpm-workspace.yaml          # Workspace definition
└── package.json                 # Root package manifest
```

## Architecture

The system follows a layered architecture. Requests arrive at the Next.js
frontend, which either renders server-side or calls the FastAPI backend over
HTTP. The backend is organised in layers: routers handle HTTP concerns,
services hold business logic, and repositories handle data access. Models
define the database schema, and schemas define the API contract. This
separation of concerns makes the system easier to test and to reason about.

The frontend follows a component-driven architecture. Primitive components live
in `components/ui`, composed components in `components/forms` and
`components/charts`, and page-level composition happens in the App Router
directory. Data fetching uses React Server Components where possible, falling
back to client-side fetching where interactivity is required.

## Key files and their purpose

- `apps/studio/app/layout.tsx` — the root layout, sets up providers and fonts
- `apps/studio/app/page.tsx` — the landing page
- `apps/studio/lib/api-client.ts` — the typed API client
- `apps/studio/hooks/use-session.ts` — session state hook
- `services/api/main.py` — creates the FastAPI app and mounts the routers
- `services/api/routers/auth.py` — login, logout, token refresh
- `services/api/repos/base.py` — the base repository class
- `services/api/models/user.py` — the User model
- `packages/shared/src/errors.ts` — the error envelope every endpoint returns

## Dependencies

The frontend depends on next, react, react-dom, typescript, tailwindcss,
@tanstack/react-query, zod, react-hook-form, recharts, lucide-react, clsx and
tailwind-merge. The backend depends on fastapi, uvicorn, sqlalchemy, alembic,
pydantic, pydantic-settings, asyncpg, redis, celery, python-jose, passlib and
httpx. Development dependencies include vitest, @testing-library/react,
playwright, pytest, pytest-asyncio, ruff, mypy, eslint and prettier.

## Development workflow

To get started, clone the repository and install dependencies with pnpm
install. Then start the local stack with docker compose up. The frontend runs
on port 3000 and the backend on port 8000. Migrations run automatically on
startup in development.

Always write clean, maintainable, well-documented code. Follow SOLID
principles. Prefer composition over inheritance. Keep functions small and
focused on a single responsibility. Write meaningful variable names. Add
comments where the intent is not obvious from the code. Handle errors
gracefully. Never leave commented-out code in a commit.

Make sure to write tests for new functionality. Aim for high test coverage.
Test the happy path and the edge cases. Use descriptive test names.

Be careful with database migrations. Always review them before applying.

## Commands

- Install: `pnpm install`
- Develop: `pnpm dev`
- Build: `pnpm build`
- Test: `pnpm test`
- Lint: `pnpm lint`
- Format: `pnpm format`
- Type check: `pnpm typecheck`
- Migrate: `alembic upgrade head`

## Conventions

- Use TypeScript everywhere on the frontend
- Use type hints everywhere on the backend
- Components are PascalCase, hooks are camelCase with a use prefix
- Python modules are snake_case
- Database access goes through the repository layer in `services/api/repos/`.
  Never write raw SQL in a route handler.
- Errors returned to the client use the envelope in
  `packages/shared/errors.ts`.
- Prefer named exports over default exports
- Keep imports sorted
- Use absolute imports with the configured path aliases

## Testing

Tests live next to the code they test on the frontend and in `services/api/tests`
on the backend. Run the whole suite before opening a pull request.

## Deployment

Deployment happens through FluxCD. Merging to main triggers the CI pipeline,
which builds the images, pushes them to the registry and updates the manifests.
The cluster reconciles within a few minutes.

## Contributing

Please open a pull request with a clear description of the change. Link the
relevant ticket. Make sure CI is green. Request review from a team member.
