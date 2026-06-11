# PR-8 — real dry-run mechanism [crit C8]

Status: merged
Merged: → main (squash) · crucible green 28 controls · zero warnings
Branch: general-bugfix/pr-8-real-dry-run → main
Depends-on: PR-7 (merged) · code_graph (exists)
Phase: 3-prs
Covers: C8 (whatif promises "no writes" but dry-running divide/combine/merge wrote for real)

## Design pivot (evidence-driven, documented)
The locked sketch assumed tool-mediated writes (code_graph reachability over Python fns).
Study showed the whatif mutators mutate via AGENT-side library ops (MKDIR/COPY-*/WRITE) —
so the enforceable contract splits in two:

## Change
- **Substrate half** (`_axon_io`): a TTL-guarded flag file
  (`workspace/memory/working/dry-run.flag`, 15 min) makes `atomic_write` AND
  `atomic_append_line` RECORD the intended write to a jsonl manifest and skip the
  disk op. The flag crosses the agent→subprocess boundary where W: keys cannot;
  a stale flag (crashed whatif) is ignored LOUDLY, never silently swallowing writes.
- **Program half** (`tools/dry_run_lint.py`, crucible **BLOCK**): every
  whatif-reachable mutator must check `W:code-dev-dry-run` BEFORE its first mutating
  library op. Baseline at wire time: divide/combine/merge all unguarded (the audit's
  claim, confirmed mechanically) — all three now carry the canonical render-plan guard;
  partition has no direct mutating ops.
- **whatif.md**: arms BOTH carriers (W: key + substrate flag), and at the end renders
  the manifest — the dry run now produces the "what would have happened" report the
  command always promised.
- **Tests** (`tests/test_dry_run.py`, 5): record-and-skip · stale-flag-loud ·
  no-flag-normal · all-mutators-guarded invariant · guard-precedes-mutation negative.

## Guarded-by
- `dry-run-lint` (BLOCK, 28th control) + the substrate locks.
- Full gate green, zero warnings.
