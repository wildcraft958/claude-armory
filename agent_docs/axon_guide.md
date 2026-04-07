# Axon Code Intelligence Guide

Full reference for using Axon MCP tools for code analysis. Read this before refactors, renames, or blast-radius analysis.

## When to Use Axon (Instead of grep)

Use Axon when you need to understand code relationships, not just text matches:
- "What calls this function?" -- `axon context`
- "What would break if I change this?" -- `axon impact`
- "Is this code used anywhere?" -- `axon dead-code`
- "Show me everything related to authentication" -- `axon query`
- "What are the dependency cycles?" -- `axon cycles`

## Tools Reference

### axon context
Get the full picture of a symbol: callers, callees, type references, and the processes it participates in.

**Use before**: modifying any function or class. Especially important for shared utilities and base classes.

```
axon context <symbol_name>
```

### axon impact
Analyze the blast radius of changing a symbol. Shows all direct and transitive dependents.

**Use before**: editing any widely-used function, changing a function signature, renaming, or deleting.

```
axon impact <symbol_name>
```

### axon dead-code
Find symbols that are defined but never referenced anywhere in the codebase.

**Use before**: cleanup refactors. Remove dead code before restructuring to reduce noise.

```
axon dead-code
axon dead-code --file src/utils.py
```

### axon query
Process-grouped hybrid search across the knowledge graph. Combines text search with structural understanding.

**Use for**: finding all code related to a concept (e.g., "authentication", "payment processing").

```
axon query "authentication flow"
```

### axon cypher
Run raw Cypher queries against the code knowledge graph for advanced analysis.

**Use for**: custom structural queries that the other tools don't cover.

```
axon cypher "MATCH (f:Function)-[:CALLS]->(g:Function) WHERE g.name = 'validate' RETURN f.name, f.file"
```

### axon cycles
Detect dependency cycles in the codebase.

**Use for**: understanding circular dependencies before refactoring module structure.

```
axon cycles
```

### axon coupling
Analyze coupling between modules or files.

```
axon coupling
```

### axon communities
Find clusters of tightly coupled code (communities in the dependency graph).

```
axon communities
```

## Session Management

### Initial analysis
Run at the start of every session in a git repo:
```bash
axon analyze --no-embeddings
```

### Keeping the index fresh
For long sessions where you're editing files:
```bash
axon watch  # runs in background, re-indexes on file changes
```

### Checking structural changes before merge
```bash
axon diff main..feature-branch
```

## Workflow Integration

1. **Before a refactor**: Run `axon dead-code` to clean up first. Then `axon impact` on the target symbol.
2. **Before a rename**: Run `axon context` to find all references. Then rename. Then verify with `axon context` again.
3. **Before merging**: Run `axon diff main..branch` to review structural changes.
4. **During code review**: Run `axon coupling` and `axon communities` to check if the changes improve or worsen modularity.
