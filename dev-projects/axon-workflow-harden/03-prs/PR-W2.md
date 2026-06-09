# PR-W2 — workflow lint suite: tool-aware refine + wire check-stale/templating as BLOCK gates

> **✅ MERGED — !144 (merge commit `4daaabe`), gate GREEN (passed:true, 0 blocking, 0 warn).** Verified on
> main: workflow-explain registered, stale mirror retired, both BLOCK controls live. Branch deleted.
>
> **Build history — amended commit `a2cdbaf` on `feat/workflow-lints`, gate-fixed (gate-first).**
> First gate RED on the pytest control — 4 failures, ALL from integrating the brought `workflow-explain.md`
> program (the other instance shipped the file without running our toolchain):
>   1. `test_programs_drift` — program not in REGISTRY.json → `programs-registry generate` (added it; the
>      regen also swept pre-existing main-side registry drift — legit catch-up).
>   2. `test_programs_md[workflow-explain]` — missing `## OUTPUT` / `▶` banner / `DONE()` → added them.
>   3. `test_registry_single_accessor` — my check_stale tool-aware refine hardcoded the registry path →
>      now reads tool names via the single accessor `_axon_registry.tools()` (F22), no raw path literal.
>   4. `test_compiled_quality_ratchet` — my `workflow-list.md` rewrite (inline→tool-delegation) made its
>      stale `workflow-list.cmp.md` mirror drop out of RED (13→10). Compilation is cognitive (no mechanical
>      refresh) + a stale mirror would serve the old inline logic → RETIRED the mirror; RED_BASELINE 13→10.
> Targeted re-verify: 1290 passed (all 162 program-structure params + the 4 + the lint suite + compiled),
> ruff clean, live check-stale/check-templating = 0. 13 files / +635/−125. Awaiting `passed:true` → push/MR/merge.

- **Status:** built + gate-fixed, re-gating (was: planned)
- **Phase:** 2-harmonize  ·  **Complexity:** M  ·  **dev-mode:** no (tools/ + workspace/programs/ + crucible.json + tests/)  ·  **Depends on:** W1 (the lint functions ship in workflow_run.py) + W3 (clean workflows)
- **Source:** MR !141's lint suite (`check_stale`/`check_templating`/`explain` already land in workflow_run.py via
  W1). W2 brings the delegator programs + tests, REFINES two false-positive classes, and wires the lints into the
  gate (owner's call: BLOCK, after W3 made the workflows clean).

## Refines (both false-positives found while validating)
- **check_stale tool-awareness** — a synapse `name:` can reference a TOOL, not a neuron (e.g.
  `adaptive-free-text.s1 → synapse-suggest` = `synapse_suggest.py`). check_stale flags it "missing-neuron"
  (false-positive). → load `tools/REGISTRY.json` tool names (+ `-`/`_` variants) and skip a name that resolves
  to a registered tool. (Resolves the 5th check-stale finding W3 deferred.)
- **check_templating reuse-awareness** — the 8 `library-dev.canonical` hits are `code-dev-*` synapse names in a
  `library-dev` workflow. They are LEGIT cross-domain reuse: all those code-dev neurons EXIST and work, and
  `library-dev-*` neurons do NOT exist (so renaming would BREAK library-dev). → check_templating must NOT hard-flag
  a foreign-domain-prefix synapse whose neuron EXISTS (legit reuse); flag (block) only a foreign-prefix synapse
  whose neuron is MISSING (a true templating slip). Keep an info/warn note for the reuse if useful.

## Bring (cherry-pick from review/mcd-141)
- `workspace/programs/workflow-list.md` · `workspace/programs/workflow-explain.md` (thin delegators to
  `TOOL(workflow-runner, list|explain)`) · the `menu.md` live-count line.
- `tests/test_workflow_check_stale_b.py` · `test_workflow_check_templating_d.py` · `test_workflow_explain_e.py`
  · `test_workflow_list.py` (+ refine-regression tests: synapse-suggest not flagged; library-dev reuse not blocked).

## Wire the gate (owner: BLOCK, only after the above make them clean)
- Add `workflow-runner check-stale` and `workflow-runner check-templating` as crucible.json controls (exit-1 =
  block). Verify the gate is GREEN first (W3 + the two refines must zero the findings), else it reds immediately.

## Acceptance
1. check_stale clean (synapse-suggest tool-backed, not flagged); check_templating clean (library-dev reuse not
   blocked); both exit 0 on the live workspace. [refine tests + the brought lint tests]
2. Both wired as crucible controls; `crucible gate` passed:true with them active.

## Changes
- `tools/workflow_run.py` (check_stale tool-aware + check_templating reuse-aware) · `tools/crucible.json`
  (+2 controls) · `workspace/programs/`{workflow-list, workflow-explain, menu}`.md` · the 4 lint test files + refine tests
