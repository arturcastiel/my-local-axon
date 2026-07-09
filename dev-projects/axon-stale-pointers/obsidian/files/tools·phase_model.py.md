---
tags: [code, file]
path: tools/phase_model.py
---

# tools/phase_model.py

> 38 symbol(s) · 1 outbound file dependency(ies)

## Symbols
- `All transitive dependents of phase_id (nodes that depend on it, directly or via`
- `Backward cascade-invalidation: mark every transitive dependent `stale`     (pend`
- `Declared outputs for a phase = the manifest per-phase `outputs` field ONLY.`
- `Declared outputs that do NOT exist under project_dir. Glob entries ('*')     req`
- `DepsNotDone`
- `Insert a NEW phase node into the manifest — the custom-phase path that     code-`
- `Load the manifest; seed the default ladder when absent (seed=False -> None).`
- `Mark a phase `done` (explicit DONE-to-advance). Requires (1) its deps `done``
- `Ordered [{id,name,order,status}] for the dashboard + the PR-7 state line.`
- `OutputsMissing`
- `Phase-id ⇄ _meta.phase consistency guard (general-bugfix C1). ok=False when`
- `PhaseError`
- `Resolve a phase token to a manifest id: exact match first, then the     canonica`
- `Set a phase `active`. Requires every dependency to be `done` first     (the in-o`
- `The `phase:` field of {project}/_meta.md (the authoritative current phase).`
- `Write per-phase `outputs` into the manifest so real projects are gated at done()`
- `_by_id()`
- `_default_manifest()`
- `_deps_done()`
- `_descendants()`
- `_meta_phase()`
- `_missing_outputs()`
- `_now()`
- `_path()`
- `_required_outputs()`
- `add()`
- `advance()`
- `check()`
- `done()`
- `load()`
- `main()`
- `normalize()`
- `phase_model.py`
- `render()`
- `save()`
- `seed_outputs()`
- `stale_downstream()`
- `status()`

## Depends on
- [[_unknown_]]
