# Candidate PR cluster — neuron-contract conformance (enforce + teach the architecture)

> Net-new, beyond the original axons-audit. Surfaced 2026-05-24 by the user's
> stated endgame: the synapse / neuron / graph contract should be THE CORE of
> AXON, with every program + tool conforming to it. Triggered concretely by the
> reservoir-review bug in reservoir-eng PR-D4 (declared `role: reviewer`, which
> is not a valid neuron role).

## Problem
The neuron-contract machinery exists (synapse-infer / synapse-validate, PR-108)
but conformance is NOT enforced. A program can declare an invalid role, or a
role that contradicts its behaviour, and only a soft 90%-tree-rate test notices
(one bad file hides under the threshold). The architecture is descriptive, not
binding — the opposite of the endgame.

## Audit evidence (background sweep, 2026-05-24 — 183 programs, 101 tools)
- **1 hard contract-invalid:** `workflow-run.md` → `role: orchestrator` (not in
  enum {mutator,reader,gate,renderer,router,composer}; it dispatches → router/composer).
- **~7 role-vs-behaviour (declared mutator, actually read-only):** authoring-guide,
  discover, glossary, quickstart, mode-router, mode-detect, show-memory.
- **~7 marked `| read-only` but durably write:** gain, stats, turn-log,
  session-summary, auto-actions, axon-compare, code-dev-knowledge-explain.
- **1 reader-but-writes-longterm:** axon-reanchor (`STORE(L:cognition-frame)`).
- **~7 missing identity lock** (phase-track w/o `ASSERT(L:cognition-frame≡"AXON-OS")`):
  health-check, igap-improve, library-dev(+explain/ingest/new), workspace-backup.
- **dangling next-suggests** (point at non-existent neurons; mostly PR-108
  migration artifacts like `→ workspace`): help, mode-router, quickstart, code-dev,
  glossary, ~10 code-dev-* modules.
- Tools: 0 invalid.

## Proposed PRs (user chose Option 1 — audit gate + extend guide, 2026-05-24)
- **PR-N1 — `R_NEURON_ROLE` lint rule** (mechanical, deterministic, CI-enforceable):
  role-vs-behaviour conformance. role∈{reader,renderer} but durable writes → flag;
  role=mutator but read-only/no writes → flag; invalid-role word → flag. warn→block
  flag, same pattern as the axon-polish rules. + tests. This is the enforcement floor.
- **PR-N2 — `neuron-audit` program**: `--target <prog.md>` → runs synapse-infer →
  synapse-validate + the rule pack (incl R_NEURON_ROLE) + dangling-suggest check →
  renders PASS/FAIL + specifics. The reusable, user-facing conformance gate. + tests.
- **PR-N3 — `authoring-guide` += "NEURON CONTRACT" section** (roles enum, required
  fields, synapse-block format, identity-lock, read-only-vs-ownership, examples)
  AND fix authoring-guide's own `role: mutator` → `reader` (it violates its own lesson).
- **PR-N4+ — cleanup** the punch list above, each fix verified by `neuron-audit`.
  Many are judgment calls (role reassignments) → review each, don't auto-rewrite.

## Effort / risk
M. N1/N2/N3 are self-contained + tested, low blast radius. N4 touches many core
programs and involves taxonomy judgment (is axon-reanchor a mutator or a gate?)
— sequence carefully, verify with neuron-audit, and keep each a small reviewable PR.

## Home + sequencing
- **Project:** axon-ascent (axon-core self-improvement) — NOT reservoir-eng.
  The reservoir-review.md program itself stays in reservoir-eng cluster D; the
  conformance *enforcement + teaching* is general AXON-core and lives here.
- **Sequenced AFTER the memory wave** ([[_candidate-agent-memory]]) per user
  direction 2026-05-24 ("enforce this PR plan after we tackle the memory wave").
- Current chain: reservoir-eng cluster D (D4 held, user merges) → memory wave
  (agent-memory) → THIS (neuron-conformance). reservoir-eng P + V remain open on
  the reservoir track, to interleave per user.

## Status
DONE 2026-05-24 — ran fully autonomously under the autonomous-mode grant (5 PRs,
all self-merged on CI green, non-kernel):
- N1 #97  R_NEURON_ROLE lint rule (role-vs-behaviour, warn->block; 9th lint rule)
- N2 #98  neuron-audit tool (synapse-infer+validate + lint pack + dangling-suggest -> verdict)
- N3 #99  authoring-guide "NEURON CONTRACT" section + fixed its own role mutator->reader
- N4a #100 rule-accuracy fix: dropped local-APPEND + EMIT false positives (live flags 7->3)
- N4b #101 the 3 TRUE role bugs: glossary mutator->reader, axon-reanchor reader->gate,
           workflow-run orchestrator->composer. R_NEURON_ROLE now flags 0.

Outcome: the neuron-contract is now ENFORCED (R_NEURON_ROLE in the lint pack),
AUDITABLE (neuron-audit gate), and TAUGHT (authoring-guide §12) — with every real
role bug fixed. Verified: compile-optimizer verify PASS on all edited compiled programs
(synapse-comment edits don't trip drift).

Residual (NOT cluster-N — pre-existing advisory backlogs surfaced by older rules,
separate large migration + recompile cost): R_FAIL_FORMAT 70, R_PHASE_TRACKED 80,
R_IDENTITY_LOCK 34. Dangling next-suggests are advisory PR-108 placeholders. The
audit's "marked read-only but writes" set was mostly false positives from the same
loose regex N4a fixed. Bridge to memory wave (memory-reads/writes synapse fields +
neuron-audit check) still deferred — optional follow-up.
