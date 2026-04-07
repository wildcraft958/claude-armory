# API Conventions

Reference for FastAPI routes, auth patterns, and error handling. Read this when building or modifying API endpoints.

## Route Structure

```python
from fastapi import APIRouter, Depends, HTTPException, status

router = APIRouter(prefix="/items", tags=["items"])

@router.get("/", response_model=list[ItemResponse])
async def list_items(
    skip: int = 0,
    limit: int = 20,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    items = await item_service.list_for_user(db, user.id, skip, limit)
    return items

@router.post("/", response_model=ItemResponse, status_code=status.HTTP_201_CREATED)
async def create_item(
    body: ItemCreate,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    item = await item_service.create(db, user.id, body)
    return item
```

## Naming Conventions

- Routes: plural nouns (`/items`, `/users`, `/agents`)
- Actions on resources: use HTTP methods, not verbs in URLs
  - GET `/items` -- list
  - GET `/items/{id}` -- get one
  - POST `/items` -- create
  - PUT `/items/{id}` -- full update
  - PATCH `/items/{id}` -- partial update
  - DELETE `/items/{id}` -- delete
- Non-CRUD actions: POST `/items/{id}/activate`, POST `/agents/{id}/run`

## Auth Patterns

### Supabase JWT
```python
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from supabase import create_client

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
):
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    user = supabase.auth.get_user(credentials.credentials)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    return user.user
```

### Dependency injection for auth levels
```python
# Public route: no auth dependency
# Authenticated route: Depends(get_current_user)
# Admin route: Depends(get_admin_user)  # checks role in JWT claims
```

## Error Response Format

All errors should return a consistent JSON shape:

```json
{
  "detail": "Human-readable error message",
  "code": "MACHINE_READABLE_CODE",
  "field": "field_name"
}
```

### Exception handler
```python
from fastapi import Request
from fastapi.responses import JSONResponse

class AppError(Exception):
    def __init__(self, detail: str, code: str, status_code: int = 400, field: str = None):
        self.detail = detail
        self.code = code
        self.status_code = status_code
        self.field = field

@app.exception_handler(AppError)
async def app_error_handler(request: Request, exc: AppError):
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail, "code": exc.code, "field": exc.field},
    )
```

## Middleware

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # frontend dev server
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Request/Response Models

- **Request models** (`ItemCreate`, `ItemUpdate`): use for input validation. All fields are required unless explicitly Optional.
- **Response models** (`ItemResponse`): use for output serialization. Include `id`, timestamps, computed fields.
- **Never expose** internal IDs, password hashes, or sensitive metadata in response models.
- Use `model_config = ConfigDict(from_attributes=True)` to convert from SQLAlchemy models.
