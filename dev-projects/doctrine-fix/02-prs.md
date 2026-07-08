# PR List — doctrine-fix
Total: 13 PRs · Waves: 0 hotfix+honesty · 1 wire-enforcement · 2 run-head · 3 real-evidence+tests
H3 = NARROW (owner, 2026-07-08).

## PR-01 [MERGED] — Gate correctness one-liners (real-path tested)
- **Status:** merged · **Wave:** 0 · **Fixes:** C1, H1, M2, M8, L2
- shell.py: C1 bulk-delete `not (repo and authorized(...).get("authorized"))`; H1 _unwrap_wrapper
  skips a flag's separate arg (`-s KILL`, `-u VAR`). workflow_run.resolve_next: M8 treat only
  MISSING `if` as unconditional (a present falsy `if` → evaluate/deny); doctrine_run: M2 guard
  a phantom `next` (reject a next-id not in the routine → halt, not dead-cursor-converge);
  L2 check terminal before the budget wall. Tests re-run on the REAL grant path (a grant with
  a repo, not grantless tmp_path) so C1 can't hide again.

## PR-02 [MERGED] — Kill the self-mint at the source
- **Status:** merged · **Wave:** 0 · **Fixes:** C3
- autonomous_mode.grant_on + bind_doctrine + renew refuse to run while an unattended run is
  active (guard IN the function, not only the hook regex) — an agent can't self-arm/rebind
  even by direct import. Broaden the hook regex to catch grant_on/import forms as defense-in-depth.

## PR-03 [MERGED] — Honesty pass: retract the oversold absolutes
- **Status:** merged · **Wave:** 0 · **Fixes:** H3 (narrow), M7, docs
- Rewrite AXON-DOCS-AUTONOMY.md + code comments so every claim matches code: binding gates
  the RUN (not "every op"); barrier/arming/chain claims scoped to what a test proves. M7:
  autonomy_doc.parse strips inline header comments (`.split("#")[0]`).

## PR-04 [MERGED] — Arm the G1c barrier for real
- **Status:** merged · **Wave:** 1 · **Fixes:** C2
- sitecustomize.py arms write_barrier when AXON_WB_ARM=1 (runs for `python -c`/-m, unlike
  PYTHONSTARTUP); shell.cmd_exec sets the flag for unattended runs. write_barrier._protected_hit
  uses path-segment matching (not `/axon` substring). Real test: a child through cmd_exec runs
  a computed-path shutil.rmtree of a protected dir → refused, non-zero exit.

## PR-05 [MERGED] — Move the node-gate state out of agent-writable space
- **Status:** merged · **Wave:** 1 · **Fixes:** H4a
- doctrine-current-node.json → axon/state via the _axon_io whitelisted-actor write (like
  loop_receipt), so the agent can't forge op_class. shell._enforce_doctrine_node reads the
  gated location.

## PR-06 [MERGED] — S7b engages for any active doctrine run
- **Status:** merged · **Wave:** 1 · **Fixes:** H4b
- _enforce_doctrine_node fires when a doctrine run is active (attended OR unattended), keyed
  on the (gated) current-node record + a live run — not on run_active alone. Real-run test
  (no monkeypatch): start a run at a read-class node, assert a write raises doctrine-node.

## PR-07 [MERGED] — Integrity: fail on injected adds + cover the real artifacts
- **Status:** merged · **Wave:** 1 · **Fixes:** M6, M10
- program_integrity: an unblessed NEW power-file under a covered root is a FAILURE (not just
  advisory); fix the globs to the actual run artifacts (run-*.dag.json) and resolve the
  DAG.json schema collision (doctrine ledger keeps its own name/schema, never 03-prs/DAG.json).
  Staged promotion note updated.

## PR-08 [MERGED] — The proposer: a run can actually start
- **Status:** merged · **Wave:** 2 · **Fixes:** B1
- A proposer step/tool authors a routine YAML from the project (or accepts an owner-supplied
  one) and STOREs W:doctrine-routine; wire it as the first FLOW step of doctrine-run.md so the
  program no longer HALTs on line 1. A test drives propose→routine-exists.

## PR-09 [MERGED] — Program run-head fixes
- **Status:** merged · **Wave:** 2 · **Fixes:** B2, M4, M9
- doctrine-run.md: derive `project-dir ← "{W:myaxon-dev-projects}/{RETRIEVE(W:code-dev-project)}"`;
  phase-ledger calls carry --program; CLEAR the current-node record at run end (teardown).

## PR-10 [MERGED] — Preflight completeness
- **Status:** merged · **Wave:** 2 · **Fixes:** M1
- doctrine_preflight runs the schema check (workflow-file.schema) + the _dont-do prohibition
  check it documents, AND validates edge/start referential integrity (catches M2 dangling
  edges at validation, before a run). Tests for each.

## PR-11 — Arming reads real run evidence
- **Status:** not-started · **Wave:** 3 · **Fixes:** H2, M3
- record_clean_run takes the run's state + filters receipts by run_id; a halted or
  receiptless run is REFUSED as evidence; run-scoped, not the global ledger. Test: a halted
  run is not counted; a fabricated run-id is rejected.

## PR-12 — Chain + host-mirror honesty
- **Status:** not-started · **Wave:** 3 · **Fixes:** M5, L3
- Either make the host-mirror (Stop-hook, agent-unreachable) the row verify_chain actually
  consults for unattended evidence, or narrow the "tamper-evident" claim to naive-tamper +
  document the re-chaining limit. host-mirror is consumed-or-cut (no decorative code).

## PR-13 — Real-path tests + program behavioral test
- **Status:** not-started · **Wave:** 3 · **Fixes:** test-quality root-cause, L1
- Replace monkeypatch-run_active in security tests with fixtures that build a real grant in
  the myaxon _resolve_myaxon actually finds, so run_active is genuinely True; add a behavioral
  test that drives the doctrine-run PROGRAM (not just the tool) through a happy + a halt path;
  L1 mermaid label escaping.
