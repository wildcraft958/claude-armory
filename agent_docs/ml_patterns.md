# ML & AI Patterns

Reference for LangGraph agents, model loading, RAG pipelines, and embeddings. Read this when building AI features.

## LangGraph Agent Patterns

### Basic ReAct Agent
```python
from langgraph.graph import StateGraph, START, END
from langgraph.prebuilt import ToolNode
from langchain_core.messages import HumanMessage

def agent_node(state):
    response = model.invoke(state["messages"])
    return {"messages": [response]}

def should_continue(state):
    last = state["messages"][-1]
    if last.tool_calls:
        return "tools"
    return END

graph = StateGraph(State)
graph.add_node("agent", agent_node)
graph.add_node("tools", ToolNode(tools))
graph.add_edge(START, "agent")
graph.add_conditional_edges("agent", should_continue)
graph.add_edge("tools", "agent")
```

### Multi-Agent with Command
```python
from langgraph.types import Command

def supervisor(state):
    # Decide which agent to route to
    decision = llm.invoke(...)
    return Command(goto=decision.agent, update={"task": decision.task})
```

### Human-in-the-Loop
```python
graph.add_node("dangerous_action", action_node)
# This pauses execution and waits for human approval
compiled = graph.compile(interrupt_before=["dangerous_action"])
```

### Checkpointing
- Dev: `from langgraph.checkpoint.memory import MemorySaver`
- Prod: `from langgraph.checkpoint.postgres.aio import AsyncPostgresSaver`
- Always pass `{"configurable": {"thread_id": "..."}}` to maintain conversation state.

## RAG with pgvector (Supabase)

### Setup
```sql
-- Enable the extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create embeddings table
CREATE TABLE documents (
  id BIGSERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  embedding VECTOR(1536)  -- dimension must match your model
);

-- Create HNSW index for fast similarity search
CREATE INDEX ON documents USING hnsw (embedding vector_cosine_ops);
```

### Embedding + Search
```python
from langchain_openai import OpenAIEmbeddings
from supabase import create_client

embeddings = OpenAIEmbeddings(model="text-embedding-3-small")

# Store
vector = await embeddings.aembed_query(text)
supabase.table("documents").insert({"content": text, "embedding": vector}).execute()

# Search
query_vector = await embeddings.aembed_query(query)
results = supabase.rpc("match_documents", {
    "query_embedding": query_vector,
    "match_threshold": 0.7,
    "match_count": 5
}).execute()
```

### Supabase match function
```sql
CREATE FUNCTION match_documents(
  query_embedding VECTOR(1536),
  match_threshold FLOAT,
  match_count INT
) RETURNS TABLE (id BIGINT, content TEXT, metadata JSONB, similarity FLOAT)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
  SELECT d.id, d.content, d.metadata,
    1 - (d.embedding <=> query_embedding) AS similarity
  FROM documents d
  WHERE 1 - (d.embedding <=> query_embedding) > match_threshold
  ORDER BY d.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;
```

## Model Loading

### LangChain model selection
```python
# OpenAI
from langchain_openai import ChatOpenAI
model = ChatOpenAI(model="gpt-4o", temperature=0)

# Anthropic
from langchain_anthropic import ChatAnthropic
model = ChatAnthropic(model="claude-sonnet-4-20250514", temperature=0)

# Local (Ollama)
from langchain_ollama import ChatOllama
model = ChatOllama(model="llama3.1")
```

### Structured output
```python
from pydantic import BaseModel

class Answer(BaseModel):
    reasoning: str
    answer: str
    confidence: float

structured_llm = model.with_structured_output(Answer)
result = structured_llm.invoke("What is 2+2?")
# result is an Answer instance
```

## Evaluation

- Use `langsmith` for tracing and evaluation in production.
- For offline eval: create a dataset of (input, expected_output) pairs and run the agent against it.
- Key metrics: accuracy, latency (p50/p95), token usage, tool call success rate.
