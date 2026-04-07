Write tests for the code specified below. Follow these rules strictly.

## Format: Arrange-Act-Assert

Every test function must have three clearly separated sections:
```
# Arrange -- set up inputs, mocks, fixtures
# Act -- call the function/endpoint under test
# Assert -- verify the output and side effects
```

## Python (pytest)

- Use `pytest` with plain functions, not unittest classes.
- Use `@pytest.fixture` for shared setup. Prefer factory fixtures over complex setup.
- Use `@pytest.mark.parametrize` for testing multiple inputs against the same logic.
- Mock external services (APIs, databases) at the boundary, not deep inside the code.
- For FastAPI: use `TestClient` from `httpx` or `fastapi.testclient`.
- For async code: use `@pytest.mark.asyncio` and `AsyncClient`.
- Name tests: `test_<function>_<scenario>_<expected_result>`

## JavaScript/TypeScript (vitest)

- Use `describe` blocks grouped by function/component.
- Use `it` with descriptive names: `it('returns empty array when no items match')`.
- Use `vi.mock()` for module mocks, `vi.fn()` for function mocks.
- For React: use `@testing-library/react` with `render`, `screen`, `userEvent`.
- For API routes: use `supertest` or direct handler invocation.
- Clean up after each test: `afterEach(() => { vi.restoreAllMocks() })`.

## What to Test

1. Happy path -- the main use case works correctly.
2. Edge cases -- empty inputs, boundary values, null/undefined.
3. Error cases -- invalid inputs throw/return appropriate errors.
4. Integration points -- API calls, database queries, external services (mocked).

## What NOT to Test

- Implementation details (private methods, internal state).
- Third-party library internals.
- Trivial getters/setters with no logic.

$ARGUMENTS
