# PR-W1 — adopt the nested-workflow anti-skip runner (with the 6 robustness fixes)

- **Status:** in-progress (W3 merged !142; M3/M4/M5/M6 applied; 33 anti-skip + 440 workflow-sweep green)
- **Phase:** 2-harmonize  ·  **Complexity:** L  ·  **dev-mode:** no (tools/ + workspace/programs/ + schema + tests/)  ·  **Depends on:** W3 (clean workflows)
- **Source:** MR !141's `tools/workflow_run.py` (+573, clean additive extension) — the anti-skip teeth. Bring it,
  but FIX the 6 robustness holes the deep-study (02-mcd-deepstudy.md) found; otherwise the teeth aren't real.

## Bring (cherry-pick from review/mcd-141)
- `tools/workflow_run.py` — SubWorkflowNotCompletedError + advance() refusal + helpers (terminals,
  workflow_names, sub_workflow_for_synapse, _sub_traj_run_id, sub_workflow_completed, the loaders) + the lint
  FUNCTIONS (check_stale/check_templating/explain/validate_draft come in the same file — wired into a gate in W2).
- `workspace/schemas/workflow-file.schema.json` — the additive `sub-workflow` synapse property.
- `workspace/programs/workflow-run.md` — `--parent-run-id`/`--parent-node` paired-arg validation + sub-workflow
  dispatch + HELP block (G/H). (NOT the loop — single-entry only here.)
- `tests/test_nested_workflow.py`, `test_workflow_run_g.py`, `test_workflow_run_help_h.py`.

## Fix while adopting — W1 takes the 4 clean, single-entry-relevant holes (verified against the review code)
- **M6 sheath** (`advance`, BEFORE the `if parent_run_id is not None:` block) — when `byid[cursor_id]` has an
  EXPLICIT `sub-workflow:` and `parent_run_id is None`, RAISE. Can't sheath an explicit sub-workflow by omitting
  the flag (author caveat 5).
- **M5 implicit-off** (`advance`: `reg = registry if registry is not None else workflow_names(workspace)`) →
  default to `set()` (explicit-only); implicit name-match becomes opt-in (pass a registry). Deterministic across
  instances. (`sub_workflow_for_synapse` already supports the empty-registry path.)
- **M3 status** (`sub_workflow_completed`) — find the last dict-step once; require `node ∈ terminals` AND
  `status ∈ {ok,done,pass}`, else refuse. A `status:error` terminal must NOT count as success.
- **M4 bare-string** (`_last_node`) — `n = step.get("node") if isinstance(step, dict) else None` (drop the
  bare-string branch — `["s7"]` must NOT pass as a terminal); validate steps are dicts on load.

## Deferred (NOT W1)
- **M1 mangling** (`_traj_path` lossy `re.sub` → filename collisions) — latent until depth≥3 / `_`-containing
  ids; rides with **W5** (the nesting/loop work — hash/encode the run-id there). **M2 terminals** (forgotten-edge
  = false terminal) — the lint catches the authoring bug → **W2** (check-stale/validate-draft); the full fix
  (explicit-terminal declaration) is a schema change best done with the meta-workflow (**W5**). **C2/C3
  loop-safety** (per-lap sub-run-id) → **W5**. No W1-adopted (single-entry) workflow loops or nests deeply, so
  all three are dormant here.

## Deferred to W5 (the meta-workflow rebuild — the only looping consumer)
- **C2/C3 loop-safety** — `_sub_traj_run_id` has no iteration component, so a LOOPING parent (re-entering the same
  sub-workflow synapse) reuses one run-id → stale-trajectory satisfies later laps + append corrupts. No W1-adopted
  workflow loops through a sub-workflow synapse, so this is dormant here; W5 adds the per-lap discriminator
  (`{parent}::{node}::{iter}::{sub}`) + the multi-lap regression test as part of making multiple-code-dev real.

## Acceptance
1. Anti-skip refuses a skipped single-entry sub-workflow (exit 2) and allows a genuinely-terminated one — with
   M3 (status) + M4 (shape) + M6 (required when declared) enforced. [adopted + new tests]
2. M1 filenames injective; M2 false-terminal rejected; M5 no implicit gating without `sub-workflow:`.
3. crucible gate passed:true.

## Changes
- `tools/workflow_run.py` · `workspace/schemas/workflow-file.schema.json` · `workspace/programs/workflow-run.md`
  · `tests/test_nested_workflow.py` (+ M-fix regression tests) · `test_workflow_run_g.py` · `test_workflow_run_help_h.py`
