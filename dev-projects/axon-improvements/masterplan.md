# AXON Improvements — the umbrella (single status board + plan)

> ONE place for all internal AXON improvement work. Open this to follow everything up.
> **RULE:** new improvement work = a workstream/item HERE — never a new top-level project.
> Updated 2026-05-27.

## ▶ STATUS BOARD  (the follow-up surface)

| Workstream | Status | Phase | Next action | Blocked by |
|---|---|---|---|---|
| **dag-consistency/** | ● active | 1-gate | build `R_DAG_CONSISTENT` gate (detect drift everywhere) | — |
| **axon-viz/** | ● active | 1-proto (a) | `tools/project_graph.py` + `viewer.html` (tolerant) | dag-consistency *(for (b) only)* |
| Tier 0 gates | ○ queued | — | F0 tree · F1 tests · F3 wiring · F4 triage · F5 cleanup · F6 artifact-guard | — |
| Tier 1 proof feeders | ○ queued | — | eval maturation · cross-host coherence | — |
| Tier 2–4 | ○ queued | — | wedge support · memory/docs · distribution | — |

**Critical path:** `dag-consistency` (schema) → `axon-viz (b)` ;  Tier 0 → *bug-free* ;  Tiers 1–2 → feed **axon-million** (product, separate).

---

## Sub-projects (nested here; full detail in each folder)
- **`dag-consistency/`** — DAG as single structural truth. `1-gate` (R_DAG_CONSISTENT) → `2-cascade` (wire the 7 mutation programs) → `3-nest` (nested project⊃phase⊃PR DAG). Supersedes firing-dag-missing.
- **`axon-viz/`** — projects/workflows/nested-DAG HTML visualizer. Generator → `graph.json` → cytoscape `viewer.html`. **(a)** tolerant prototype now → **(b)** full nested after dag-consistency.

## Scope
- **In:** kernel · quality/bug-free gates · tooling · cross-host consistency · memory · docs · distribution.
- **Out (separate top-level projects):** `axon-million` (product/proof — consumes Tiers 1–2) · `reservoir-eng` (domain) · `cpg-to-unstructure` (external) · `lab2-*` elifoot.
- **Archives:** `../finished/` (4) · `../obsolete/` (28).

## Backlog (DAG-ordered; items not yet broken into sub-projects)

### Tier 0 — Foundation / bug-free gates
- **F0 · Converge to ONE canonical axon tree** — 3 live trees today; biggest sellability risk. *[NEW]*
- **F1 · Test battery → enforce.** `[axon-tests · 5-enforce]`
- **F2 · DAG-as-truth** → now the **`dag-consistency/`** sub-project (see board).
- **F3 · Wire unwired memory keys.** `[axon-wiring-gaps · 1-design]`
- **F4 · Stub census + TODO/xfail triage.** `[axon-gap-closure · 1-stub-census]`
- **F5 · Testing-error + bloat cleanup.** `[axon-cleanup · 3-implement]`
- **F6 · Artifact brand-guard gate.** `[axon-artifact-guard · 1-guard]`

### Tier 1 — Proof feeders  (→ axon-million P3)
- **E1 · Eval/benchmark maturation** (seeds + CIs + scoring). `[axon-ascent · 3-safety-budget]`
- **X1 · Cross-host coherence** → benchmark goal #4 + Axiom portability. `[claude-code-consistency · copilot-anchor · copilot-consistency · copilot-deviation-study]`
- *(done)* `R_GROUNDED_CLAIMS` → goal #5.

### Tier 2 — Wedge support  (→ axon-million P2 Axiom v1.1)
- **W1 · Portability + enforcement-gap signal** from X1.

### Tier 3 — Subsystems
- **M1 · Memory subsystem** (harness-portable memory + reminders; kernel #96). `[axon-memory · 2-plan]`
- **D1 · Docs** (regenerate AXON-DOCS; PR-S01). `[axon-docs]`

### Tier 4 — Distribution enablers
- onboarding `[lab2-15]` · prefs-doctor `[lab2-14]` · tool-help `[lab2-08]` · cron-runner `[lab2-07]` · progs-index `[lab2-13]`.

### Parked — low priority / never-started
- `[axon-coherence-v2]` · `[axon-ranker-v2]` · `[axon-user]` · lab2 axon stubs `[06,09,17,18,20]`.

## Reference
- Finished (`../finished/`): axon-audit-2026 (verdict ✓) · axon-synapse · axon-polish · axon-autoimprove (PR-211 open).
- Each sub-project folder holds its own `03-prs/` + `phases/` detail.
