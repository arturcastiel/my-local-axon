# High-Level Plan — Stale Pointer Integrity
Updated: 2026-07-09  ·  Iterations: 1  ·  AXON: 8.5/10  ·  User: 10/10

## Context (from Phase 1)
Goal: Find and fix stale pointers; make it impossible for a project's state pointers
to go stale. Root cause (study, evidence-grounded): every pointer writer is optional
or advisory at exactly the moment of completion, and nothing audits cross-store
coherence. Four stores: W:active-phase · _phases.json · _meta.md · last-test-run.json.

## Architecture Overview
Python CLI tools (tools/*.py, argparse + JSON envelopes) invoked via axon.py dispatch;
AXON-LANG markdown programs (workspace/programs/*.md) orchestrate them. Pointer
topology: memory.py owns W:/L: files · phase_model.py owns _phases.json (sound gates,
passive) · _meta.md is freeform-written by programs/agents · test_runner.py stamps
last-test-run.json only when tests run through it. self_care.py is the existing
read-only sweep (areas/attention pattern) — the natural composition point.
Graph DB active: my-axon/dev-projects/axon-stale-pointers/graph/graph.json.

## A · Detect (the missing enforcement seam)
One read-only pointer-coherence sweep INSIDE self_care.py as a new area
(reduce-surface: no new top-level tool). Four checks:
1. W:active-phase validity — program file exists for the token's program segment;
   token shape valid; terminal-vs-project-state cross-check.
2. phase_model.check() for every project with _meta status: active.
3. _meta "status: complete" ⇄ manifest all-done reconciliation.
4. last-test-run.json ts vs latest repo commit ts (stale-warn, advisory).
Each finding renders one attention line + one fix command (self-care house style).

## B · Surface (stale = seen next session, not weeks later)
Wire the sweep verdict into tools/axon_state.py menu-snapshot (new `pointers` field,
per-field fallback preserved) + workspace/programs/menu.md OS STATE render. Resume
offer guarded: a pointer failing validation renders "⚠ stale pointer — repair"
instead of a trusted resume/interrupt prompt. Kernel BOOT.md untouched (kernel-floor);
all wiring lands workspace-side.

## C · Enforce (loud completion)
New `code-dev complete` route in workspace/programs/code-dev.md: refuses to write
"status: complete" until the manifest is all-done, else lists exactly which phases
block and why (per-phase reason codes). The five best-effort phase-advance call
sites (study ×2, plan, pr-create, journal-log, safety-audit) escalate
outputs-missing from LOG(ERROR) to a rendered human-handoff line — the
axon-obsidian silent-pending failure class dies here.

## D · Reconcile reality (tests + history)
Root conftest.py with pytest_sessionfinish stamping last-test-run.json on EVERY
pytest run in this repo (pytest-native seam; sitecustomize.py sets the env-gated
precedent; test_runner.py de-duplicated to avoid double-stamp). Then repair existing
stale records with the new lint as verifier: axon-obsidian pr → done --force
(recorded — the 5 PRs verifiably shipped), log → done (04-log.md exists), audit
stays pending honestly (it never ran).

## Risks
- menu.md render parity between snapshot field and per-tool fallback (test-pinned,
  lossless mandate — same class as prior menu bugfixes).
- conftest.py interacting with coverage subprocess bootstrap — keep the stamp
  write-only, exception-swallowed like sitecustomize.
- done --force semantics on repair must stay honest: forced = recorded, audit
  phase NOT forced.
