# Master plan v2 — AXON Polish Phase 3-design

> Integrates ALL artifacts produced: 137 original flaws + 13 new findings + 48 demands +
> 14 prior projects + 7 reference docs + 8 ADRs + 100% verification coverage.
> Supersedes `phases/2-prioritise/02-plan.md` (which predated verification iterations 2+3).

## Inputs used (every artifact, no exceptions)

| Artifact | Lines | Role in this plan |
|---|---|---|
| `_flaws.md` | ~150 findings post-reconcile | Source of bug-fix clusters |
| `_demands.md` | ~50 demands | Source of capability-gap clusters |
| `_adrs.md` | 8 ADRs (6 accepted, 1 proposed, 1 expanded) | Design constraints on each cluster |
| `_prior-work-crossref.md` | 14 prior projects | Routing + pattern adoption |
| `_verified-findings.md` | ~160 verifications | Severity reconciliation + count corrections |
| `_synthesis.md` | overview | Confidence baseline |
| `axon-reference/kernel/` | ~7k words | Identified F-D3-016, F-D3-017 + 4 audit-notes |
| `axon-reference/tools/` | ~10.8k words | Confirmed shell.py architecture; CHANGELOG/registry deltas |
| `axon-reference/programs/` | ~11.5k words | True counts: 212 programs (183 workspace + 29 kernel) |
| `axon-reference/workflows/` | ~7.8k words | F-D4-017a (full predicate vocab missing) |
| `axon-reference/memory/` | ~6.1k words | F-D9-022 (orphaned recover) confirmed in scope |
| `axon-reference/compliance/` | ~7.9k words | Rule-by-rule enforcer status |
| `axon-reference/identity/` | ~6.5k words | F-D6-016 (drift-log path discrepancy) |

## What changed since `02-plan.md` (which is now superseded)

### 13 NEW findings folded in
1. **F-D7-007a** BLOCKER — enforce.py `user:` bypass → cluster C-12 expanded
2. **F-D6-005a** BLOCKER — write-attribution sentinel → NEW cluster C-16 needed
3. **F-D6-005b** BLOCKER — EXEC silent simulation → routes to axon-copilot-anchor (cross-ref only)
4. **F-D4-016** MAJOR — DAG auto-emit content-coupled → routes to firing-dag-missing
5. **F-D4-017** BLOCKER — `goal.acceptance.met()` undefined → C-05 expanded
6. **F-D4-017a** BLOCKER — entire predicate vocab missing → C-05 expanded again (largest scope change)
7. **F-D4-018** MAJOR — workflow-run no `--ctx` → C-05 prerequisite
8. **F-D5-009** MINOR — drift-log schema lacks kinds → routes to axon-copilot-anchor
9. **F-D9-022** MAJOR — `session.recover()` orphaned → ADR-006 Phase 1 directly addresses
10. **F-D9-023** MINOR — `processes/active/` documented but unused → C-09 cleanup
11. **F-D6-016** MINOR — drift-log path discrepancy → routes to axon-copilot-anchor
12. **F-D3-016** MINOR — `TOOL(drift, check)` stale in kernel → C-09 cleanup
13. **F-D3-017** MINOR — KERNEL-SLIM ~780 token claim stale → C-09 cleanup

### 7 severity reframes
- F-D3-003 MAJOR→MINOR; F-D5-001 BLOCKER→MINOR; F-D6-008 MAJOR→MINOR
- F-D4-001 BLOCKER→MAJOR; F-D9-006 BLOCKER→MINOR; F-D9-007 BLOCKER→MAJOR
- F-D4-001 reframed: dead code, not crash

### 1 retraction
- F-D3-012 (axon/tools/ DOES exist) — REMOVED from catalog

### 6 count corrections (audit was conservative — actual is worse)
- F-D2-015: 46 readers (not 22). **Doubles the work** of the role-vs-impl audit.
- F-D3-014: 118 disk stubs (not 25). **Almost 5× the stub-cleanup scope.**
- F-D6-012: 16 always-skip tests (not 7).
- F-D6-015: 15 bare HALTs (not 12).
- F-D7-011: 0 references for 5 OPTIONAL tools (not ≤1). All 5 fully dead.
- D-D7-008: PARTIAL — 25 tool doc cards already exist (CHANGELOG promise partly kept).

---

## Updated cluster matrix (16 clusters, was 15)

Cluster ranking now uses:
- `impact (1-10) × (1 / size-weight) × (1 + prior-work-bonus)` (same formula)
- BLOCKER count weighted higher per cluster (was implicit)
- Cross-project routing factored in (clusters routed-out scored 0 for axon-polish)

| Rank | Cluster | Title | Size | BLOCKERs closed | MAJORs closed | Score | ADR | Status |
|---|---|---|---|---|---|---|---|---|
| 1 | C-12 | enforce.py + R9 hardening (PR-12.1 + PR-1.2) | S+S | 3 (F-D7-007/a, F-D8-001) | 1 | **9.5** | ADR-001 sibling | spec drafted |
| 2 | C-07 | context.py + host-model awareness | S | 1 (F-D9-001) | 3 (F-D9-005, F-D9-015, F-D9-017) | **8.75** | align master W3-* | spec drafted |
| 3 | C-02 | fail_render.py + 5-program migration | S+M | 0 (no BLOCKER) | 2 (F-D2-001, F-D2-007) + 3 MINORs | **8.0** | ADR-002 | spec pending |
| 4 | C-05a | workflow termination + ctx-passing (ADR-005a) | S | 1 (F-D4-003) | 2 (F-D4-008, F-D4-018) | **6.75** | ADR-005a | spec pending |
| 5 | C-09 | duplicated files cleanup | S | 3 (F-D1-001/002/003) | 1 (F-D6-011 dead bottom) | **6.0** | none | spec pending |
| 6 | C-16 | **(NEW)** write-attribution sentinel + hook | M | 1 (F-D6-005a) | 1 | **5.0** | ADR-001 supplement | needs design |
| 7 | C-01 | TOOL(shell) sandbox (PR-1.1) | M | 3 (F-D3-001, F-D7-001, F-D8-008) | 0 | **7.5** | ADR-001 main | spec pending |
| 8 | C-06 | resume / compaction (Phase 1 + Phase 2) | S+L | 2 (F-D9-022, F-D9-004) | 4 (F-D9-002, F-D9-008, F-D9-011, F-D9-013) | **5.5** | ADR-006 | spec pending |
| 9 | C-08 | Core Rule enforcer fill-in (5 missing) | M | 4 (F-D6-001, F-D6-007, F-D8-002, F-D8-003) | 3 | **6.0** | per-rule ADRs | needs design |
| 10 | C-05b | full predicate-vocab BUILTINS (ADR-005b) | M | 2 (F-D4-017, F-D4-017a) | 0 | **4.5** | ADR-005b | needs design |
| 11 | C-03 | Deprecation policy scaffold + log + cron | M | 0 | 2 + 4 MINORs | **4.4** | ADR-003 | spec pending |
| 12 | C-04 | Mainline composition (workflow ↔ orchestrator) | S | 0 | 4 (F-D4-002, F-D4-011, F-D4-014, F-D4-015) | **6.5** | ADR-007 | spec pending |
| 13 | C-14 | Doc-drift / live-count pipeline | M | 0 | 5 MINORs (F-D3-016/017, etc.) | **2.5** | D-XC-001 | low priority |
| 14 | C-15 | Worst error messages (depends on C-02) | S | 0 | 3 MINORs | **4.0** | depends C-02 | post-C-02 |
| — | C-10 | Dispatcher wiring (explain/simulate) | M | 0 | 4 | route | → axon-wiring-gaps |
| — | C-11 | Catalog grooming pass | XL | 0 | 5 + many MINORs | route | → axon-cleanup |
| — | C-13 | Synapse ranker correctness | M | 0 | 3 | route | → axon-ranker-v2 |
| — | (new) | F-D6-005b harness EXEC drift | — | 1 | 0 | route | → axon-copilot-anchor |
| — | (new) | F-D4-016 DAG auto-emit | — | 0 | 1 | route | → firing-dag-missing |
| — | (new) | F-D5-009 + F-D6-016 drift-log gaps | — | 0 | 0 + 2 MINORs | route | → axon-copilot-anchor |

## Sequenced PR roadmap (top-tier first)

### Tier 1 — S-sized, ADR-grounded, low-risk (ship first; no dependencies)
| # | PR | Cluster | ADR | Effort | Status |
|---|---|---|---|---|---|
| 1 | PR-12.1 enforce.py user: bypass fix | C-12 | ADR-001 sibling | S | ✅ spec done |
| 2 | PR-7.1 context.py L:host-model | C-07 | align master | S | ✅ spec done |
| 3 | PR-2.1 fail_render.py tool | C-02 | ADR-002 | S | spec needed |
| 4 | PR-5.1 workflow-run step-count + ctx | C-05a | ADR-005a | S | spec needed |
| 5 | PR-1.2 R9 realpath hardening | C-12 sibling | ADR-001 | S | spec needed |
| 6 | PR-9.1 menu/quickstart/help dedupe | C-09 | none | S | spec needed |
| 7 | PR-9.2 r_reasoning_trace dead-bottom removal | C-09 | none | S | spec needed |
| 8 | PR-6.1 session.recover() wired to response gate | C-06 phase 1 | ADR-006 | S | spec needed |
| 9 | PR-7.1 ↳ context.py accumulator reset on boot | C-07 | ADR-006 Phase 1 | S | spec needed |

### Tier 2 — M-sized, ADR-grounded (after Tier 1 lands)
| # | PR | Cluster | ADR | Effort |
|---|---|---|---|---|
| 10 | PR-1.1 tools/shell.py sandbox | C-01 | ADR-001 | M |
| 11 | PR-2.2..2.4 fail_render lang shorthand + 5-prog migration | C-02 | ADR-002 | M |
| 12 | PR-3.1..3.3 deprecation log + cron + initial sweep | C-03 | ADR-003 | M |
| 13 | PR-4.1..4.3 workflow-run light bridge | C-04 | ADR-007 | M |
| 14 | PR-6.2 R_PHASE_TRACKED + program audit | C-06 phase 2 | ADR-006 | M |
| 15 | PR-16.1 write-attribution sentinel + hook | C-16 | ADR-001 supplement | M |

### Tier 3 — L-sized, design-decision-pending
| # | PR | Cluster | Blocked on |
|---|---|---|---|
| 16-20 | PR-8.1..8.5 Core Rule enforcers (5 missing) | C-08 | needs ADR-008 per-rule (or batch) |
| 21-24 | PR-5b.1..5b.4 register full predicate vocab | C-05b | ADR-005b accept |
| 25-30 | PR-14.* doc-drift / live-count pipeline | C-14 | D-XC-001 |
| — | (deferred until ADR-004 accepted) phase-transition gate | — | ADR-004 user decision |

## Dependency graph (S-tier only)

```
PR-12.1 ───┐                          ← independent (enforce.py)
PR-7.1  ───┤                          ← independent (context.py)
PR-2.1  ───┼─→  PR-2.2 → PR-2.3 → PR-2.4   ← C-02 fail_render chain
PR-5.1  ───┤                          ← independent (workflow-run guard)
PR-1.2  ───┤                          ← independent (R9 realpath)
PR-9.1  ───┤                          ← independent (file dedupe)
PR-9.2  ───┤                          ← independent (dead code removal)
PR-6.1  ───┘                          ← independent (recover wire-up)
```
**All 8 Tier-1 PRs can ship in parallel.** No internal dependencies among them.

## Coverage map (which findings each PR closes)

| PR | BLOCKERs | MAJORs | MINORs/NITs | Demands |
|---|---|---|---|---|
| PR-12.1 | F-D7-007a, F-D7-007 | — | — | — |
| PR-1.2 | F-D8-001 (4 vec) | — | — | D-D8-017 |
| PR-7.1 | F-D9-001 | F-D9-005, F-D9-015 | — | D-D7-002 |
| PR-2.1 | — | F-D2-001, F-D2-007 | F-D2-016, F-D6-013, F-D6-015 | D-D2-018, D-D2-019 |
| PR-5.1 | F-D4-003 | F-D4-008, F-D4-018 | — | — |
| PR-9.1 | F-D1-001, F-D1-002, F-D1-003 | F-D1-013 | F-D1-014, F-D3-017 | D-D1-001 |
| PR-9.2 | — | F-D6-011 | F-D3-016 | — |
| PR-6.1 | F-D9-022, F-D9-004 | — | F-D9-023 | — |
| **Tier-1 totals** | **9 BLOCKERs** | **7 MAJORs** | **8 MINORs** | **6 demands** |

Out of ~24 BLOCKERs total, **Tier-1 closes 9 (38%) in S-sized, low-risk, ADR-grounded work**.

## Open design decisions remaining (post-Tier-1)

1. **ADR-004** (phase-transition invariant gate) — drives Tier-2 PR-12/15 design. User accept/refine needed.
2. **ADR-005b expansion** (already documented in `_adrs.md` line 200+) — accepted in scope but PR design pending.
3. **C-08 per-rule ADR pattern**: 5 missing enforcers (Rules 1, 4, 5, 6, 8, 10, 12). Each could be its own micro-ADR or a single batch ADR-008. Recommend batch — they share enforcement strategy (output-text scan + state-key check).
4. **C-16 design** (write-attribution sentinel): file-header `<!-- AXON-MANAGED: writer=X; do-not-write-without-program -->` + pre-commit hook + edit-time wrapper. Implementation depth needs ADR-001 supplement.

## Cross-project handoffs (axon-polish stops here, other projects take over)

| Routed-out finding | Target project | What axon-polish hands over |
|---|---|---|
| F-D6-005b EXEC silent simulation | axon-copilot-anchor | finding + reference-doc identity/01-identity-and-harness.md |
| F-D4-016 DAG auto-emit | firing-dag-missing | finding + cross-ref to ADR-004 (firing-dag-missing already adjacent) |
| F-D5-009, F-D6-016 drift-log gaps | axon-copilot-anchor | findings + drift-log path discrepancy |
| C-10 explain/simulate wiring | axon-wiring-gaps | F-D1-004 + cross-ref + 5-readers-0-writers method |
| C-11 catalog grooming | axon-cleanup | F-D2-005 (42 dead files) + F-D3-014 (118 stubs) + ADR-003 30-day policy |
| C-13 ranker correctness | axon-ranker-v2 | F-D3-004 + F-D4-005 + F-D4-013 |

## Reference-doc-driven insights (what the docs surfaced that flaws missed)

| Insight | Source doc | Action |
|---|---|---|
| Three identity axes (cognition-frame vs harness vs model) clearly separated | identity/ | adopt as the kernel R12-supplement vocabulary; cite in ADR-008 enforcer designs |
| Compiler subsystem is 82% placeholder | programs/ | C-11 (cleanup) should compress real compileds OR drop the artifact-existence test |
| 174/182 synapse blocks auto-inferred (only 1 hand-authored: axon-reanchor) | programs/ | F-D5-005 underestimated impact; metadata is structurally noise |
| Composition-only invariant (RETRO lesson R12) | workflows/ | Future ranker work must be pure (state, candidate) → ban orchestrator changes in C-13 |
| Op→CLI binding table (PR-CC-201, PR-CD-201) is load-bearing | identity/ | Adopt verbatim for any new persona contract or harness addition |

## Implementation cadence proposal

**Sprint 0 — preparation (1 session)**
- User decides ADR-004
- This master plan finalizes

**Sprint 1 — Tier-1 ship (3-5 days, parallelizable)**
- All 8 Tier-1 PRs shipped concurrently
- Closes 9 BLOCKERs, 7 MAJORs, 8 MINORs, 6 demands
- Phase 4-implement begins with `code-dev pr 12.1` (or any of the 8)

**Sprint 2 — Tier-2 (1-2 weeks)**
- Tier-2 PRs (M-sized; depends on Tier-1 patterns)
- Closes most of the BLOCKER + MAJOR remainder

**Sprint 3 — Tier-3 + cross-project handoffs (2-3 weeks)**
- Tier-3 (L-sized, design-pending)
- Hand-off package to axon-cleanup / axon-wiring-gaps / axon-ranker-v2 / axon-copilot-anchor / firing-dag-missing
- axon-polish marks status: done

## Exit criteria (when axon-polish is "done")
- [ ] All Tier-1 PRs landed (9 BLOCKERs closed)
- [ ] Tier-2 PRs landed (architectural BLOCKERs closed)
- [ ] Cross-project handoffs delivered
- [ ] Reference docs reviewed by ≥1 other AXON user (acceptance: "I could explain AXON to a new dev using these")
- [ ] Final `_retro.md` written with lessons learned

## Status at this writing
- Master plan v2 (this file) — drafted 2026-05-22
- Tier-1 PR specs drafted: 2 of 8 (PR-12.1, PR-7.1)
- Pending Tier-1 PR specs: 6 (PR-1.2, PR-2.1, PR-5.1, PR-6.1, PR-9.1, PR-9.2)
- ADR-004: still PROPOSED
- ADR-005b: accepted (scope expanded)
- Implementation: not started (waiting on user)
