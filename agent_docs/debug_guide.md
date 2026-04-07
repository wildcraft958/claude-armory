# Debug Guide

Reference guide for debugging across the stack. Read this when diagnosing errors.

## Python / FastAPI

### Common errors
- **ImportError / ModuleNotFoundError**: Check virtual env is active. Check `pyproject.toml` dependencies. Run `pip install -e .` for local packages.
- **Pydantic ValidationError**: Print `model.model_json_schema()` to see expected shape. Check field types and required vs optional.
- **422 Unprocessable Entity (FastAPI)**: Request body doesn't match the Pydantic model. Check field names (camelCase vs snake_case), types, and required fields.
- **SQLAlchemy / asyncpg errors**: Check connection string. Check that `await` is used with async sessions. Check that models match the actual DB schema.

### Debugging approach
1. Reproduce with the smallest possible input.
2. Add `import pdb; pdb.set_trace()` or use `breakpoint()` at the failure point.
3. For async code, use `import asyncio; asyncio.run(debug_function())` in a scratch script.
4. Check logs: FastAPI uses `uvicorn` logging. Set `--log-level debug` for verbose output.

## LangGraph

### Common errors
- **RecursionError / recursion_limit reached**: Agent is looping. Check tool output -- the LLM may not be getting useful responses. Add a fallback or increase the limit.
- **InvalidUpdateError**: A node is returning state that doesn't match the schema. Check TypedDict fields.
- **ToolException**: Tool raised an unhandled error. Wrap tool logic in try/except and return error as string.
- **Checkpointer errors**: For PostgresSaver, check connection pool limits and that the checkpointer table exists.

### Debugging approach
1. Use `graph.get_state(thread_id)` to inspect state at any point.
2. Use `graph.stream(input, config, stream_mode="debug")` to see every node execution.
3. Test tools individually before testing the full graph.
4. Check the prompt -- most agent failures are prompt failures, not code failures.

## React / Next.js

### Common errors
- **Hydration mismatch**: Server and client render different HTML. Check for `typeof window` checks, random values, or Date.now() in render.
- **"Cannot read properties of undefined"**: Data isn't loaded yet. Add loading states. Check that API responses match expected shape.
- **CORS errors**: Backend needs to set `Access-Control-Allow-Origin`. In FastAPI, use `CORSMiddleware`.
- **Build failures (tsc)**: Read the FULL error. Usually a type mismatch or missing import.

### Debugging approach
1. Check browser console AND network tab together.
2. Use React DevTools to inspect component state and props.
3. For state bugs, add `console.log` in the reducer/store, not in the component.

## Supabase

### Common errors
- **RLS policy blocking**: Query returns empty when data exists. Check RLS policies with `supabase.auth.getUser()` to verify the JWT.
- **"relation does not exist"**: Table not created or migration not applied. Run `supabase db push` or check migration status.
- **"permission denied for schema public"**: Missing grants. Check that the `anon` or `authenticated` role has SELECT/INSERT/UPDATE on the table.
- **pgvector errors**: Ensure the `vector` extension is enabled. Check vector dimensions match between index and query.

### Debugging approach
1. Test queries in the Supabase SQL editor first (bypasses RLS when run as postgres).
2. Use `supabase.rpc()` to test functions in isolation.
3. Check the Supabase dashboard logs for detailed error messages.
4. For RLS: temporarily disable with `ALTER TABLE ... DISABLE ROW LEVEL SECURITY;` to confirm RLS is the issue, then re-enable and fix the policy.
