Explain the code specified below at four levels of depth. Be precise, not verbose.

## Level 1: TL;DR
One paragraph. What does this code do? What problem does it solve? If someone asked "what's this file for?" give the answer.

## Level 2: How It Works
Walk through the logic step by step. Cover:
- Entry points (what triggers this code)
- Data flow (what goes in, what transformations happen, what comes out)
- Key decisions (conditionals, error handling, branching logic)
- State changes (what gets mutated, stored, or emitted)

Use code references (file:line) for each point.

## Level 3: Connections
How does this code fit into the larger system?
- What calls it? (trace callers using grep or Axon context)
- What does it call? (dependencies, services, utilities)
- What data does it read/write? (database tables, API endpoints, files, caches)
- What would break if this code changed? (downstream consumers, API contracts)

## Level 4: Gotchas
Things that are non-obvious, surprising, or easy to get wrong:
- Implicit assumptions (ordering, uniqueness, timing)
- Error handling gaps
- Performance characteristics (O(n) loops, N+1 queries, memory usage)
- Race conditions or concurrency issues
- Magic numbers or hardcoded values that should be config

If there are no gotchas, say so. Don't invent problems.

$ARGUMENTS
