# Lessons

Rules distilled from past mistakes. Each entry is a correction that already cost time once.

## Verify by executing, not by reasoning

Before calling a launch path, import path, or code path broken, run it. Reasoning about
`sys.path` rules in the abstract produced a confident wrong claim once: an editable install
(`uv sync`) puts the project root on `sys.path` regardless of how the script is launched, so
`python src/pkg/mod.py` worked fine. Prefer `python -m pkg.mod` for robustness, but sell it as
robustness, not as a bug fix.

The same rule catches worse bugs. A Seq2Point model had conv paddings that shrank the sequence
599 → 596 and crashed the FC layer on any forward pass. It survived four sessions and a dedicated
bug audit, because code review checks plausibility, not executability, and nothing ever ran it.
For every model or pipeline, run a one-batch end-to-end smoke test before calling it implemented.

## Check data against physical plausibility before using it

PV "power" peaked at 157 MW at 03:47 AM. Romanian-locale exports use comma decimals, and the
conversion to xlsx dropped them for values ≥ 1, so `6.965662` became `6965662`. Check range and
time-of-day profile before trusting loaded data. When repairing, validate candidate
interpretations against signal smoothness - consecutive 1-second samples must vary smoothly.

## Satisfy type checkers idiomatically, not with suppressions

Code shared with a supervisor or reviewer must read as professional. Prefer the rewrite that
satisfies the checker (`df.loc[date]` over boolean index filtering, an explicit `pd.Timestamp()`
cast) over sprinkling `# type: ignore`. Use the suppression only when the stubs are genuinely
wrong. Squash fixup commits before moving on.

## Never combine pkill with the restart it targets

`pkill -f "pattern" && python script_matching_pattern.py` as a single background command kills
itself (exit 144) - `pkill -f` matches full command strings, including the wrapping shell's own.
Run the kill and the restart as separate calls, or use a pattern that cannot appear in the new
command line.

## uv `[tool.uv.sources]` only binds direct dependencies

A project pinned `torch = { index = "pytorch-cpu" }` and the lock still resolved torch from PyPI
with 15 `nvidia-*-cu12` packages, because torch was transitive via sentence-transformers. To force
a transitive package to a specific index, declare it directly in `[project] dependencies` (or the
relevant extra) alongside the source mapping. Verify with `grep -c 'name = "nvidia-' uv.lock`
returning 0 - not by re-reading the config.
