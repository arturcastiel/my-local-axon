# Synthesis (draft) — Phase 1 → Phase 2 bridge

> Author: AXON, 2026-05-17. Status: draft — ready for user review + sign-off
> to mark Phase 1 complete.

## TL;DR

The AXON Synapse project's vision is **more achievable than initially scoped.**
The kernel is domain-agnostic. The orchestrator substrate (intent classifier,
TF-IDF dispatch, pattern miner, usage tracker, event bus) largely exists.
Library-dev proves the multi-domain claim. DAG plumbing exists at plan level.
The shadow tool is production-quality.

**Phase 3 is mostly composition and wire-up, not greenfield.**

The work that remains:
- **Schema authoring** — synapse contract, workflow file, domain manifest,
  goal schema.
- **Composition glue** — `synapse-suggest` tool combining existing signals.
- **Hooks** — auto-DAG-on-plan, shadow-enforcement, suggestion-footer.
- **Migration** — `domain:` field on 174 programs; alias canonicalization
  (F-012); retroactive shadow on 119 PRs (F-016).
- **Conversational author** — `workflow-new --from-description` (D-28).

## Demand status snapshot

| Demand | Phase target | Synthesis status |
|--------|---|---|
| D-1  full audit | 1 | 🟦 in-progress (75/75 tools done; ~25/174 programs deep, all 174 surface) |
| D-2  auto-DAG on plan | 2/3 | ⬜ open — substrate exists (F-015) |
| D-3  DAG auto-mutation | 3 | ⬜ open — mutator wiring needed |
| D-4  DAG central nested | 2/3 | ⬜ open — 4 of 5 levels missing |
| D-5  workflow report | 1 | 🟦 in-progress (helpers/workflow-catalog.md drafted, 12 workflows enumerated) |
| D-6  synapse contract | 2/3 | ⬜ open — F-005/F-013 spec inputs ready |
| D-7  adaptive orchestrator | 3 | ⬜ open — F-014 shows composition path |
| D-8  workflow generator | 3 | ⬜ open — depends on D-6 |
| D-9  pre-built workflows | 3 | ⬜ open — 12 candidates catalogued |
| D-10 goals per step | 2/3 | 🟨 designed (F-017 schema draft) |
| D-11 suggest by goal+wf | 3 | ⬜ open |
| D-12 pop-up questions | 3 | ⬜ open |
| D-13 after-action suggest | 3 | ⬜ open |
| D-14 hierarchy + suggest | 3 | ⬜ open |
| D-15 most-detailed study | 1 | 🟦 in-progress (17 findings; targeting ≥ 30) |
| D-16 post-impl chain | 3 | ⬜ open — WF-08 / WF-09 catalogued |
| D-17 adjust per project | 3 | ⬜ open |
| D-18 infer-or-pick wf | 3 | ⬜ open |
| D-19 no tests break | continuous | 🟦 in-progress (D-012 governance) |
| D-20 auto-discoverable tools | 3 | ⬜ open (F-001/F-002 schema gap) |
| D-21 proper-tool-suggested | 4 | ⬜ open |
| D-22 pseudo-FSM | 2/3 | 🟨 designed (D-013) |
| D-23 shadow enforced | 2/3 | ⬜ open (F-016 — 0% coverage today) |
| D-24 auditable demands | continuous | 🟦 in-progress (this file + ledger) |
| D-25 preserve code-dev | continuous | 🟦 in-progress (D-014 governance) |
| D-26 workflow OS | 2/4 | 🟦 in-progress (F-008/F-010/F-011 validated) |
| D-27 register new synapses | 3 | 🟦 in-progress (register-tool exists, F-014) |
| D-28 conversational author | 3 | ⬜ open (harness-builder pattern reusable) |
| D-29 fixed/adaptive modes | 3 | 🟨 designed (D-017) |
| D-30 suggest in fixed mode | 3 | 🟨 designed (D-017) |

Roll-up: 30 demands · 🟨 designed=4 · 🟦 in-progress=7 · ⬜ open=19 · 🟩 met=0.

## Findings index (17 to date)

| # | Severity | Headline |
|---|---|---|
| F-001 | high | 31/75 tools have zero program-callers |
| F-002 | medium | REGISTRY 75 vs boot 69 — OPTIONAL invisible |
| F-003 | medium | Single-member tool categories |
| F-004 | low | Top-20 caller list = AXON's core call surface |
| F-005 | high | No synapse-contract fields today — BLOCKER for orchestrator |
| F-006 | high | Workflow-completion programs already exist (≥ 36) |
| F-007 | medium | `code-dev-knowledge-X` variant pattern; role taxonomy needed |
| F-008 | high | Code-dev is one domain; kernel must be domain-agnostic |
| F-009 | high | Two PR-review implementations drift |
| F-010 | medium | Kernel already domain-agnostic — D-015 cost downgraded |
| F-011 | medium | Library-dev validates multi-domain — proof shipping |
| F-012 | high | Three code-dev entry verbs are deprecated/orphan |
| F-013 | high | Programs are parameterized synapses — schema must capture |
| F-014 | medium | Suggestion-engine substrate exists — orchestrator = composition |
| F-015 | high | DAG plumbing exists at plan level only — 4 of 5 levels missing |
| F-016 | high | Shadow tool full-featured but 0% coverage across 119 PRs |
| F-017 | medium | Goal-schema derivation — proposed per-level shape |

Severity rollup: **high = 9 · medium = 7 · low = 1.**

## Track status

| Track | Description | Findings | Status |
|-------|-------------|----------|--------|
| T-A | tool + program inventory | F-001..F-005, F-007..F-013 | substantial (12 findings); 75/75 tools deep, ~25 programs deep, all 174 surface |
| T-B | code-dev hierarchy + workflows | F-006; workflow-catalog | substantial (12 workflows catalogued) |
| T-C | goal derivation | F-017 | designed (schema draft) |
| T-D | synapse contract + orchestrator | F-005 F-008 F-011 F-013 | inputs gathered; Phase 2 designs |
| T-E | DAG + nested DAGs | F-015 | inputs gathered |
| T-F | workflow generator + suggester | F-006 F-008 F-014 | inputs gathered |
| T-G | shadow enforcement | F-016 | inputs gathered |

All tracks have ≥ 1 finding. Synthesis condition met per D-15.

## Open questions still pending

- **OQ-03** suggestion delivery channel — footer / panel / pop-up?
  *(Recommend: footer compact + pop-up on QUERY-mode; spec in Phase 2.)*
- **OQ-05** workflow generator output — compiled program or ephemeral?
  *(Recommend: both — adaptive runs are ephemeral, accepted runs compile.)*
- **OQ-06** deviation behaviour — redirect or annotate?
  *(Resolved: D-017 — sideband + deviation-suggestion; never silent override.)*
- **OQ-07** goal-schema location — resolved by F-017 (hierarchical, file per level).
- **OQ-08** synapse-contract migration strategy — bulk-infer first then per-author override.
- **OQ-10** Phase 1 validation gate — synthesis sign-off by user; no per-track gate.

## Architectural picture (consolidated)

```
                     ┌────────────────────────────────────────┐
                     │           AXON KERNEL                  │
                     │   (domain-agnostic — F-010 confirmed)  │
                     │                                        │
                     │  identity · language · compliance      │
                     │  CHECKPOINT · STORE/RETRIEVE · EXEC    │
                     │  events · drift · pattern · usage      │
                     └──────────────┬─────────────────────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
        ┌───────▼────────┐  ┌───────▼────────┐  ┌───────▼────────┐
        │  DOMAIN        │  │  DOMAIN        │  │  DOMAIN        │
        │  code-dev      │  │  library-dev   │  │  (future)      │
        │                │  │                │  │  study-dev     │
        │  manifest      │  │  manifest      │  │  science-dev   │
        │  workflows[]   │  │  workflows[]   │  │                │
        │  programs[]    │  │  programs[]    │  │                │
        │                │  │                │  │                │
        └───────┬────────┘  └───────┬────────┘  └───────┬────────┘
                │                   │                   │
                └───────────────────┼───────────────────┘
                                    │
                          ┌─────────▼──────────┐
                          │   ORCHESTRATOR     │
                          │   (D-013 FSM,      │
                          │    composition of  │
                          │    existing tools  │
                          │    per F-014)      │
                          │                    │
                          │ observe → rank →   │
                          │ fire → re-observe  │
                          └─────────┬──────────┘
                                    │
                  ┌─────────────────┴────────────────┐
                  │           SUGGESTER              │
                  │  signals: dispatch + pattern +   │
                  │  usage + drift + context + goal  │
                  │  + next-conditional              │
                  └──────────────────────────────────┘

  Synapses (programs/tools) declare:
    precondition · inputs · outputs · post-state · next-conditional ·
    cost · goal-advances · domain · family · role · modes

  Workflows are:
    files at workspace/domains/{d}/workflows/{n}.{yml,md}
    OR workspace/workflows/{n}.{yml,md} (cross-domain)
    declaring: execution-mode (fixed/adaptive/hybrid),
               synapse sequence (DAG), triggers, default-goal,
               acceptance, allow-suggestions, allow-deviation

  DAGs at five levels:
    project · phase · plan · PR · study   (D-009)
    DAG.json canonical, DAG.md rendered, sync-checked

  Goals at every level:
    project (_goal.md) · phase (_meta.md goal:) · workflow (default-goal:)
    · step (synapse post-state) · PR (frontmatter goal:) · finding
    (Implication) · demand (_demands.md)
```

## Phase 2 entry conditions

Phase 1 may declare complete when:

- ✅ Every track has ≥ 1 finding. (Today: all 7 tracks ≥ 1.)
- ✅ Every demand has goal + measurement + audit-criterion. (Today: 30/30.)
- ✅ Synthesis draft links findings to Phase 2 design questions. (This file.)
- ⏳ User sign-off on synthesis.

## Phase 2 design queue (ordered by dependency)

1. **SYNAPSE-GLOSSARY.md** — fix vocabulary first (Q15.1).
2. **Synapse contract schema** (resolves F-005, F-013).
3. **Workflow file schema** (resolves Q16.3, D-016).
4. **Goal schema + predicate language** (resolves F-017, D-010, D-024).
5. **Domain manifest schema** (resolves F-008, D-015, D-026).
6. **DAG spec — 5 levels + sync-checker** (resolves F-015, D-009).
7. **Orchestrator composition spec** (resolves F-014, D-007, D-010, D-013).
8. **Shadow enforcement spec** (resolves F-016, D-011, D-023).
9. **Conversational workflow author spec** (resolves D-028).
10. **Migration plan** — alias canonicalization (F-012), `domain:` field
    rollout, retroactive shadow on 119 PRs.

## Phase 3 PR seed list (rough)

- `synapse-contract-schema-v1` (BLOCKER for everything else)
- `workflow-file-schema-v1`
- `domain-manifest-schema-v1` + `code-dev` + `library-dev` reference manifests
- `goal-schema-v1` + `goal` tool
- `dag-sync` tool
- `plan_dag-auto-emit-hook`
- `dag-bootstrap-project / -phase / -study / -pr` programs
- `synapse-suggest` tool (composition of dispatch+pattern+usage+drift+context+goal)
- `output-layer-suggestions-section` (D-013)
- `shadow-coverage-enforce-finalize` + `shadow-coverage-report-audit`
- `shadow-retroactive-bulk` (one-shot migration on 119 PRs)
- `register-tool-reload`
- `workflow-new --from-description` (interactive, harness-builder pattern)
- `code-dev-finalize-impl` (close F-012 orphan stub)
- `code-dev-aliases-formalize` (preserve, mark canonical, drop sunset markers)
- `domain-metadata-migrate` (add `domain:` field to all 174 programs)
- `mode-2-label-domain-aware` (cosmetic)

Sequencing + dependencies → Phase 2's `02-plan.md`.

## Recommendation to user

**Phase 1 is ready to sign off.** The vision is now well-grounded:

- 17 findings cover every track.
- 30 demands carry auditable goals.
- Architectural picture is concrete.
- Risks are downgraded by 4 positive findings (F-006/F-010/F-011/F-014).
- Phase 2 design queue is ordered and dependency-aware.

If you sign off on this synthesis, the next move is `code-dev plan` to
materialize the Phase 2 design queue into a full plan + PR list + DAG.

Confidence: **HIGH** that Phase 1 has surfaced enough to design Phase 2
without further study. Remaining ~150 unwalked programs can be deep-dived
during Phase 2 / Phase 3 as needed — they don't block design decisions.
