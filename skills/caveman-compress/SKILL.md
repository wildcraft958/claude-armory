---
name: caveman-compress
description: >
  Compress natural language memory files (CLAUDE.md, todos, preferences) into caveman format
  to save input tokens. Preserves all technical substance, code, URLs, and structure.
  Compressed version overwrites the original file. Human-readable backup saved as FILE.original.md.
  Trigger: /caveman-compress <filepath> or "compress memory file"
---

# Caveman Compress

## Purpose

Compress natural language files (CLAUDE.md, todos, preferences) into caveman-speak to reduce input tokens. Compressed version overwrites original. Human-readable backup saved as `<filename>.original.md`.

## Trigger

`/caveman-compress <filepath>` or when user asks to compress a memory file.

## Process

1. Read the target file fully.
2. Apply compression rules below to all natural language prose.
3. Write compressed version back to the original path.
4. Save human-readable backup as `<filename>.original.md`.
5. Report: original token count, compressed token count, % saved.

## Compression Rules

### Remove
- Articles: a, an, the
- Filler: just, really, basically, actually, simply, essentially, generally
- Pleasantries: "sure", "certainly", "of course", "happy to", "I'd recommend"
- Hedging: "it might be worth", "you could consider", "it would be good to"
- Redundant phrasing: "in order to" → "to", "make sure to" → "ensure", "the reason is because" → "because"
- Connective fluff: "however", "furthermore", "additionally", "in addition"

### Preserve EXACTLY (never modify)
- Code blocks (fenced ``` and indented)
- Inline code (`backtick content`)
- URLs and links
- File paths
- Commands (`npm install`, `git commit`, etc.)
- Technical terms (library names, API names, protocols, algorithms)
- Proper nouns (project names, companies)
- Dates, version numbers, numeric values
- Environment variables (`$HOME`, `NODE_ENV`)

### Preserve Structure
- All markdown headings (keep exact heading text, compress body below)
- Bullet point hierarchy
- Numbered lists
- Tables (compress cell text, keep structure)
- Frontmatter/YAML headers

### Compress
- Short synonyms: "big" not "extensive", "fix" not "implement a solution for"
- Fragments OK: "Run tests before commit" not "You should always run tests before committing"
- Drop "you should", "make sure to", "remember to" — just state the action
- Merge redundant bullets that say the same thing differently
- Keep one example where multiple examples show the same pattern

## Example

Before (CLAUDE.md excerpt):
```
When you are asked to plan something, you should make sure to output only the plan.
You should not write any code until the user explicitly tells you to proceed.
For non-trivial features that involve three or more steps or architectural decisions,
you should clarify the implementation details, UX, and tradeoffs before writing any code.
```

After:
```
Plan only when asked. No code until told to proceed. Non-trivial features (3+ steps): clarify impl, UX, tradeoffs first.
```
