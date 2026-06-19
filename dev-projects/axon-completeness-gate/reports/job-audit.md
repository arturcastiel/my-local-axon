# Per-Job Audit — AXON Council Report

**Charge:** Audit individual AXON jobs (programs and tools) for health — which are ACTIVE+tested, which are stale/orphaned/untested, and which duplicate others. Produce a per-job status table for the most important jobs plus a triage list.

**Council:** 4 sealed seats — Seat 1 (Coverage/Test lens), Seat 2 (Orphan/Dead-code lens), Seat 3 (Duplication/Overlap lens), Seat 4 (Challenger: broken / should-not-exist).
**Status:** Advisory. Read-only audit. Findings verified against the live tree on 2026-06-19.

---

## 1. Executive Summary

AXON's job surface is **far healthier than its size suggests** — ~178 registered tools and 173 registered programs, and all four seats independently converge on the same verdict: **near-zero true rot.** Registry/disk sync is airtight, reachability is machine-enforced, and the apparently-scary clusters (audit family, lint family, drift/conformance family) are role-distinct, not duplicates. The challenger seat found **zero broken jobs** — every tool smoke-run exits 0.

The real weaknesses are narrow and consistent across lenses:

1. **Dead capability, not dead code.** A small cluster of *functional gate tools* (`axon_io_lint`, `emit_listener_lint`, `domain_validate`) run clean but are wired into **no runner** — not pre-commit, not CI, not crucible. They enforce nothing. Verified: none appear in `tools/crucible.json`, `.pre-commit-config.yaml`, or `.github/workflows/ci.yml`.
2. **A one-directional orphan check.** `tools/keystone.py` verifies every crucible *control* points to a real script, but not the inverse — that every gate *tool* is referenced by a control. This asymmetry is *exactly why* finding #1 exists and *why it will recur*.
3. **Marked-for-death jobs that nobody has deleted.** AXON has excellent deprecation *discipline* (`workspace/QUARANTINE.md`, an append-only deprecation ledger, a de-install manifest `_reservoir-manifest.md`) but is conspicuously slow at *execution*. Reservoir/adjoint content merged in by accident remains live and ACTIVE despite being owner-flagged for removal with the removal procedure already written.
4. **Two registry-drift jobs below the radar.** `tools/queue_tool.py` and `tools/_axon_rollback.py` exist on disk but are **unregistered** (verified: 0 hits in `tools/REGISTRY.json`). The drift gate reports 178/178 clean because it counts registered-and-present; these slip beneath it via naming. `_axon_rollback` — a recovery primitive — is untested, which is the single highest-risk gap.
5. **Behavioral test depth is thin.** Structural coverage is universal (all 174 programs are wired-checked), but only **10 programs** receive behavioral assertions, tiering lives in a hardcoded test constant rather than the registry, and four `phase5` behavioral tests silently skip in any checkout lacking the private `axon-polish` tree.
6. **Concentrated duplication debt in `code-dev-*`.** 8 self-identified alias stubs + 7 autogen-stub programs + a `code-dev-meta-*` namespace that re-exports kernel tools. This is *managed sprawl*, but it is the densest cleanup surface.

**Bottom line:** AXON is excellent at *marking* dead jobs and slow at *removing* them. The dominant council recommendation is **prune, wire, and close the orphan-gap** — not fix — plus targeted tests for the few untested risky primitives.

---

## 2. Detailed Findings (file-cited)

### 2.1 What is STRONG (consensus across all four seats)

- **Kernel rules are the gold standard.** 37 rule predicates in `tools/rules/r*.py` each have a 1:1 dedicated test in `tests/test_rules/test_r*.py`. CI enforces **100% line+branch** on `tools/rules/` (`.github/workflows/ci.yml` coverage-gate step; `pyproject.toml [tool.coverage.report]`). (Seat 1)
- **Registry/disk hygiene is airtight.** Verified live: `registry_drift.py check` → `ok:true, registered:178, on_disk:178, drift_count:0`. Program registry: 173 registered vs 174 on disk; the only unregistered file is `workspace/programs/_reservoir-manifest.md` (a private `_`-prefixed de-install manifest, expected). (Seats 1, 2, 4)
- **Reachability is machine-enforced, not lucky.** `workspace/memory/longterm/dispatch-index.json` covers 172/172 runnable programs; `tools/crucible.json` registers `liveness` at **BLOCK** severity, and `tests/test_ci_runs_crucible.py` asserts BLOCK controls exist. This is the immune system that keeps disk/registry from drifting. (Seat 2)
- **Structural program coverage is universal.** `tests/test_programs_md.py` parametrizes over ALL programs and asserts valid structure, zero kernel-rule violations, and that every `EXEC`/`TOOL` reference resolves. So all 174 programs are wired-checked even when not behaviorally tested. (Seat 1)
- **The audit and lint families are role-distinct, NOT duplicates.** `axon_audit` (structural), `neuron_audit` (program-as-neuron conformance), `auto_audit` (append-only ledger), `audit_axon_lang` (LANG primitive coverage), `rag_maturity_audit` (70-pt rubric) each carry a "why separate" rationale in their headers. Likewise `lint_paths` (hardcoded homedir) vs `lint_path_vars` (define-vs-use). (Seats 3, 4)
- **A formal deprecation discipline exists and is complete:** `workspace/QUARANTINE.md` + append-only `workspace/memory/episodic/deprecation-log.md` + de-install manifest `workspace/programs/_reservoir-manifest.md`. (Seat 4)

### 2.2 Dead capability — orphan GATE tools (Seats 2 & 4, fully concordant)

Three functional gate tools run clean but are connected to **no runner**. Verified live: `grep` for `axon_io_lint`/`emit_listener_lint` across `tools/crucible.json`, `.pre-commit-config.yaml`, and `.github/workflows/ci.yml` returns **NOT WIRED**.

- `tools/axon_io_lint.py` — full argparse gate CLI, committed ~13h ago (Jun-19), exercised only inside `tests/test_axon_io_lint.py`.
- `tools/emit_listener_lint.py` — runs `ok:true`, catalog-only, exercised only in `tests/test_emit_listener_lint.py`.
- `tools/domain_validate.py` — runs `ok:true`, referenced only by `tools/REGISTRY.json` + the `AXON-DOCS.md` catalog.

These are "tested but inert" — they claim to enforce R9 invariants but gate nothing in CI or commit flow. They are the exact "feature goes missing" disease that `tools/rules/r_no_orphan_tools.py` was built to stop; they predate the rule and are grandfathered.

### 2.3 The one-directional orphan check (Seat 4 — structural root cause)

`tools/keystone.py` enforces "every crucible *control* points to a real script" (no dangling controls) but **not** the inverse — "every gate *tool* is referenced by a control." That asymmetry is precisely why the orphan gates in §2.2 slip through: they are real scripts that no control points to. Without closing this, §2.2 recurs for every future gate.

### 2.4 Marked-for-death, not removed (Seat 4 — the headline dissent)

`workspace/QUARANTINE.md` flags personal reservoir/adjoint content merged into shipping AXON by accident — all logged in the deprecation ledger with **no sunset date** (owner-gated). These remain live ACTIVE jobs:

- Tools: `tools/reservoir_pvt.py`, `tools/reservoir_mcp.py`
- Program: `workspace/programs/reservoir-review.md`
- Rule: `tools/rules/r_reservoir_output.py`
- Doc-job: `workspace/OBJECTIVE-FUNCTION-INTERFACE.md` ("0 references — fully orphaned")

The removal procedure is already written in `workspace/programs/_reservoir-manifest.md`. The only missing thing is the trigger.

### 2.5 Registry drift below the radar (Seat 1)

Verified live: `grep` for `queue_tool`/`queue-tool` and `_axon_rollback`/`axon-rollback` in `tools/REGISTRY.json` both return **0**.

- `tools/queue_tool.py` — invoked in 5 files, **unregistered**, no test. ACTIVE-in-practice but invisible to the drift gate.
- `tools/_axon_rollback.py` — a rollback/recovery primitive, **unregistered**, **zero tests**. This is the highest-risk single gap: a tool whose entire job is recovery, untested.

### 2.6 Under-tested ACTIVE tools (Seats 1, 3, 4 concordant)

Verified live: `tests/test_test_runner.py`, `tests/test_study_evals.py`, `tests/test_document_parser.py` all **do not exist**.

- `document_parser`, `study_evals`, `test_runner` are ACTIVE in REGISTRY but have **zero** dedicated `tests/test_<stem>.py`. They pass the tools/ ≥80% gate by *import* coverage only, reached transitively (e.g. `document_parser` via `axon_io_lint.py`, `health.py`, `rag_maturity_audit.py`). Seat 3's grep confirms `test_runner` → 0 test references, `study_evals` → 0.

### 2.7 Behavioral test depth & blind spots (Seat 1)

- **Only 10 programs get behavioral assertions.** `TIER_A` in `tests/test_programs_tier_a.py:18` is a hardcoded list of 10. The other ~164 get structural checks only. The program registry has **no `tier` field** (all 173 entries show `tier=?`) — tiering lives in a test constant, not data, so it can't be queried or scaled.
- **Four phase5 behavioral tests silently no-op.** The `axon-polish` private tree is absent in this checkout, so `test_phase5_{wave3,wave4,extend,pilot}.py` skip their core assertions — green-by-skip, a coverage blind spot masquerading as passing.
- **Local `.coverage*` is stale and misleading.** Dated May-26; combining with the one fresh parallel file produces broken path-maps ("290 tools at 0%"). The repo knows this (`tools/coverage_gate.py` docstring). Trustworthy coverage exists only in CI's fresh `coverage.xml`.

### 2.8 Duplication debt, concentrated in `code-dev-*` (Seat 3, supported by Seats 2 & 4)

- **T1 — 8 self-identified alias stubs** still in the live tree, e.g. `workspace/programs/code-dev-reviewer-track.md` ("alias stub — superseded by code-dev-knowledge-reviewer-track; removed next release"). Also `code-dev-preflight`, `code-dev-init`, `code-dev-plan`, `mode-router`, `find-program`, `meta`, `_code-dev-schema-v4`. **Cleanest deletions — they advertise their own removal.**
- **T2 — 7 autogen-stub programs** shipped with placeholder descriptions `(autogen-stub — needs description)`: `code-dev-meta-board`, `code-dev-meta-igap`, `code-dev-meta-usage`, `code-dev-meta-dispatch-stats`, `code-dev-events-emit`, `code-dev-rules-audit`, `_code-dev-schema-v4`. (Seats 2, 3, 4 all list this set.)
- **T3 — `code-dev-meta-*` re-export layer.** A whole namespace re-exporting kernel tools (`dispatch-stats`, `igap`, `usage`, `board`) under a `code-dev-meta-` prefix. Defensible as code-dev UX, but the single largest systematic duplication surface — should be a documented decision, not drift.
- **T4 — `menu`/`status`/`stats` dashboard overlap.** Purposes diverge (home/mode-switcher vs live OS dashboard vs workspace-health) but the rendered `━━━` box surfaces overlap enough that users won't know which to call. Consolidation/cross-link candidate, not a delete.
- **T5 — Audit-program proliferation** is overlap-by-accretion, not duplication — each has a distinct scope. Recommend an audit *index/router*, not merges.

### 2.9 Residue defect found in passing (Seat 3, verified)

Verified live: the last two non-blank lines of `axon/programs/mode-build.md` are an identical, duplicated `DONE(mode-build)`. This is exactly the "dead double-DONE tail" that `tools/residue_lint.py` is built to catch — but residue-lint's purpose string scopes it to *workspace* programs, so it misses this **OS** program. Two fixes: (a) fix the file; (b) widen residue-lint to cover `axon/programs/`.

### 2.10 Deprecated alias still shipped (Seats 2 & 4 — with a resolved disagreement; see §4)

`hooks` is `status: OPTIONAL` in `tools/REGISTRY.json` (verified line 691: `"DEPRECATED — alias for events tool. Use events hook-add/... Shim removed next release."`). Seat 4's closer read: its repo mentions in `auto-actions.md` and `axon-reanchor.md` (and `KERNEL-SLIM.md`) are **prose, not `TOOL(hooks,…)` calls** — so the alias is genuinely uncalled and safe to delete; `events` covers it.

---

## 3. Per-Job Status Table (most important jobs)

| Job | Kind | Registry | Tested | Wired/Reachable | Status / Verdict |
|---|---|---|---|---|---|
| `tools/rules/*` (37) | rule | in `registry.py` | 1:1 in `tests/test_rules/` | 100% gated | **ACTIVE+TESTED (gold)** |
| `crucible.py` | tool | ACTIVE | `test_crucible.py`, `test_ci_runs_crucible.py` | gated | ACTIVE+TESTED |
| `registry_drift.py` | tool | ACTIVE | `test_registry_drift.py` | crucible | ACTIVE+TESTED |
| `coverage_gate.py` | tool | ACTIVE | `test_coverage_gate.py` | gated | ACTIVE+TESTED |
| `keystone.py` | tool/meta-gate | ACTIVE | yes | crucible | **KEEP, but one-directional** |
| `liveness.py` | tool/gate | ACTIVE | yes | crucible (BLOCK) | ACTIVE+TESTED (enforces 0-orphan) |
| All programs (174) | program | 173 reg | `test_programs_md.py` (structural, all) | dispatch-index | **STRUCTURALLY TESTED** |
| Tier-A programs (10) | program | — | `test_programs_tier_a.py` | — | BEHAVIORALLY TESTED |
| Other ~164 programs | program | reg | structural only | dispatch-index | **THIN (no behavior)** |
| `document_parser.py` | tool | ACTIVE | none (indirect) | yes | **ACTIVE, UNDER-TESTED** |
| `study_evals.py` | tool | ACTIVE | none (0 refs) | yes | **ACTIVE, UNDER-TESTED** |
| `test_runner.py` | tool | ACTIVE | none (0 refs) | yes | **ACTIVE, UNDER-TESTED** |
| `queue_tool.py` | tool | **UNREGISTERED** | none | invoked in 5 files | **DRIFT, UNTESTED** |
| `_axon_rollback.py` | tool | **UNREGISTERED** | none | recovery primitive | **UNTESTED (highest risk)** |
| `axon_io_lint.py` | tool/gate | ACTIVE | self-test only | **not in CI/precommit/crucible** | **ORPHAN GATE — inert** |
| `emit_listener_lint.py` | tool/gate | ACTIVE | self-test only | **not wired** | **ORPHAN GATE — inert** |
| `domain_validate.py` | tool/gate | ACTIVE | yes | **no runner** | **ORPHAN GATE — inert** |
| `hooks` | tool | OPTIONAL | — | uncalled (prose only) | **DELETE — DEPRECATED alias of `events`** |
| `reservoir_pvt` / `reservoir_mcp` | tool | ACTIVE | yes | yes | **PRUNE — QUARANTINE.md + ledger** |
| `reservoir-review` | program | ACTIVE | yes | yes | **PRUNE — same** |
| `r_reservoir_output` | rule | active | yes | yes | **PRUNE — QUARANTINE** |
| `OBJECTIVE-FUNCTION-INTERFACE.md` | doc-job | — | — | 0 refs | **PRUNE — fully orphaned** |
| 8 alias-stub programs (T1) | program | reg | structural | dispatch | **DELETE — self-identified** |
| 7 autogen-stub programs (T2) | program | ACTIVE | structural | dispatch | **STALE — fill or retire** |
| `code-dev-meta-*` (T3) | program ns | reg | structural | dispatch | **DECIDE — sanctioned re-export?** |
| `menu`/`status`/`stats` (T4) | program | ACTIVE | structural | menu | **CLARIFY/CONSOLIDATE** |
| audit family (5 tools) | tool | ACTIVE | yes | yes | **KEEP — distinct, not dup** |
| `lint_paths` + `lint_path_vars` | tool | ACTIVE | yes | yes | **KEEP — distinct jobs** |
| `axon/programs/mode-build.md` | OS program | — | — | — | **DEFECT — double-DONE residue** |
| phase5 wave3/4/extend/pilot tests | test | — | self | **skips in this checkout** | **BEHAVIORAL BLIND-SPOT** |

---

## 4. Prioritized Recommendations (triage)

### P1 — Highest risk / owner-approved-but-undone

1. **Test `_axon_rollback.py`.** A recovery primitive with zero tests and no registry entry is the single highest-risk gap. Add behavioral tests for the failure path it guards, then register it. (Seat 1)
2. **Resolve `queue_tool.py` drift.** It is invoked in 5 files yet unregistered and untested — register + test, or delete. (Seat 1)
3. **Execute the QUARANTINE prune.** Run `_reservoir-manifest.md` to remove `reservoir_pvt`, `reservoir_mcp`, `reservoir-review`, `r_reservoir_output`, `OBJECTIVE-FUNCTION-INTERFACE.md`. Owner-approved; only the trigger is missing. (Seat 4)
4. **Wire-or-drop the 3 orphan gates** (`axon_io_lint`, `emit_listener_lint`, `domain_validate`): add to `tools/crucible.json`/pre-commit, or demote to OPTIONAL. A gate nobody runs is worse than no gate. (Seats 2, 4)

### P2 — Structural fixes that prevent recurrence

5. **Close the one-directional orphan gap.** Add an inverse census to `tools/keystone.py` (or extend `r_no_orphan_tools.py` to the standing set) so gate-tools-without-a-control are caught going forward. Without this, #4 recurs. (Seat 4)
6. **Behavioral tests for the 3 under-tested ACTIVE tools** (`document_parser`, `study_evals`, `test_runner`) — they pass only by import coverage. (Seats 1, 3)
7. **Fix the phase5 silent-skip blind spot** — synthetic `axon-polish` fixture, or assert-fail (not skip) in CI. (Seat 1)
8. **Add a human-reachability lint.** 136/173 programs are in neither `menu.md` nor `PROGRAMS-INDEX.md` (runtime-reachable but menu-invisible → latent orphans). Assert every ACTIVE program is reachable from at least one human-navigable surface. (Seat 2)

### P3 — Cleanup / cosmetic / policy

9. **Delete the 8 self-identified alias stubs (T1)** after confirming dispatch-index no longer routes to them. (Seat 3)
10. **Fill or retire the 7 autogen-stub programs (T2)** with placeholder descriptions. (Seats 2, 3, 4)
11. **Decide the `code-dev-meta-*` policy (T3):** document it as a sanctioned re-export layer, or collapse it. (Seat 3)
12. **Fix `mode-build.md` double-DONE and widen `residue_lint.py` to cover `axon/programs/`.** (Seat 3)
13. **Delete the `hooks` DEPRECATED alias** from `tools/REGISTRY.json`; migrate any remaining references to `events`. (Seats 2, 4)
14. **Promote tiering into the program REGISTRY** (add a `tier` field; all 173 are `?`) and grow `TIER_A` beyond 10. (Seat 1)
15. **Gitignore local `.coverage*`** and reason only from CI `coverage.xml`. (Seat 1)
16. **Clarify `menu`/`status`/`stats` boundaries (T4)** — cross-link or merge `stats`→`status --full`. (Seat 3)
17. **Add an audit-family index/router (T5)** rather than merging the role-distinct audit programs. (Seat 3)

---

## 5. Open Questions / Dissent

The four seats are **strongly concordant** — there is convergence, not conflict, on the core findings. The disagreements are nuances of interpretation, preserved here:

- **`hooks` — uncalled, or has live callers?** Seat 2 reported `hooks` is "still invoked from `auto-actions.md`, `axon-reanchor.md`, and `KERNEL-SLIM.md`" and recommended migrating those call-sites before deletion. Seat 4 did a closer read and found those mentions are **prose, not `TOOL(hooks,…)` invocations** — so the alias is genuinely uncalled and safe to delete outright. **Resolution leans Seat 4** (the syntactic distinction is load-bearing), but the council should confirm with a `TOOL(hooks` grep before deletion. Practically the outcome is the same (delete `hooks`); only the amount of pre-migration work differs.

- **`a2a` / `onboarding` — abandoned or feature-staged?** Seat 2 flags `a2a`, `onboarding`, `apply_memory_slot`, `domain_validate`, `metric_integrity` as registered/tested but with no runtime entrypoint, characterizing them as "feature-staged, not abandoned" (committed 3–4 weeks ago). This is a softer reading than Seat 4's "orphan gate" framing for the overlapping `domain_validate`. **Open question:** is the absence of a route a deliberate staging decision or latent rot? Needs an owner call per tool — the council cannot resolve intent from the tree alone.

- **Severity of the menu/index invisibility (136 programs).** Seat 2 stresses this as the largest *latent* orphan-generator; the other seats treat it as discoverability, not health. All agree these are NOT current orphans (dispatch-index reaches them). The dissent is only about **priority** — Seat 2 wants a P2 lint; others would defer.

- **`code-dev-meta-*` — UX feature or duplication.** Seat 3 calls the re-export namespace "the single largest systematic duplication surface"; Seats 1/4 are more tolerant, treating it as defensible code-dev UX. **Unresolved policy question for the owner**, not a factual disagreement.

- **Cleared suspicions (explicitly NOT findings — recorded so the council does not re-chase them):**
  - `test.py` vs `test_runner.py` are **NOT duplicates** — `test.py` is a program-structure dry-run validator; `test_runner.py` wraps pytest. (Seat 1)
  - The memory-sync trio (`apply_memory_slot` → `import axon_memory_sync` → `memory_sync`) is a **layered stack, not a duplicate**. (Seat 2)
  - "82 tools <80% coverage" / "6 tools never referenced in tests" from naive local `.coverage` are **stale-DB artifacts**, not real gaps. (Seat 1)
  - `coverage_gate`, `metric_integrity`, `lint_commit_trailer` look test-only by grep but are wired via `crucible.json` / `metrics_manifest.json` / pre-commit. (Seat 2)

**Synthesized challenger verdict (Seat 4, endorsed as the report's closing note):** AXON's loudest "should not exist" signal is *not broken code* — it is the **gap between its complete deprecation discipline and the fact that nothing has executed it.** The recommended standing fix is a recurring **"deletion-pass" job** that drains `QUARANTINE.md` and the orphan-gate list, so marked-for-death jobs cannot live indefinitely — paired with the inverse-orphan check (P2 #5) so new dead capability can't accumulate silently.

---

*Report compiled by the DELIBERATOR from 4 sealed Round-1 seat opinions. Key cited files: `tools/REGISTRY.json`, `workspace/programs/REGISTRY.json`, `tools/crucible.json`, `tools/keystone.py`, `tools/registry_drift.py`, `tools/residue_lint.py`, `tools/rules/r_no_orphan_tools.py`, `tools/rules/r_new_needs_test.py`, `tools/coverage_gate.py`, `workspace/QUARANTINE.md`, `workspace/programs/_reservoir-manifest.md`, `workspace/memory/longterm/dispatch-index.json`, `tests/test_programs_md.py`, `tests/test_programs_tier_a.py`, `tests/test_rules/`, `.github/workflows/ci.yml`, `.pre-commit-config.yaml`, `axon/programs/mode-build.md`, `pyproject.toml`. Drift, unregistered-tool, missing-test, lint-wiring, and double-DONE claims independently verified against the live tree on 2026-06-19.*
