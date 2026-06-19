# Decisions (ADRs) — study

## ADR-001 — Design: `# emits:` SSOT + drift-lock + 6-layer rollout
- Date: 2026-06-18
- Decision: deliver the "terminal ⇒ post-condition verified" invariant via a new machine-parseable
  `# emits:` program header (root-relative, glob-allowed) as the single source of truth, parsed by ONE
  tool (`tools/emits.py`), held in mechanical parity with the `REQUIRED_OUTPUTS` floor by a drift-lock
  (`# emits:` ⊇ map; map NEVER deleted). Layers: L0 SSOT · L1 drift-lock · L2 phase_model.done sources via
  the existing manifest `outputs` override (done() untouched) · L3 R_TERMINAL_OUTPUTS verifier rule
  (silent-until-flag, modeled on r_state_surfaced.py) · L4 workflow node `outputs:` schema + verify · L5
  process/queue/dag bare-writers. Ship L0–L3 first.
- Why: the prose `# outputs:` header is provably unusable as SSOT (omits DAG.json; 40% have no path token;
  templated vocabulary). A new `# emits:` + ⊇-lock makes SSOT real without ever weakening the gate.
- Constraint-fit: NO axon/ kernel edits (preamble already extracts the header; DONE already writes :done;
  verify output gate already runs). No gate bypass (map stays a floor; --force logs). Tests-in-change.

## ADR-002 — Decided design forks (study recommendations adopted)
- Date: 2026-06-18
- Program↔phase binding = explicit `# phase:` program field (not name-inferred).
- `# emits:` parsed + written into the manifest `outputs` override by an upstream code-dev driver / run.py
  (keeps phase_model "pure over the json"); phase_model gains NO program-reading responsibility.
- Mode-dependent outputs = static SUPERSET in `# emits:` (drift-lock only needs ⊇, so a superset is safe).
- `emits-drift` = an MCP tool, registry-drift-style.

## ADR-003 — Teeth reality (honest)
- Date: 2026-06-18
- L2 (phase_model.done guard) carries the REAL teeth in v1 (in the transition function; flag-independent).
- L3 (R_TERMINAL_OUTPUTS) is belt-and-suspenders and is LOG-ONLY at the Stop hook today (`verify_stop.py`
  exits 0 on BLOCK) — so it is advisory until the hook escalates or it rides crucible. This is itself an
  enforcement-architecture finding (cross-ref the parallel arch bug-hunt). v1 does NOT depend on L3 for teeth.

## Open forks → resolve in PLAN (owner-facing)
- Scope: L0–L3 now + L4/L5 follow-ups (recommended) vs all 6 layers here.
- Default activation OFF (recommended) — flip after FP validation.
- Stop-hook escalation in scope or deferred (broader enforcement-arch change).
- Staleness via active-phase.md mtime (recommended v1) vs a phase-entered-at stamp (kernel edit, out of scope).
- Migration: auto-populate existing projects' manifest `outputs` from the map, or leave map as default.
- L5 semantics: structural (deps terminal) vs outcome-based (work succeeded).

## ADR-005 — Revise ADR-003 "teeth reality" (post-council, 2026-06-19)
- Status: accepted · supersedes the "L3 advisory until it rides crucible" framing of ADR-003.
- Context: ADR-003 said L3 (R_TERMINAL_OUTPUTS) gains teeth once it "rides crucible." PR-11 did add a
  crucible merge-carriage runner — but the hr-team council + plan-auditors proved the teeth are partial:
  only 3 of ~12 BLOCK-RUNTIME rules are carried; the runtime rule ships flag-OFF
  (`terminal-outputs-required` absent); and the merge runner fails OPEN on a fresh clone (gitignored
  working-state). Also keystone has NO reverse-coverage assertion, and 8 BLOCK rules are carried only by
  WARN-severity lint/audit controls → no fail-closed runner at all.
- Decision (Wave G / G3): replace "carry all BLOCK rules" with an EXPLICIT per-rule disposition —
  {carry-at-merge | reclassify-as-per-response-only | N/A-at-merge-with-reason}; content-driven rules are
  NOT mergeable (sentinel would no-op or false-fire) so most reclassify. `r9_axon_write` is action-driven
  and needs an action-ctx carriage, not the text sentinel. Add a keystone reverse-coverage gate over a
  machine-checkable rule→runner registry; resolve the 8 WARN-only-runner BLOCK rules (promote or
  reclassify) before that gate can be green. Fail-CLOSED on absent working-state ONLY when the
  `.axon-governed` sentinel is present AND a project is genuinely active — distinguish "no active project"
  (legit empty, allow) from "state suppressed" (block), or every clean CI merge false-blocks.
- Honest current posture (to be stamped into KERNEL-SLIM L89-95 lineage docs, NOT the kernel file):
  L2 (phase_model.done) = real teeth, flag-independent, always-on. L3 runtime = flag-gated + clone-open.
  Merge-carriage = 3 rules today; Wave G makes the carried set explicit + adds reverse-coverage.
