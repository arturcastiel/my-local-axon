# Project: AXON Next — council follow-ups
slug:            axon-next
schema-version:  v4
status:          complete
legacy:          false
phase:           complete
workflow-step:   build
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
workflow:        _workflow.yml
parent:          (none)
sub-projects:    []
created:         2026-07-08
updated:         2026-07-08

## Working Context
- SOURCE: the hr-team standing audit (my-axon/generated/axon-standing-report-2026-07-08.md).
  Owner triage 2026-07-08 of the council's four Tier-1/2 recommendations:
  - T1 BENCHMARK — PARKED ("hanging"): owner believes the benchmark is STALE and needs
    adjustment before any run. Scope when picked up: refresh the guide (stale prompt-level
    caveat vs the merged --axon-arm mcp), re-validate the 2026-05-28 pre-registration against
    the current OS (40 days of change), re-run preflight/power, THEN decide the run.
  - T2 STRANGER TEST — DROPPED (owner 2026-07-08, "drop 2 as well"). No stranger test;
    the onboarding-tier keep/delete question stays unasked for now.
  - T3 SAFETY GAPS — COMMITTED scope: (a) deletion-verb gate coverage in tools/shell.py
    (find -delete, rsync --delete, shred, xargs rm, bulk rm -rf under workspace/ + threshold);
    (b) grant TTL/budget + receipts for delegated destructive acts; (c) program-integrity
    tripwire (reviewed-hash manifest over workspace/programs/*.md, advisory→BLOCK staged).
  - T4 AUTONOMY DOCTRINE — owner vision recorded (2026-07-08): autonomy becomes a
    FIRST-CLASS DOCTRINE, associable to code-dev or ANY program/workflow. Pillars:
    (1) per-project autonomy doc — the doctrine instance lives IN the respective project;
    (2) activation interview — before activating, AXON pops questions that EXPLAIN the
    delegations and elicit scope/limits (fail-closed: no doc, no autonomy);
    (3) fluxogram/DAG — AXON compiles the mission into an explicit DAG (what it will do,
    in what order, with which gates) written for the human BEFORE running;
    (4) bound execution — the run MUST follow and obey that DAG, and the DAG itself must
    obey the project (its _policy/_dont-do/_profile compiled into gate nodes).
    Substrate to reuse: autonomous_mode grants, AEGIS _policy, tools/dag.py, workflow-runner
    rigid traversal + kernel R_WORKFLOW_NODE_ORDER, phase_model, loop receipts.
    T3's guards (deletion verbs, TTL, integrity tripwire) = the doctrine's mechanical floor.
  DESIGN LOCKED (owner answers, 2026-07-08):
    Q1 granularity → AXON-CONTROLLED: owner gives the mission input; AXON proposes the
      autonomy routine and translates it into the DAG; the DAG is VALIDATED against the
      program/project itself; if valid, the run proceeds UNTIL END.
    Q2 execution mode → ALL: attended AND unattended both in scope.
    Q3 deviation policy → in scope, per-project configurable: the interview lets the user
      set it, AXON suggests defaults (default = bounded self-repair for reversible ops,
      mandatory halt-and-handoff for risk-tiered ops).
    Q4 doc lifetime → standing AUTONOMY.md per project + per-run DAG instances.
- STUDY COMPLETE 2026-07-08 (self-grade 9/10, one fan-out round; 2 load-bearing claims
  re-verified at synthesis). 01-study.md: substrate map (doctrine ≈70% assembly), 12-entry
  verified gap register (G1-G12), 10 extension seams (S1-S10), 5 plan priorities.
  Headline: extend autonomy-contract into the four-artifact transaction; ONE doctrine graph
  format (dag.py + typed nodes + conditional edges) bound by workflow_run.advance +
  loop_contract; fail-closed activation is NEW enforcement (G1); TTL must deny via
  authorized() without disarming unattended enforcement (G6 tension).
- PLAN COMPLETE 2026-07-08 (owner: "continue"; council-REBUILT). 02-plan.md + 02-prs.md
  (17 PRs / 4 waves) + 02-phases/ + 03-prs/DAG.json (17 nodes, verify ok) + ADR-001
  (D1 FORMAT FLIP: doctrine graph authored as workflow YAML, DAG.json a one-way derived
  ledger — council overturned the study's extend-dag.py lean with source evidence).
  Locked: D2 unattended = evidence-gated promotion (3 clean attended runs) · D3 deviation
  v1 = halt-and-handoff only · D4 budget unit = node-completions. Council blockers all
  in-plan: grant⟷doctrine binding (PR-008), real G1c barrier (PR-002), S7b node-op-class
  gate (PR-015), hash-chained receipts + host mirror (PR-004/016), human-only TTL renew
  (PR-003), integrity manifest covers AUTONOMY.md (PR-005, gates the spine), walking
  skeleton (PR-009). Step-0 reversal recorded: aegis resolve() HAS 2 production callers.
- Next: code-dev pr 1 / implementation (waves A→D, full suite per PR, per the drill).
