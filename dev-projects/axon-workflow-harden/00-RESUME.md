# ▶ RESUME HERE — axon-workflow-harden (updated 2026-06-05)

Read this first on resume. Active project = **axon-workflow-harden** (W:code-dev-project), phase 2-harmonize.

## Where we are
**W3 merged (!142)** · **W1 merged (!143)** · **W2 merged (!144, `4daaabe`)**. main synced + clean.
W2 = lint suite + two false-positive refines + two BLOCK controls. (Gate-fix lesson: a brought program needs our
toolchain — register via generate · OUTPUT/banner/DONE structure · single-accessor for the registry read · retire
or refresh a stale compiled mirror. See memory `axon-foreign-program-integration`.)

## Immediate resume step — W5 rebuild in progress (W5a gating)
W1/W2/W3/W4 all merged (!142/!143/!144/!145). W5 = REBUILD `multiple-code-dev`, decomposed (design: `04-w5-design.md`):
- **W5a** — runner mechanism: per-lap (visit) sub-run-ids + M1 collision-safe paths. BUILT + gating (`1186924`,
  `feat/workflow-loop-antiskip`, `03-prs/PR-W5a.md`). Additive/opt-in (visit=None == legacy). On passed:true → merge.
- **W5b** — BUILT + gating (`d6fe162`, `feat/multiple-code-dev-rebuild`, `03-prs/PR-W5b.md`). ALL audited blockers
  fixed (C1/C4/C5/H1/H2/H3/H5 + the C2/C3 visit-wiring in workflow-run.md, backward-compatible) + 4 new programs
  registered/valid. 9-test rebuild proof (routing via the predicate engine) + seed test + broad 2262-pass regression.
  On passed:true → merge.
- **W5c** — BUILT + gating (`feat/multiple-code-dev-e2e`, `03-prs/PR-W5c.md`). H4 e2e: drives the REAL workflow
  3 laps through the advance-guard, per-lap anti-skip proven on every lap + the C2 stale-skip vector blocked +
  C4 routing pinned (3 tests). On passed:true → merge → **campaign W1–W5c COMPLETE**.
- **M2 (deferred follow-up, MED)** — `terminals()` still accepts a FORGOTTEN on-complete as a terminal (forgery
  vector). Real fix = explicit `terminal: true` schema + migrate all workflows + `terminals()` requires it + lint.
  A BREAKING schema-migration, separate scope. NOT dropped — its own runner-hardening PR.
- Gate-first each: branch → build → `crucible gate` (background, ~10-17min) → parse passed:true SEPARATELY → discard
  regen dirt (`tests/coverage.json`, `workspace/AXON-DOCS.md`, `workspace/audit/axon-lang.md`) → brand-free commit +
  AXON trailer (pre-lint `lint_commit_trailer.py --stdin`) → push → `glab mr create --fill --yes` → `glab mr merge <N>
  --yes --remove-source-branch` (405-retry) → sync main.

## Then the rest of the harmonization (build order, gate-first each)
1. ✅ **W3** merged !142 — `code-dev-self-review` → `code-dev-review-self` (4 workflow YAMLs).
2. ✅ **W1** merged !143 — anti-skip runner + M3/M4/M5/M6 (M1/M2/C2/C3 deferred to W5). Removed the brought
   F841 (`dom`). Test surgery: 5 anti-skip tests repointed/deferred; new `test_workflow_antiskip_mfixes.py`.
3. 🟡 **W2** built `325f4f3`, gating — lint suite (`workflow-list`/`workflow-explain` neurons + dynamic menu),
   check-stale tool-aware refine (`synapse-suggest` false-positive) + check-templating reuse-aware refine
   (library-dev's legit code-dev-* reuse — design call: ACCEPT reuse, don't rename; neurons all exist) +
   the NoneType-subscript crash fix + **the two BLOCK controls** (owner's call; W3 made the gate green first).
4. **W4** — workflow-new `validate_draft` pre-write hardening + `workflow-new-questions.yml`.
5. **W5** — **REBUILD `multiple-code-dev`** (it's a mirage — never ran; the "10 green iters" were
   `iter-helper.py` hardcoding `advance(s4→s6)`). Fix C1–C5 + H1–H5 + the loop-safety C2/C3 (per-lap sub-run-id)
   per **`02-mcd-deepstudy.md`**: route the gate decision into predicate ctx, per-lap sub-run-id, wire goal
   criteria goal-set→goal-audit, fix the seed field-names, reset W: keys, abort→clean terminal, + loop/abort/
   depth-3 tests. The CONCEPT is sound (owner sees potential) — make it actually run.

## Key context / decisions
- `review/mcd-141` branch = the cherry-pick source (kept locally). Don't merge !141 wholesale.
- Owner decisions: lints → BLOCK gate (after W3); W5 = rebuild (not adopt); I sequence priority.
- Reference docs in this project: `01-study.md` (the !141 vet + harmonization plan), `02-mcd-deepstudy.md`
  (the 3-agent bug audit of the meta-workflow — the bug list for W5).
- Minor follow-up noted: `tests/test_predicate_workflow_vocab.py` errors when run in ISOLATION (dynamic
  importlib of predicate.py without sys.modules registration — a dataclass `__module__` lookup quirk); passes
  in the full suite. Tiny test-hygiene fix (register the module before exec_module).

## Parked projects (not lost)
- **axon-coverage** — the external coverage deep-study's gaps (telemetry inert · L: split · memory program-tier
  · the GAP list · semantic-search stale ×3 · rtk OPTIONAL · list-programs). Study-complete; plan in its
  `01-study.md`. P0 = telemetry+memory learning-loop.
- **axon-resweep** — the re-MEGA. DONE (6/6 merged, !135–140). workflow-step: done.

## Session ledger (this thread)
Merged: SP-1 + R1–R6 + PM1 + 2A–2F = **14 PRs** (re-MEGA complete). Then: validated the deep-study (axon-coverage
scaffolded), vetted MR !141 + 3-agent deep-study (axon-workflow-harden scaffolded), started W3. Memory updated
(MEMORY.md + axon-resweep-campaign.md).
