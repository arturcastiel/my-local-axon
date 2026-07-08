# Study — AXON Next (Autonomy Doctrine + T3 floor)
Updated: 2026-07-08  ·  Iterations: 1 (4-cluster fan-out)  ·  AXON: 9/10  ·  User: pending

## Goal
Map everything the AUTONOMY DOCTRINE needs so the plan phase extends existing substrate
instead of duplicating it. Doctrine (owner-locked design, 2026-07-08): a first-class
construct attachable to any program/workflow — owner gives the mission; AXON proposes the
routine and translates it into a DAG; the DAG is VALIDATED against the project itself;
valid ⇒ run-until-end (attended AND unattended), under a per-project deviation policy
(AXON-suggested defaults) recorded in a standing per-project AUTONOMY.md written by a
fail-closed activation interview. T3 safety gaps = the doctrine's mechanical floor.

## Method
4 parallel read-only clusters (autonomy/governance stack · DAG/workflow substrate ·
T3 gaps + receipts · interview/doc precedents), every claim verified against source
(file:line) and, where non-mutating, live probes (shell-gate inspect dry-runs, registry/
manifest reads). Cross-cluster convergences spot-checked at synthesis (single
authorized() caller; the workflow outputs schema contradiction) — both confirmed.

## Result — the substrate map in one paragraph
The doctrine is ~70% assembly. The interview exists (autonomy-contract: a per-RUN entry
gate writing policy+grant+ledger in one transaction — extend it, don't parallel it); the
execution teeth exist (workflow_run.advance stacks four deterministic guards: declared-
edge, trajectory anti-skip, sub-workflow completion, output-completeness); the DAG engine
exists (dag.py: schema'd nodes/edges, cycle/dangling verify, write-guarded persistence,
cascade-stale, critical-path); the run-until-end governor exists (loop_contract: hard
human-set budget wall, plateau→REPLAN advice, EXHAUSTED handoff report); the validation
battery exists (check-stale, dag_consistency, git_dag_reconciler, constraints scopes,
r_dont_do fail-closed, phase deps); the receipts spine exists (loop_receipt two-phase
ledger with boot recover()); and the fluxogram renderers exist (plan_dag mermaid +
explain_workflow prose). What does NOT exist: any fail-closed "no doc = no autonomy"
enforcement; typed gate/checkpoint/human-handoff node kinds; ONE graph format carrying
both conditional edges (workflow YAML has them) and a status/provenance ledger (DAG.json
has it); mid-run append-repair mechanics; TTL/budget/scope enforcement on grants; and
deletion-verb classification in the shell gate.

## Verified gap register (consolidated, deduped across clusters)
G1  No fail-closed activation: nothing anywhere requires a contract/doc before autonomy
    proceeds (A+D independently; the "entry gate" is prose).
G2  Two-graph split-brain: workflow YAML = conditional edges + execution, no ledger;
    DAG.json = status/provenance ledger, no conditions/execution. No bridge in either
    direction (promote only does trajectory→YAML).
G3  No gate/checkpoint/human-handoff NODE KINDS; `role:` is a free string nothing
    branches on; handoff exists only as scattered primitives (QUERY, skip_guard token,
    human-confirm, human_handoff renderer).
G4  No mid-run repair primitive: advance(allow_deviation) only jumps to EXISTING nodes;
    graph mutation isn't tied to a live trajectory (deviation-policy mechanics missing).
G5  Deletion-verb blind spot (live-probed): find -delete / xargs rm / shred / unlink /
    git clean -fdx → allow with ZERO inspected paths (even against axon/ kernel files,
    even unattended); rsync --delete carries no deletion semantic; rm -rf workspace/* is
    inspected but has no bulk threshold or protected-subtree concept.
G6  Grants immortal + advisory: granted_ts and budget are write-only (grep-verified);
    contract scope answer is unenforced prose; the accountability contract entry is
    opened and never reconciled. DESIGN TENSION (C): TTL must deny via authorized() —
    naively expiring run_active() would DISARM kernel-floor/breaker/cadence mid-run.
G7  Only 2 of 6 AEGIS capabilities route through resolve() mechanically (test-execution,
    web); develop/pr-create/merge/build are program-discipline only. Two unreconciled
    _policy.md locations (repo root vs per-project); vocabulary drift (kernel-change vs
    kernel-edit; amend/rebase absent from aegis INVIOLABLE).
G8  Latent schema contradiction: the runner enforces synapse `outputs:` completeness but
    workflow-file.schema.json (additionalProperties:false) FORBIDS the field (confirmed);
    no shipped workflow uses it.
G9  goal.* predicates fail-closed False: build_gate_ctx has no goal source, so
    acceptance/rejection vocabulary never evaluates true from deterministic ctx.
G10 No program-integrity manifest: workspace/programs REGISTRY carries last_modified
    only, no content hashes anywhere (injection tripwire absent).
G11 Hook enforces only 3 gate codes and fail-opens on internal exception; new GateBlock
    codes must be registered in _BASH_ENFORCED_CODES or they don't bite on the host path.
G12 dag.py has no conditional edges; NODE_KINDS/EDGE_KINDS need extension (additive-
    tolerant schema, proven by the provenance-fields precedent).

## Extension seams (where the plan attaches, least-new-surface)
S1  AUTONOMY.md: sibling of _policy.md at the project anchor; format = key: header
    (meta.py-addressable) + ## sections of `cap: setting` lines (load_policy grammar) +
    prose + auto-rendered `## Dependency graph` (REPLACE-SECTION + mermaid, pr-link
    idiom) + preserved ## Notes (_preserve_and_backup idiom). Template in
    workspace/templates/. NEVER embedded in _policy.md (contract rewrites clobber it).
S2  Interview: extend autonomy-contract program + autonomy_contract.write into the
    doctrine's four-artifact transaction (policy + grant + ledger + AUTONOMY.md), house
    style: banner-explain first, TOOL(decide) with explanations in option labels +
    recommended-first, re-prompt-until-valid, budget human-set, single write tool,
    confirmation card restating powers + floor.
S3  Fail-closed activation check: aegis_policy.resolve gains a doctrine predicate, and/or
    a crucible STATIC rule (r_autonomy_* BLOCK-by-default pattern) + the skip_guard-style
    halt in the runner program: no valid AUTONOMY.md + validated DAG ⇒ no autonomous op.
S4  Doctrine DAG: extend dag.py (NODE_KINDS += gate/checkpoint/handoff; edges gain `if:`
    predicates evaluated via predicate.py + build_gate_ctx) so ONE format carries
    execution semantics AND ledger; workflow_run.advance wraps it (pure over a dict,
    injectable loaders). Mermaid render on the canonical path (plan_dag.emit_mermaid).
S5  Validation preflight = compose existing detectors: check-stale (nodes name real
    ACTIVE programs), dag_consistency + verify (structure), constraints.run_checks +
    r_dont_do (project prohibitions compiled into gate nodes), phase_model deps
    (ordering), git_dag_reconciler (git reality). Zero new detection code.
S6  Run-until-end: one loop_contract per doctrine run (budget wall = the run's hard
    stop; REPLAN advice = the bounded-self-repair trigger; EXHAUSTED report = the
    handoff payload). Deviation = append-repair-node primitive (dag add-node + re-verify
    + trajectory resume glue) for reversible ops; halt-and-handoff for risk-tiered.
S7  Op-level enforcement: shell.gate_check gains (a) deletion-verb classification +
    wrapper unwrapping + bulk threshold (2pre/3c pattern, new op in DESTRUCTIVE_OPS,
    new code in _BASH_ENFORCED_CODES, manifest key added); (b) a current-DAG-node
    op-class check beside _enforce_destructive_git. Change-level: a crucible STATIC rule.
S8  Receipts: loop_receipt v1.1 (intents doctrine-node + delegated-destructive; trigger
    unattended-run/doctrine-run; maybe target kind `tree`); every DAG-node completion
    receipted via the ctx-manager; recover() gives crash-consistent node state free.
S9  TTL/renewable grants: _expired() inside authorized() (fail-closed), renew CLI +
    audit + ledger row; budget gains a reader (loop_contract's enforced-budget pattern);
    grant_off reconciles the accountability entry.
S10 Program-integrity tripwire: sha256 manifest (NEW reviewed file, separate from
    autogen REGISTRY) + bless action + crucible WARN + promotes_on → BLOCK (the proven
    staging recipe).

## Key Concepts (for plan-phase codebase mapping)
- AEGIS triad + audit: GRANT × GATE × POLICY, resolve() the single fail-closed decision
  point (aspirationally — 2/6 wired); the doctrine makes it 6/6 for doctrine runs.
- Advance-guard pattern: pure deterministic transition validation over declared edges +
  trajectory + completeness; deviation only via explicit flag.
- Classify-then-enforce gate segments (2pre/3c) + hook code registration.
- WARN + promotes_on + baseline → BLOCK: the staging recipe for every new guard.
- Interview→N-artifact transaction; thin-waist writes (program asks, tool writes).
- Receipts = two-phase evidence, not undo; closed enums versioned; recover() at boot.
- run_active = the mechanical meaning of "unattended" (4 enforcement points key on it).

## Tech Stack
Same as bugfix02 + the graph layer: markdown neuron programs (LLM-interpreted) over
Python tools; DAG.json/workflow-YAML/predicate grammar v1.1; JSONL ledgers;
crucible STATIC/suite controls; PreToolUse/Stop host hooks.

## Constraints
- reduce-surface: extend autonomy-contract/dag.py/loop_receipt/gate_check — no parallel
  interview machines, graph engines, or ledgers.
- Kernel floor untouchable: doctrine strengthening never weakens the inviolable set;
  kernel-file edits stay human-only in every mode.
- tests-with-neurons (Core Rule 13) + the empty-baseline discipline (new guards ship
  WARN+promotes_on, ratchets only shrink).
- TTL design tension (G6): expiry denies ops, never disarms unattended enforcement.

## Priorities for the plan
1. The doctrine spine: AUTONOMY.md format + template + parser; extended interview
   (four-artifact transaction); fail-closed activation (G1) — the construct exists.
2. The doctrine graph: dag.py typed nodes + conditional edges (G2/G3/G12), mermaid on
   the canonical render path, the validation preflight (S5), DAG-bound runner wrapping
   advance() + trajectory + loop_contract (S6), deviation mechanics (G4).
3. The mechanical floor (T3): deletion-verb classification + bulk threshold (G5, S7a),
   TTL/budget/scope enforcement + ledger reconciliation (G6, S9), program-integrity
   manifest (G10, S10), receipts v1.1 (S8).
4. Coherence debts that block the above: outputs schema contradiction (G8), goal ctx
   bridge (G9), policy-location reconciliation + vocabulary alignment (G7), hook code
   registration (G11).
5. Unattended arming: the doctrine runner registers run_active correctly; breaker/
   cadence/kernel-floor stay armed through expiry (G6 tension).

## Self-assessment (grade rationale)
AXON: 9/10. All four clusters returned source-verified, line-cited findings with live
probes where safe; the gap register is deduped and every entry carries evidence; the
seams name exact functions/patterns to extend; cross-cluster convergences were
independently derived (G1 by A and D; gate seams by A and C) and two load-bearing claims
re-verified at synthesis. Held below 10 by the honest boundaries: LLM-interpreted
program behavior verified from text not execution; host-hook behavior for subagent Bash
not traced; for-use checkout hook wiring unchecked; budget field's intended unit unknown
(no reader ever existed to define it).
