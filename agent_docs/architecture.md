# Architecture Patterns

> **Stack:** FastAPI + React (full-stack Python/TS). Structure principles are broadly applicable; backend-specific sections assume FastAPI.

Reference for project structure and feature scaffolding. Read this when building new features or understanding an unfamiliar project layout.

## Python Backend (FastAPI)

```
project/
  app/
    __init__.py
    main.py              # FastAPI app, middleware, lifespan
    config.py            # Settings via pydantic-settings
    models/              # SQLAlchemy / Pydantic models
    routes/              # API route handlers (one file per resource)
    services/            # Business logic (not in routes)
    repositories/        # Database queries (not in services)
    middleware/           # Auth, logging, error handling
    utils/               # Shared helpers
  agents/                # LangGraph agents (separate from web app)
  migrations/            # Alembic or Supabase migrations
  tests/
    conftest.py          # Shared fixtures
    test_routes/
    test_services/
  pyproject.toml
```

### Key principles
- Routes are thin: validate input, call service, return response.
- Services contain business logic. They don't know about HTTP.
- Repositories handle database access. Services call repositories, not the ORM directly.
- Models are split: SQLAlchemy models for DB, Pydantic models for API request/response.

## Frontend (React / Next.js)

```
src/
  app/                   # Next.js app router pages
  components/
    ui/                  # Generic reusable components (Button, Modal, Input)
    features/            # Feature-specific components (ChatPanel, AgentCard)
  hooks/                 # Custom React hooks
  lib/                   # Utilities, API client, constants
  stores/                # State management (Zustand / context)
  types/                 # TypeScript type definitions
```

### Key principles
- Components are either UI (generic, reusable) or feature (specific, composed from UI).
- Hooks encapsulate stateful logic. If a component has complex state, extract a hook.
- API calls live in `lib/api.ts` or a similar client module, not inside components.
- Types are co-located with the code that uses them unless shared across features.

## Monorepo

```
packages/
  shared/                # Types, utils shared between frontend and backend
  web/                   # Frontend
  api/                   # Backend
  agents/                # LangGraph agents
```

Use workspaces (pnpm/npm) for JS or a `pyproject.toml` with path dependencies for Python.

## Adding a New Feature (checklist)

1. Define the data model (DB schema, API request/response types).
2. Write the migration (if DB changes needed).
3. Write the service layer with tests (TDD).
4. Write the route/endpoint.
5. Wire up the frontend (API call, component, state).
6. Add integration test for the full flow.
7. Run `/ship` before committing.
