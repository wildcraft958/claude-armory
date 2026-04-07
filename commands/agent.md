Build a LangGraph agent based on the description below. Follow these patterns.

## Architecture

Use the standard LangGraph ReAct pattern:
1. **State schema** -- Define with TypedDict or Pydantic. Include `messages`, `context`, and any domain-specific fields.
2. **Tools** -- Each tool is a standalone function decorated with `@tool`. Keep tools focused: one action per tool.
3. **Graph** -- Build with `StateGraph`. Use `add_node` for processing steps, `add_edge` for flow.
4. **Checkpointing** -- Use `MemorySaver` for dev, `PostgresSaver` (Supabase) for prod.

## Safety Rails

Every agent must have:
- **Max iterations** -- Set `recursion_limit` on the graph (default: 25).
- **Tool error handling** -- Wrap tool calls in try/except. Return error messages as ToolMessage, don't crash the graph.
- **Input validation** -- Validate user input before passing to the LLM.
- **Output guardrails** -- Check LLM output before executing tool calls (especially for write operations).
- **Human-in-the-loop** -- Use `interrupt_before` on nodes that perform destructive actions (delete, update, send).

## File Structure

```
agents/
  <agent_name>/
    __init__.py
    graph.py       # Graph definition, nodes, edges
    state.py       # State schema
    tools.py       # Tool definitions
    prompts.py     # System prompts, few-shot examples
    config.py      # Model selection, temperature, limits
```

## Patterns

- Use `use context7` to get the latest LangGraph docs before building.
- For RAG: use pgvector via Supabase, not local FAISS.
- For multi-agent: use LangGraph's `Command` to hand off between sub-graphs.
- For streaming: use `.astream_events()` with the v2 API.
- Always add a `langgraph.json` for LangGraph Studio compatibility.

## Testing

- Test each tool in isolation with pytest.
- Test the full graph with a mock LLM (`FakeListChatModel` from langchain_core.language_models.fake).
- Test state transitions by running the graph with `thread_id` and checking intermediate state.

$ARGUMENTS
