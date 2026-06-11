# PR-7 — output_manifest + accessor-side conformance (heavy guard, BLOCK)

Status: merged
Merged: → main (squash) · crucible green 27 controls · zero warnings
Branch: general-bugfix/pr-7-output-manifest → main
Depends-on: PR-1, PR-5, PR-6 (all merged)
Phase: 3-prs
Covers: the dead-accessor class repo-wide (the .value/.candidates/.fresh family)

## Goal
The flag side (PR-0b/1/6) proves a call PARSES; nothing proved the program reads keys the
tool actually EMITS — the class behind C2 (.value vs .result), the synapse-suggest shape,
and shadow's fresh. This PR closes the read side mechanically.

## Change
- **`tools/output_manifest.json`** — per-(tool, sub) stdout keys for the 11 pairs the
  scoped families consume (clock, predicate eval, todo list, library terms/intersect/
  partition/cite, workflow-runner list/validate-draft/advance/promote). Every key was
  verified against the real tool before pinning.
- **Accessor extraction** in `program_tool_conformance`: inline `TOOL(a,b,…).key` PLUS
  the variable-flow form (`v ← TOOL(a,b,…)` … `v.key`, same-file, conservative —
  non-tool reassignment drops tracking). 20 reads found in the scoped families.
- **Lint pass**: a read against a MANIFESTED pair must name an emitted key →
  `unknown-accessor` violation; unmanifested pairs SKIP (grow the manifest, never
  guess). Rides the existing BLOCK control — 0 violations at wire time (Waves 1–2
  already cleaned the instances; this pins the class).
- **Tripwires** (`tests/test_output_manifest.py`): each read-only manifested pair probed
  LIVE — manifest keys ⊆ actually-emitted keys (the manifest may never promise a key the
  tool doesn't emit). Negative lock: the C2 `.value` read is now mechanically
  unrepresentable.

## Guarded-by
- The BLOCK conformance control (flag + accessor sides, one cmd).
- 7 tripwire/negative tests. Full gate green, zero warnings.
