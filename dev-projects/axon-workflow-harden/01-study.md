# 01-study — assessment of MR !141 + harmonization plan

MR !141 (`feat/multiple-code-dev-iter-a-to-j`) from another AXON instance (Copilot · Opus 4.7). Reviewed the
full diff (32 files, +3376/−29), the 318-line HANDOFF, and validated every claim against THIS dev axon.

## Verdict per component — RELEVANCE × QUALITY

### KEEP (good + relevant — workflow subsystem exists here too)
- **Anti-skip enforcement** (`tools/workflow_run.py` +573 · sub-goal F) — `SubWorkflowNotCompletedError`;
  `advance()` refuses to leave a synapse declaring `sub-workflow:` until a per-run sub-trajectory terminates at
  a sub-terminal (exit 2, structured JSON). **This is exactly our re-MEGA thesis** — *an invariant that matters
  must live in the deterministic tool layer, not advisory `.md`.* High value. **Quality gap (author-flagged,
  caveat 5):** `--parent-run-id` is still OPTIONAL at the Python boundary → the teeth *sheath* if a caller
  omits it. Our harmonized PR should CLOSE this (require it when the cursor synapse has `sub-workflow:`).
- **Workflow lint suite** (`check-stale` B · `check-templating` D · `explain` E) — run live here: they surface
  **REAL bugs in our shared workflows** (see below). High value; consider wiring check-stale/templating into
  the crucible gate. **Quality gap:** `check-stale` flags `synapse-suggest` (a TOOL) as a "missing neuron" —
  it doesn't account for tool-backed synapse names → false-positive. Our PR should refine it.
- **`workflow-new` `validate_draft`** (C) — pre-write validation (the `when:` vs `if:` trap, missing keys,
  dangling `next:`, dup ids, bad `start:`) + a per-phase questions registry. Medium value, clean.
- **Parent-context threading** (G/H · `workflow-run.md` `--parent-run-id`/`--parent-node` + HELP) — the
  surface that drives the anti-skip; relevant (enables nested workflows). Keep with W1.

### KEEP-IF-WANTED (a new capability, not a fix)
- **`multiple-code-dev` meta-workflow** (`multiple-code-dev.yml` + `goal-set`/`goal-audit`/`audit-to-study`/
  `iterate-or-stop` programs + `code-dev-study` seed-ingest) — loops a code-dev cycle until a goal-audit passes.
  This is the "new workflow" suggestion. Sound, but it's a *product* addition (do we want auto-iterating
  code-dev?). Owner call.

### EXCLUDE (author agrees these are non-production)
- **`iter-helper.py`** (repo root) — the iteration-driver scaffold. HANDOFF §2.3/§5.1: "**NOT a production
  tool**." Drop.
- **`tools/run_tests.py`** — built on the premise "**Core Rule 9 forbids autonomous pytest**." FALSE HERE:
  our Core Rule 9 is the axon/-write gate; pytest runs via the crucible gate + the AEGIS project-grant. So it
  duplicates pytest, and it has a known full-sweep hang (caveat 6). Drop (revisit only if a no-pytest niche
  appears). Its `.gitignore` line + `tests/_jruntime_fixtures/` go with it.
- W: key cruft (§7 — 11 keys not cleaned between sessions): not our concern; the meta-workflow PR (if taken)
  should CLEAR its own W: keys.

## REAL bugs the lints surfaced HERE (worth fixing regardless of the rest)
- **5 missing-neuron (check-stale):** 4 workflows (`code-dev.canonical`, `cpp-code-dev`, `python-code-dev`,
  `library-dev.canonical`) s4 reference **`code-dev-self-review`** — but the real neuron is **`code-dev-review`**
  (exists). → rename the synapses to `code-dev-review` (verify it IS the s4 self-review) OR create the neuron.
  The 5th (`adaptive-free-text.s1 → synapse-suggest`) is a TOOL ref → fix is to refine check-stale (tool-aware),
  not write a neuron.
- **8 templating artefacts (check-templating):** `library-dev.canonical.yml` carries `code-dev-*` foreign-domain
  synapse names → rename to library-dev-domain names (or confirm intentional).

## Harmonization plan — decomposed gate-first PRs (cherry-pick from `review/mcd-141`)
- **W1 — anti-skip + parent-context** (workflow_run.py F + schema `sub-workflow` + workflow-run.md G/H + the
  4 nested-workflow test files) **+ close caveat 5** (require `--parent-run-id` when `sub-workflow:` declared).
- **W2 — workflow lint suite** (check-stale/templating/explain + workflow-list/explain programs + tests) **+
  refine check-stale to be tool-aware** (no false-positive on `synapse-suggest`) + consider a crucible control.
- **W3 — fix the surfaced bugs** (rename the 4 `code-dev-self-review`→`code-dev-review`; resolve the 8
  library-dev templating names). Small, high-value, independent.
- **W4 — workflow-new hardening** (validate_draft + questions registry + PHASE-E + tests).
- **W5 (owner-optional) — the multiple-code-dev meta-workflow** (the .yml + 4 programs + seed + tests), with
  its own W:-key cleanup.

Order: W3 (quick real-bug fix) → W1 (the teeth) → W2 (lints, ideally gated) → W4 → W5-if-wanted. Each branch-
first → cherry-pick/adapt from review/mcd-141 → targeted tests → full crucible gate passed:true → merge-by-
number. **EXCLUDE iter-helper.py + run_tests.py throughout.**

## Sufficiency
Study sufficient to plan. The KEEP set is sound + relevant; the EXCLUDE set is author-acknowledged scaffolding;
the bug fixes are independently valuable. Open owner decisions: (a) take W5 (the meta-workflow)? (b) wire the
lints into the crucible gate? → confirm, then build.
