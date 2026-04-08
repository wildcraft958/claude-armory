# Database Patterns (Supabase)

> **Stack:** Supabase + pgvector (PostgreSQL). Skip this doc for projects using SQLite, MongoDB, Prisma, or non-Supabase Postgres.

Reference for Supabase queries, RLS policies, migrations, and pgvector. Read this when working with the database layer.

## Supabase Client Setup

### Python
```python
from supabase import create_client, Client
import os

supabase: Client = create_client(
    os.environ["SUPABASE_URL"],
    os.environ["SUPABASE_SERVICE_ROLE_KEY"],  # server-side only
)
```

### JavaScript
```typescript
import { createClient } from '@supabase/supabase-js'

// Browser (uses anon key, RLS enforced)
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

// Server (uses service role, bypasses RLS)
const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
```

## Common Queries

```python
# Select with filter
data = supabase.table("items").select("*").eq("user_id", user_id).execute()

# Insert
data = supabase.table("items").insert({"name": "test", "user_id": user_id}).execute()

# Update
data = supabase.table("items").update({"name": "updated"}).eq("id", item_id).execute()

# Delete
data = supabase.table("items").delete().eq("id", item_id).execute()

# Join (foreign key)
data = supabase.table("items").select("*, category:categories(name)").execute()

# Full-text search
data = supabase.table("items").select("*").textSearch("name", "search query").execute()

# Pagination
data = supabase.table("items").select("*", count="exact").range(0, 9).execute()
# data.count gives total, data.data gives page
```

## RLS Policies

### Pattern: users can only access their own data
```sql
-- Enable RLS
ALTER TABLE items ENABLE ROW LEVEL SECURITY;

-- Select: users see only their rows
CREATE POLICY "Users can view own items" ON items
  FOR SELECT USING (auth.uid() = user_id);

-- Insert: users can only insert for themselves
CREATE POLICY "Users can insert own items" ON items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Update: users can only update their rows
CREATE POLICY "Users can update own items" ON items
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Delete: users can only delete their rows
CREATE POLICY "Users can delete own items" ON items
  FOR DELETE USING (auth.uid() = user_id);
```

### Pattern: public read, authenticated write
```sql
CREATE POLICY "Anyone can view" ON posts
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert" ON posts
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

### Pattern: role-based access
```sql
CREATE POLICY "Admins can do anything" ON items
  FOR ALL USING (
    auth.jwt() ->> 'role' = 'admin'
  );
```

## Migrations

### Using Supabase CLI
```bash
# Create a new migration
supabase migration new add_items_table

# Apply migrations locally
supabase db push

# Check migration status
supabase migration list

# Reset local DB (destructive)
supabase db reset
```

### Migration file format
```sql
-- supabase/migrations/20240101000000_add_items_table.sql

CREATE TABLE items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Always enable RLS on new tables
ALTER TABLE items ENABLE ROW LEVEL SECURITY;

-- Add updated_at trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON items
  FOR EACH ROW EXECUTE FUNCTION moddatetime(updated_at);
```

## pgvector

### Setup
```sql
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE embeddings (
  id BIGSERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  embedding VECTOR(1536)
);

CREATE INDEX ON embeddings USING hnsw (embedding vector_cosine_ops);
```

### Similarity search function
```sql
CREATE FUNCTION match_embeddings(
  query_embedding VECTOR(1536),
  match_threshold FLOAT DEFAULT 0.7,
  match_count INT DEFAULT 5
) RETURNS TABLE (id BIGINT, content TEXT, metadata JSONB, similarity FLOAT)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
  SELECT e.id, e.content, e.metadata,
    1 - (e.embedding <=> query_embedding) AS similarity
  FROM embeddings e
  WHERE 1 - (e.embedding <=> query_embedding) > match_threshold
  ORDER BY e.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;
```

## Performance Tips

- Always add indexes for columns used in WHERE clauses and JOINs.
- Use `select("col1, col2")` instead of `select("*")` for large tables.
- Use `count="exact"` only when you need the total count (adds overhead).
- For bulk inserts, use `upsert()` with `on_conflict` to handle duplicates.
- Connection pooling: use Supavisor (built into Supabase) for serverless/edge functions.
