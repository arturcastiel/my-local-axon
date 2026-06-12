# PR List — Axon Plus
Updated: 2026-06-11  ·  Total PRs: 27 (firm) · +2 conditional in 02-prs.deferred.md

## PR-001 — A: token bench — scenario runner + baseline report
- **Status:** merged (d5a8ce8, 2026-06-11)
- **Phase:** 0-instrument-floor
- **Complexity:** M
- **Scope:** tools/token_bench.py (scenario defs: boot-menu, pr-cycle replay, study, scripted chat) · tokenizer reuse · baseline report doc · tests
- **Depends on:** none
- **Spec:** 03-prs/PR-001.md (not written yet)

## PR-002 — G: execution receipts — tool envelopes + verifier cross-check
- **Status:** merged (81ab00e, 2026-06-11)
- **Phase:** 0-instrument-floor
- **Complexity:** M
- **Scope:** _axon_response/run.py envelope nonce · verify.py receipt rule · tests
- **Depends on:** none
- **Spec:** 03-prs/PR-002.md (not written yet)

## PR-003 — G: mechanical menu-render check
- **Status:** merged (4fca0ab, 2026-06-11)
- **Phase:** 0-instrument-floor
- **Complexity:** S
- **Scope:** verify.py output rule (menu dispatched → sections present, BLOCK) · enforcement posture doc · tests
- **Depends on:** none
- **Spec:** 03-prs/PR-003.md (not written yet)

## PR-004 — H: doc census report
- **Status:** delivered (analysis artifact, 2026-06-11)
- **Phase:** 0-instrument-floor
- **Complexity:** S
- **Scope:** census tool/program over all *.md (owner/purpose/freshness) · adjoint-class candidate list · report only
- **Depends on:** none
- **Spec:** 03-prs/PR-004.md (not written yet)

## PR-005 — F: fix census discrepancies (residue-lint 0-vs-27 · prompt-log no-write)
- **Status:** delivered (investigation, 2026-06-11 — 1 probe error corrected, 1 dead-wiring finding routed to W5)
- **Phase:** 0-instrument-floor
- **Complexity:** S
- **Scope:** investigate + fix both · regression tests
- **Depends on:** none
- **Spec:** 03-prs/PR-005.md (not written yet)

## PR-006 — A: boot/menu state aggregation (~10 probes → 1 call)
- **Status:** merged locally (10bd0aa, 2026-06-12 — push pending: GitLab read-only)
- **Phase:** 1-tokens-round1
- **Complexity:** M
- **Scope:** axon-state snapshot extension · menu program consumes it · equivalence test: byte-identical menu
- **Depends on:** PR-001
- **Spec:** 03-prs/PR-006.md (not written yet)

## PR-007 — A: compile pipeline pilot (top-5 programs + equivalence harness)
- **Status:** merged locally (db0c2c8, 2026-06-12 — push queued)
- **Phase:** 1-tokens-round1
- **Complexity:** M
- **Scope:** usage suggest → top-5 · compiler run · behavior-equivalence fixtures · savings measured
- **Depends on:** PR-001
- **Spec:** 03-prs/PR-007.md (not written yet)

## PR-008 — A: --brief envelopes for heaviest agent-read tools
- **Status:** merged locally (d71cba4, 2026-06-12 — push queued)
- **Phase:** 1-tokens-round1
- **Complexity:** S
- **Scope:** boot/cron/health envelope slimming · TEE pattern · full detail on demand
- **Depends on:** PR-001
- **Spec:** 03-prs/PR-008.md (not written yet)

## PR-009 — A: program shadows for stable neurons (fallback lever)
- **Status:** merged locally as SECTIONAL READS re-scope (14e9d47, 2026-06-12 — checkpoint-w1)
- **Phase:** 1-tokens-round1
- **Complexity:** M
- **Scope:** hash-gated shadow of program sources · warm-boot reads · equivalence
- **Depends on:** PR-007
- **Spec:** 03-prs/PR-009.md (not written yet)

## PR-010 — C: convergence contract schema + runner enforcement
- **Status:** merged locally (b1cc896, 2026-06-12 — push queued)
- **Phase:** 2-convergence-goals
- **Complexity:** M
- **Scope:** spec: target predicate/metric/budget · runner enforces · halt report · loop-receipts per iteration
- **Depends on:** none
- **Spec:** 03-prs/PR-010.md (not written yet)

## PR-011 — C: loop designer (interrogate → spec → simulate)
- **Status:** merged locally (20071a9, 2026-06-12 — push queued)
- **Phase:** 2-convergence-goals
- **Complexity:** M
- **Scope:** conversational designer program · generates contract · simulate before run
- **Depends on:** PR-010
- **Spec:** 03-prs/PR-011.md (not written yet)

## PR-012 — D: goal-define mode (intake→organize→interrogate→harden)
- **Status:** merged locally (1132184, 2026-06-12 — push queued)
- **Phase:** 2-convergence-goals
- **Complexity:** M
- **Scope:** study --mode=goals + standalone · this session = prototype fixture · acceptance per goal
- **Depends on:** none
- **Spec:** 03-prs/PR-012.md (not written yet)

## PR-013 — D: scoped-constraints registry + auto-routing + phase checklists
- **Status:** merged locally (c14f2e7, 2026-06-12 — push queued)
- **Phase:** 2-convergence-goals
- **Complexity:** S
- **Scope:** global ledger (gate-readable) · goal-define routes scope · phase-entry checklist render
- **Depends on:** PR-012
- **Spec:** 03-prs/PR-013.md (not written yet)

## PR-014 — F: quality-loop program (scan battery → triage → prepared diffs)
- **Status:** not-started
- **Phase:** 3-quality-discover
- **Complexity:** M
- **Scope:** generate-then-drain · report-only mode · weekly cron · receipts
- **Depends on:** PR-010
- **Spec:** 03-prs/PR-014.md (not written yet)

## PR-015 — F: autonomy ramp gate (3 green cycles → S-fix live)
- **Status:** not-started
- **Phase:** 3-quality-discover
- **Complexity:** S
- **Scope:** ramp config + breaker · S-fix criteria (one-file, tested, crucible-green, undoable)
- **Depends on:** PR-014
- **Spec:** 03-prs/PR-015.md (not written yet)

## PR-016 — B: situation-trigger engine (≤1 hint/response, deduped)
- **Status:** not-started
- **Phase:** 3-quality-discover
- **Complexity:** M
- **Scope:** signal detectors (grep streak, repeat steps, N graph queries) · dedup store · why+how-to render
- **Depends on:** none
- **Spec:** 03-prs/PR-016.md (not written yet)

## PR-017 — B: activate orchestrator footer (≤3 ranked + why + how-to)
- **Status:** not-started
- **Phase:** 3-quality-discover
- **Complexity:** S
- **Scope:** PR-112 machinery live · noise ceiling enforced
- **Depends on:** none
- **Spec:** 03-prs/PR-017.md (not written yet)

## PR-018 — B: dispatch-phrases + cross-links full rollout
- **Status:** not-started
- **Phase:** 3-quality-discover
- **Complexity:** M
- **Scope:** code-dev/workflow/mode surface · dispatch fixture suite extended
- **Depends on:** none
- **Spec:** 03-prs/PR-018.md (not written yet)

## PR-019 — E: synapse-suggester accuracy (measure wrong-rate, fix, pin)
- **Status:** not-started
- **Phase:** 4-workflow-designer
- **Complexity:** M
- **Scope:** wrong-suggestion fixtures · evidence fix · regression pins
- **Depends on:** none
- **Spec:** 03-prs/PR-019.md (not written yet)

## PR-020 — E: workflow run visibility (narrated step blocks)
- **Status:** not-started
- **Phase:** 4-workflow-designer
- **Complexity:** M
- **Scope:** per-step state block: program · phase · why-chosen · next
- **Depends on:** none
- **Spec:** 03-prs/PR-020.md (not written yet)

## PR-021a — E: designer dialogue → generated workflow yml + validate/simulate
- **Status:** not-started
- **Phase:** 4-workflow-designer
- **Complexity:** M
- **Scope:** interrogation flow · yml generation · schema validation · simulate
- **Depends on:** PR-011, PR-019
- **Spec:** 03-prs/PR-021a.md (not written yet)

## PR-021b — E: synapse-program generation + tests-or-DRAFT + auto-register
- **Status:** not-started
- **Phase:** 4-workflow-designer
- **Complexity:** M
- **Scope:** program scaffolds · generated contract tests or DRAFT status (R13) · registry wiring
- **Depends on:** PR-021a
- **Spec:** 03-prs/PR-021b.md (not written yet)

## PR-024 — G: weak-tier strict overlay (harness-declared model → overlay)
- **Status:** not-started
- **Phase:** 5-tiers-docs-bookend
- **Complexity:** M
- **Scope:** tier detection via harness contract · overlay file: redundant imperatives, ack tokens
- **Depends on:** PR-002
- **Spec:** 03-prs/PR-024.md (not written yet)

## PR-025 — G: conformance scorecard per model/harness
- **Status:** not-started
- **Phase:** 5-tiers-docs-bookend
- **Complexity:** M
- **Scope:** temptation scenarios (menu render, mimic-vs-execute, long output) · dual-agent machinery
- **Depends on:** PR-024
- **Spec:** 03-prs/PR-025.md (not written yet)

## PR-026 — H: stale sweep execution (adjoint 6 files + census results)
- **Status:** not-started
- **Phase:** 5-tiers-docs-bookend
- **Complexity:** M
- **Scope:** owner-confirmed deletions · archive not silent-delete · update or retire
- **Depends on:** PR-004
- **Spec:** 03-prs/PR-026.md (not written yet)

## PR-027 — H: project doc floor + doc index, freshness-wired
- **Status:** not-started
- **Phase:** 5-tiers-docs-bookend
- **Complexity:** M
- **Scope:** every project: filled _meta+study/plan · doc map/index · freshness reconciler
- **Depends on:** PR-026
- **Spec:** 03-prs/PR-027.md (not written yet)

## PR-028 — A: targets sign-off + final vs-baseline measurement
- **Status:** not-started
- **Phase:** 5-tiers-docs-bookend
- **Complexity:** S
- **Scope:** re-run bench suite · vs baseline · owner signs targets met
- **Depends on:** PR-006, PR-007, PR-008, PR-009
- **Spec:** 03-prs/PR-028.md (not written yet)
