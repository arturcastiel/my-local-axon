# Decisions (ADRs) — 2-design

ADRs inherit from Phase 1 (D-001 .. D-017). New ADRs in this phase get IDs
D-018+.

## D-018 — 2026-05-17 — Glossary is the singular vocabulary source
**Context.** Schemas downstream of glossary cited different terms
inconsistently in Phase 1.
**Decision.** `SYNAPSE-GLOSSARY.md` is authoritative. Every spec carries
`glossary: SYNAPSE-GLOSSARY v1` front-matter. Edits go through ADR + version
bump + downstream sweep.
**Consequences.** Phase 3 PR-101 ships glossary first. All subsequent PRs
cite version explicitly.

## D-019 — 2026-05-17 — DAG.md is one-way rendered output; hand-edits ignored
**Context.** OQ-04 / D-006 considered both files as sources of truth.
F-015 + design work concluded round-trip parsing is too brittle.
**Decision.** `DAG.json` is canonical. `DAG.md` is auto-rendered from JSON
on every mutation. Hand-edits to MD are discarded on next render.
Users edit via the `dag` tool mutators or by editing JSON directly.
**Consequences.** Simpler `dag-sync` semantics; no md→json reverse parser
needed. Document the rule prominently in the DAG-SPEC doc and dag-tool help.

## D-020 — 2026-05-17 — Synapse-contract: bulk-infer-first, declared override progressive
**Context.** OQ-08 + F-013 — 174 programs to characterise. Hand-author at scale
not viable.
**Decision.** `synapse-infer` runs on every program/tool, emits a default
contract derivable from headers + body ops. Authors override progressively
as they touch each file. No deadline for full hand-authoring.
**Consequences.** Phase 3 PR-107 ships inference; PR-108 bulk-applies.
Subsequent PRs hand-author contracts only where inferred quality is
insufficient (validated by spot-check).

## D-021 — 2026-05-17 — Ranker is rule-based for v1; learning is Phase 4+
**Context.** Phase 1 ruled out learned ranker (per `_goal.md` non-goals).
**Decision.** PR-109 ships a rule-based combiner with default weights in
`L:ranker-weights`. Tuning happens by hand. Phase 4 candidate PR-152 may
introduce learning from lived data; not in Phase 3 scope.
**Consequences.** No ML dependencies in Phase 3. Top-1 hit rate target
relaxed to 70 % for PR-109; 90 % target deferred to Phase 4.

## D-022 — 2026-05-17 — Shadow-grace flag for backwards compatibility
**Context.** F-016 — 0 / 119 shadow coverage today. Hard-fail audit
immediately on Phase 3 ship = breaking change for all dev-projects.
**Decision.** `L:shadow-enforcement-strict` flag (default `false`) gates
the hard fail. PR-116 (retroactive migration) flips it to `true` on
completion. Before that, audit reports coverage but does not fail.
**Consequences.** Phase 3 lands without regressions; coverage cleanup
happens in a single deterministic PR.

## D-023 — 2026-05-17 — Suggestion delivery defaults — footer + opt-in panel
**Context.** OQ-03 — suggestion delivery channel.
**Decision.** Default channel: `footer` (compact, one-line top-1).
`panel` and `popup` available when workflow opts in via
`suggestion-channel: [footer, panel]` field. `popup` reserved for
QUERY-mode (inference-mode ≤ 2).
**Consequences.** Output-layer change (PR-112) ships with footer; panel
is a per-workflow opt-in; no kernel change for popup beyond existing
QUERY plumbing.

## D-024 — 2026-05-17 — Workflow-compile is Phase 4
**Context.** OQ-05 — compiled vs ephemeral workflow output.
**Decision.** Phase 3 ships ephemeral execution + persistent workflow
file authoring. Compilation cache is Phase 4 (PR-153) for perf.
**Consequences.** No `workspace/workflows/compiled/` directory in Phase 3.

## D-026 — 2026-05-17 — Biology-correct vocabulary rename (closes OP-01)
**Context.** User: "you pointed the names metaphor error". Original
"each program = synapse" inverted biology — synapses are connections,
not nodes.
**Decision.** Vocabulary rename in v2 glossary:
  - **neuron** = firing unit (program or tool) — was "synapse"
  - **synapse** = weighted edge (`next-conditional`) between neurons
  - **axon** = the orchestrator (matches project name)
  - **dendrite** = receiver (precondition / input) — for prose only
Backwards-compat: `synapse` accepted as alias for `neuron` in user input
and external docs forever. Spec/schema fields canonical-named.
**Consequences.** Glossary v2 ships. neuron-contract supersedes
synapse-contract. `next-conditional:` → `synapses:`. File renames
deferred to Phase-3 PR-101a (cosmetic). 

## D-027 — 2026-05-17 — Predicate language v1.1 formalized (closes FL-01..FL-03, GAP-06)
**Decision.** Formal grammar with precedence (AND > OR, NOT prefix,
implication right-assoc, comparison non-associative). Strict type
system with explicit coercion. Safe-eval null mode (default; null = false
in predicate context); opt-in strict-null mode. Snapshot semantics:
entry-time default, continuous opt-in.
**Consequences.** New standalone spec `predicate-language-v1.1`. PR-102
(predicate tool) implements the formal grammar. 50-fixture corpus seeded.

## D-028 — 2026-05-17 — Ranker tie-break ladder (closes FL-04)
**Decision.** Six-level tie-break ladder when raw-scores within ±0.05:
canonical-status → recency → role-match → cost → goal-alignment →
lexicographic name. Lexicographic terminal ensures reproducibility.

## D-029 — 2026-05-17 — Zero-candidate fallback (closes FL-05)
**Decision.** When `rank-candidates()` returns empty: TF-IDF goal-keyword
match against full registry → top-3 surfaced. If still empty, QUERY
offering register-tool / workflow-new / free-text routes. Never silent-hang.

## D-030 — 2026-05-17 — Cold-start ranker bootstrap (closes FL-07)
**Decision.** First 20 fires of a fresh session: frequency-prior from
REGISTRY `invocation_source` (program=0.5, cli=0.3, kernel=0.0). After
20 user-confirmed fires, full ranker active. Conversational author
gets parallel cold-start path: first 3 picks skip ranker; show all
same-domain neurons.

## D-031 — 2026-05-17 — Layer axis added; meta-overload split (closes OP-03)
**Decision.** Five-value `layer:` axis: kernel | system | meta | shared |
domain. Splits old `category` overload. `category` preserved for
backwards-compat; queries prefer `layer`.

## D-032 — 2026-05-17 — source-artifact-glob declared per domain (closes FL-08)
**Decision.** Each domain manifest declares
`source-artifact-glob:` patterns. `requires-shadow` inference becomes
`affects-source AND outputs-match-domain-glob`. Removes ambiguity.

## D-033 — 2026-05-17 — Shadow-grace-flag flip protocol explicit (closes FL-10)
**Decision.** Flag flips ONLY when: 100% coverage twice ≥ 5min apart
+ axon-audit clean + explicit user QUERY confirm. Unflip requires
dev-mode + reason.

## D-034 — 2026-05-17 — Interrupt-gate workflow-aware (closes FL-09)
**Decision.** Existing active-program-interrupt-gate (KERNEL-SLIM §168)
integrates with axon orchestrator: continuation passes through;
deviation surfaces; pause-and-task CHECKPOINTS + adaptive; abort
terminates workflow.

## D-035 — 2026-05-17 — PR-116 split per project; PR-108 per-file rollback (closes FL-06, OP-04)
**Decision.** PR-116 → PR-116a..f (one per project, internal sub-DAG).
PR-108 ships `--rollback-per-file` mode using existing `undo` tool.

## D-036 — 2026-05-17 — Improvement artifacts I-01..I-06
**Decision.** Ship six improvement artifacts: `_flaws.md` register,
`_versions.md` per phase, orchestrator fixture corpus, per-PR rollback
template, blast-radius declaration, reversibility tier.

## D-025 — 2026-05-17 — Phase 1 validation gate: synthesis sign-off, no per-track gate
**Context.** OQ-10.
**Decision.** Per-track sign-off is not required. The synthesis document
is the single gate. User saying "carry phase 2" = implicit sign-off.
**Consequences.** Already executed this turn.
