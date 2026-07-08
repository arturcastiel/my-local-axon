# Audit — AXON Next (Autonomy Doctrine)
Date: 2026-07-08 · Method: 4-seat adversarial council over the SHIPPED code (@77eb1a5) +
AXON Step-0 re-verification of every load-bearing claim against source. Suite 5220/0 and
crucible 38/38 GREEN — yet the audit found the green substantially oversold for the one
property that matters (safe unattended execution).

## Verdict
The DETERMINISTIC TOOL LAYER is real and well-tested (grant binding + hash-check, TTL +
the G6 invariant, receipt hash-chain algorithm, deletion classifier + protected-subtree
matching, resolve_next, the barrier ALGORITHM). But the SECURITY GUARANTEES for unattended
arming are largely defeated as shipped. Seat scores: safe-to-arm 2/10 · correctness 4/10 ·
test-de-risk 4/10 · real-first-run-succeeds 1/10. The absolutes written into the commits
and docs ("authorizes NOTHING", "the host refuses", "tampering breaks the chain", "an agent
can never renew its own grant", "the DAG is obeyed") are FALSE as shipped. This is retracted
honesty: the completion summary claimed more than the code delivers.

## Confirmed defect register (AXON Step-0 re-verified marked ✓✓)

### BLOCKER — a real run cannot start / is not what it claims
- B1 ✓✓ **W:doctrine-routine is never SET** — the runner program HALTs on its first line
  (doctrine-run.md:30, RETRIEVE-only, no STORE anywhere). NO PROPOSER exists: nothing
  authors the routine YAML the owner's vision promises ("AXON proposes a routine"). The
  e2e "birth certificate" passes only because it BYPASSES the program and calls the Python
  with a hardcoded routine. A live owner-driven run is DOA.
- B2 **{project-dir} is unbound in the program** — binds `project ← RETRIEVE(W:code-dev-project)`
  (a slug, not a path) but references `{project-dir}` at 5 sites; the derive line every
  sibling program has is missing → bind/preflight get a bare slug and fail.

### CRITICAL — safety gate defeated
- C1 ✓✓ **bulk-delete gate INVERTED** (shell.py:228) — `if not (repo and authorized(...))`;
  authorized() returns a truthy dict on DENY, so the GateBlock never fires when a grant
  exists. Every recursive/>25-target delete under an unattended run is ALLOWED even when
  the grant does not delegate bulk-delete. Correct pattern (`.get("authorized")`) is used
  right two functions away (shell.py:372). My own test masked it (grantless tmp_path).
- C2 ✓✓ **G1c write-barrier is DEAD CODE** — AXON_WB_PREAMBLE set (shell.py:768), consumed
  by NOTHING; the child python never runs the arming preamble. The computed-path
  interpreter delete the barrier exists to stop (`python3 -c "b='axon';shutil.rmtree(b+'/core')"`)
  sails through unattended. Bonus: `_protected_hit`'s `/axon` substring match would refuse
  EVERY write under `.../new-axon/axon` if it ever did arm (toy-calibrated to tmp_path).
- C3 ✓✓ **anti-self-renew regex misses grant_on** — `python3 -c "import autonomous_mode;
  a.grant_on(...,mode='unattended')"` is NOT caught; grant_on has no run_active guard.
  The master key: one Bash line self-mints an unattended grant with a self-forged
  hash-matched binding, resets its own TTL, needs no human. Collapses arming + TTL +
  binding at once.

### HIGH
- H1 ✓✓ **`timeout -s KILL 5 rm -rf axon/core` bypass** — _unwrap_wrapper skips a wrapper's
  own flags but not a flag's SEPARATE argument, so the head becomes `KILL`, `rm` is hidden
  → bypasses BOTH the deletion gate AND R9 (axon/core never inspected). Same class:
  `env -u VAR rm -rf axon`.
- H2 ✓✓ **arming evidence gate is HOLLOW** — record_clean_run (doctrine_arming.py:41) checks
  ONLY verify_chain(ws).ok; never reads the run's status/receipts by run_id. Proven: an
  empty workspace + three arbitrary run-ids → ARMED. verify_chain on an empty ledger is ok.
  The "reached converged" definition lives only in the untested LLM program. Cross-project
  coupled (default --workspace None → global ledger).
- H3 **authorized() gates only destructive-git + bulk-delete** (shell.py:228,372) — ordinary
  commit/push/pr-create/merge-squash never route through it, so grant scope, ops-list, AND
  the doctrine binding gate NOTHING for the ops a run actually performs.
- H4 **S7b trusts an agent-writable file + is inert for attended runs** — reads
  doctrine-current-node.json from the agent-writable workspace (one write defeats it);
  returns early unless _unattended_run_active, but v1 does only ATTENDED runs, so the
  "obeyed" gate never engages for the runs v1 performs. Every S7b test pre-fakes run_active.

### MEDIUM
- M1 **preflight under-implements its own contract** — the schema check (workflow-file.schema)
  and the _dont-do prohibition check it documents are NEVER run; only profile/node-liveness/
  constraints/integrity execute. So dangling-edge routines (see M2) pass "validation".
- M2 **phantom `next` id → dead cursor → false converge** — resolve_next returns a next with
  no existence check; the runner sets cursor to a phantom node (default kind action →
  op_class write), then next step "converges". A nonexistent start id also "converges".
- M3 **record_clean_run status/self-report** (folds into H2) — convergence enforced only in
  the advisory program, never the tool.
- M4 **phase-ledger calls omit required --program** (doctrine-run.md:35,74) — argparse-fail;
  bookkeeping-only so it degrades not DOAs.
- M5 **hash-chain has no secret/signature** — a RE-CHAINING attacker (edit a row, recompute
  all downstream prev-sha) verifies ok. Detects only naive tampering; oversold vs "the
  agent's diary" claim.
- M6 **program_integrity is add-blind + WARN-only** — `unblessed` never fails the check; an
  injected NEW power file (evil.md) stays green. Attackers add, they don't edit blessed.
- M7 **parse() doesn't strip inline comments from header lines** (autonomy_doc.py:62) —
  `level: full-auto # note` → invalid. Fail-closed (over-rejects) but wrong for hand-edits.
- M8 **resolve_next treats falsy `if:` (false/empty/0/null) as unconditional else** — a
  semantic inversion in the branch selector.
- M9 **doctrine-current-node.json never cleared** — stale after a run; host mirror keeps
  mirroring the stale node on every Stop.
- M10 **program_integrity globs miss the real per-run artifacts** — declares *.routine.yml
  (no writer emits it) + 03-prs/DAG.json (already OWNED by the code-dev PR plan, schema
  axon-dag); the actual run-{id}.dag.json is covered by nothing → the injection risk stays
  open for the doctrine's own run graphs, and wiring to DAG.json would clobber the PR plan
  and trip the repo-wide dag-consistency gate (schema collision axon-doctrine-dag vs axon-dag).

### LOW
- L1 mermaid label escaping (quotes/brackets/pipes break the diagram) — view-only.
- L2 budget wall fires before terminal detection → a terminal at the budget boundary
  reports exhausted+handoff instead of converged.
- L3 host-mirror is decorative — written by untested code, read by no one, and mirrors the
  agent-written current-node file (so it mirrors any forgery).

## What genuinely HOLDS (credited honestly)
- test_doctrine_binding.py — real bind + hash + tamper-relocks (the crown jewel).
- TTL logic + the G6 invariant (expiry denies while run_active stays armed).
- Receipt hash-chain vs NAIVE tampering + legacy tolerance.
- Deletion classifier families + protected-subtree matching: NO false positives, ancestor
  sweeps correctly caught (verified by the correctness seat).
- resolve_next first-true-wins determinism (for well-formed routines).

## Root-cause themes
1. Enforcement written but never WIRED to a real trigger (C2 barrier, H4 S7b, H3 authorized
   coverage) — the tool works, the production path doesn't call it.
2. Guarantees TESTED with the enforcement pre-faked ON (monkeypatch run_active everywhere) —
   green proves the gate body, never that the gate engages in a real run.
3. Truthiness/return-shape bugs at the one-line level (C1) that the tests masked with
   unrealistic fixtures (grantless tmp_path; mx sibling ≠ _resolve_myaxon's my-axon).
4. The propose→run head of the chain was never built (B1/B2) — the e2e proves the tools
   compose, not that the PROGRAM drives them.

## Recommendation
This is architectural, not piecemeal — a dedicated bugfix project (plan → PRs → per-wave
full suite, same rigor), because several fixes are design-level (wire the barrier or drop
the claim; route ordinary ops through authorized() or narrow the claim; move the node-gate
state out of agent-writable space or sign it; build the proposer; make arming read real
run evidence; make the tests exercise the real resolver + program). Until then: the
unattended-arming claims must be retracted in the docs, and the doctrine treated as
attended-only, honest-agent-only. The one-liners (C1, C3 regex, H1, M7) can land first as a
hotfix wave since they are contained and high-value.
