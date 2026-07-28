# PR List — AXON 4 Bug-Free (AXON-LANG self-awareness) · v2 AMENDED by plan-review council
Updated: 2026-07-13 · Total PRs: 8 · goal-2026-07-13-1 · supersedes v1
review verdict: NOT ready as written (3 seats) — amended per verify-before-build + one security fix.
grounding (corrected live): 791 TOOL / 287 EXEC sites · 188 registry names · 94 distinct TOOL targets (91 resolve).

## Wave 1 — quick sweep (amended)

### PR-001 — G1: kernel-scope program_tool_conformance — HARDEN THE PARSER FIRST
- **Wave 1 · M (was S) · G1 · Deps: none**
- **Scope:** (a) FIRST harden the extractor — strip fenced/inline-code spans + bound accessor
  var-tracking (reset at blank lines) so prose like `` `tools/drift.py` `` and fenced PLANNED-tool
  blocks aren't matched; (b) THEN add axon/*.md top-level to scope (axon/programs/*.md already scanned;
  exclude core/compiler spec docs). Tests incl. the 3 known prose FPs (KERNEL-SLIM:519, OUTPUT-LAYER:34,147).
- **Why:** closes the F-H10 scope gap. Risk-seat: unhardened, it produces 3 prose FALSE POSITIVES that would
  break the only-shrink conformance_baseline (currently 0). Harden → live kernel is genuinely clean.
- **Acceptance:** live kernel scan = 0 violations (NOT via baseline); the 3 prose FPs are test-pinned as non-matches.

### PR-002 — G3: EXTEND doc_counts to CONTEXT.md/ARCHITECTURE (do NOT build a new tool)
- **Wave 1 · S (was M) · G3 · Deps: none**
- **Scope:** tools/doc_counts.py ALREADY exists (PR-14.1: check/fix/counts) and is wired as gate+auto-heal
  in freshness.py. Extend its patterns to CONTEXT.md/AXON-DOCS-ARCHITECTURE's richer phrasing
  ("N entries, M ACTIVE + K OPTIONAL", "seven subsystems") + ensure `fix` covers them; retire the 3
  hand-typed count text-pins in favor of the doc_counts freshness check. Tests.
- **Why:** verify-before-build — a NEW `docgen tool-counts` would be a 2nd count tool (the duplication PR-006
  exists to prevent). The residual is narrow: extend the existing generator's coverage.
- **Acceptance:** adding a fixture tool + `doc_counts fix` updates all 3 artifacts; the freshness check
  replaces the brittle text-pins.

### PR-003 — G3: auto-recompile mirrors ONLY — NO AUTO-BLESS (security)
- **Wave 1 · M · G3 · Deps: none**
- **Scope:** a hook that recompiles changed programs' compiled mirrors, then runs `program_integrity check`
  and BLOCKS the commit with the EXACT `bless` command for the human to run after reviewing the mirror diff.
  Blessing stays a deliberate human action. (Integration point: git .pre-commit-config, NOT tools/hooks/
  which is agent-lifecycle.)
- **Why — HARD STOP on the original:** program_integrity.py's manifest is "deliberately separate … so a
  generator can NEVER auto-bless drift"; cmd_bless re-blesses ALL covered files; doctrine_preflight uses it
  as a PRE-EXECUTION injection guard; the control is 245/245 blessed on the verge of promoting to BLOCK. An
  auto-bless hook = security theater. The recompile half writes covered power-files (9 mirrors) → that is the
  legit half; the bless must NOT be automated.
- **Acceptance:** editing a program without recompiling → the hook recompiles + BLOCKS with the bless command;
  a fixture proves the mirror stays in lockstep AND that bless is never auto-invoked.

## Wave 2 — the core (RESTRUCTURED: consolidate-first, reuse-what-exists)

### PR-004 — G2: ONE canonical AXON-LANG parser library (behavior-PRESERVING refactor, FIRST)
- **Wave 2 · M (was L) · G2 · Deps: none**
- **Scope:** new tools/axonlang.py — a single canonical tokenizer (bracket-balanced for the 60 multi-line
  TOOL(); full opcode+scope alphabet INCLUDING E:, which memory_key_lint's `(W|L)` regex misses). Migrate the
  strongest existing consumers onto it with ZERO behavior change, proven by their EXISTING tests+baselines:
  at least memory_key_lint, program_tool_conformance, deps, simulate. Preserve the path-var (W:ws-*) vs
  memory-key (W:*) namespace distinction.
- **Why:** the review found ~6-17 .py files parse AXON-LANG with OWN regexes that DISAGREE on the alphabet
  (E: scope) — "gates on sand." A pure refactor done FIRST makes reduce-surface the un-cuttable PR (vs the old
  reconcile-last PR that gets dropped under wave pressure), and never creates a transient extra parser.
- **Acceptance:** ≥90% of the 791 TOOL / 287 EXEC / STORE / RETRIEVE sites resolved; the migrated consumers'
  existing test suites + baselines pass UNCHANGED (behavior-preserving proof); the E: scope is now parsed.

### PR-005 — G2: the gating lints as CONSUMERS of the canonical relation (fold dedup in)
- **Wave 2 · M · G2 · Deps: PR-004**
- **Scope:** gating checks built as consumers of axonlang.py's relation (NOT new probers):
  (a) dead EXEC()/dead-program — REUSE deps.py's existing `missing_exec` (deps.py:161), promote deps into
     crucible with a baseline; don't reimplement.
  (b) dead keys (written-never-read) — EXTEND memory_key_lint with its EXISTING noise discipline (the W:_*
     run --input exemption + allowlist + baseline that keep it off the 67%-noise / 223-of-333 trap). NOT a
     naive written-never-read (the 8% dynamic tail is the highest-fanout hubs → false BLOCK).
  (c) dangling TOOL() — already emitted by program_tool_conformance; do NOT re-probe argparse.
  Phantom keys already gated by memory_key_lint. Tests + crucible controls.
- **Why:** most of the "new" gates already exist (deps.py, memory_key_lint reverse-query); the work is
  WIRING + tuned-noise-discipline, not new capability.
- **Acceptance:** seeded fixtures BLOCK; live tree clean; baselines ship EMPTY or each entry annotated
  fixable-not-FP (no masking); deps promoted into crucible.

### PR-006 — G2: finish the consolidation + document the parser boundary
- **Wave 2 · S · G2 · Deps: PR-005**
- **Scope:** migrate the remaining AXON-LANG parsers PR-004 didn't (audit_axon_lang, exec_args_lint,
  dry_run_lint, docgen — the review counted ≥6, up to ~17 loosely) onto axonlang.py OR record an explicit
  scoped decision + a conformance test that any un-migrated parser AGREES with the canonical one on the
  alphabet. State the scope boundary explicitly (no "3 parsers" undercount).
- **Acceptance:** a conformance test proves every remaining AXON-LANG parser agrees with axonlang.py on the
  opcode+scope alphabet, or is explicitly out of scope with a reason.

## Wave 3 — G4 graph-emission (DECISION-GATED, coverage machinery lives HERE now)
### PR-007 — emit the canonical relation into the unified graph.json (gated on residual multi-hop gap)
- **Wave 3 · M · G4 · Deps: PR-004; GATE: only if W1-W2 leave a real transitive gap**
- **Scope:** extend code_graph.py to ingest axonlang.py's relation as nodes+edges (program→tool invoke,
  program→key write/read; EXTRACTED/AMBIGUOUS); the join-COVERAGE metric (matched vs unresolved) lives here
  (it's a query-index quality signal, not a gate threshold); make query callers/affected span both layers.
- **DECISION GATE:** at end of Wave 2, assess whether any residual finding was transitive/multi-hop. None → DEFER.

## Deferred — PR-008 G5 markdown runner (likely its own future project; unchanged)

---
CHANGES vs v1: PR-001 harden-parser-first (+M) · PR-002 extend doc_counts not new tool (−effort) ·
PR-003 recompile-only NO auto-bless (SECURITY) · PR-004 canonical-library-refactor-first (was standalone
extractor) · PR-005 reuse deps.py + tuned dead-key + fold dedup in · PR-006 finish consolidation (6-17
parsers, not 3) · PR-007 coverage machinery moved here.
