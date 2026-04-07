Compress the file at the path below into caveman-speak to reduce input tokens. Preserve all technical substance, code, URLs, and structure. Overwrite the original file. Save a human-readable backup as `<filename>.original.md`.

## Compression Rules

### Remove
- Articles: a, an, the
- Filler: just, really, basically, actually, simply, essentially, generally
- Pleasantries and hedging: "sure", "happy to", "it might be worth", "you could consider"
- Redundant phrasing: "in order to" → "to", "make sure to" → "ensure"
- Connective fluff: however, furthermore, additionally, in addition

### Preserve EXACTLY — never touch
- Code blocks (fenced ``` and indented)
- Inline code (`backtick content`)
- URLs, file paths, commands
- Technical terms, library names, API names
- Dates, version numbers, numeric values
- Environment variables

### Preserve Structure
- All markdown headings (compress body below, not the heading text)
- Bullet hierarchy and numbered lists
- Tables (compress cell text, keep structure)
- Frontmatter/YAML headers

### Compress prose
- Fragments OK: "Run tests before commit" not "You should always run tests before committing"
- Drop "you should", "make sure to", "remember to" — just state the action
- Short synonyms: "big" not "extensive", "fix" not "implement a solution for"
- Merge redundant bullets that say the same thing differently

## After compressing

Report:
- Original token estimate
- Compressed token estimate
- % saved
- Backup saved at: `<filename>.original.md`

$ARGUMENTS
