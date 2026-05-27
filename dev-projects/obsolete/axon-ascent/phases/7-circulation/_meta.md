# Phase: 7-circulation
schema-version: v4
status:         in-progress  (surfaces 7c1/7c2/7c3 + compass merged; engine — feed-loops + autonomous cycle — pending real usage)
workflow-step:  implement
branch:         main
current-pr:     (none)
created:        2026-05-25
predecessor:    1-telemetry, 3-safety-budget, 4-eval  (engine prereqs)
successor:      (capstone — none)
source:         architecture-bones.md (the "make AXON alive" North Star) — NOT axons-audit

## Scope (full detail in ../../masterplan.md § North Star + 7-circulation)
Make the self-improvement loop self-sustaining, and give it a user-facing surface.

**Engine** (the loop itself — see masterplan):
- feed the loops (use, not build) — this *is* phase 1-telemetry, the organism's food
- a trustworthy compass (fix the saturated usefulness metric; resolve MYAXON_ROOT)
- runtime enforcement (Bone 1 — guarantees in hooks/tools, not instruction-hope)
- the autonomous cycle (measure → close-gaps → grow; cron + gated auto-actions)

**Surface** (proprioception + foresight — the user-facing front-end):
- **PR-7c1 control-strip** — intent queue + R_PROJECT_ANCHOR render + sparing tip;
  adaptive density via OUTPUT-LAYER. Rides shipped pieces; fixes rapid-fire ordering-blur.
- **PR-7c2 anticipation-layer** — extend synapse-suggest with workflow-arc signals to
  anticipate the next step; drive the strip's density via the orchestrator
  decide-thresholds (silence is first-class); context-aware menu slices. Confidence-gated
  + measured. Mechanism ships on the existing orchestrator; intelligence ramps with the loops.
- **PR-7c3 autonomous-mode verbose trace** — separate the agent's reasoning from AXON's
  program/tool execution + narrate each invocation + emit a structured trace (session-log)
  for reporting / training / observability. Gated, default off. Third proprioception surface.

## Dependency order
```
orchestrator (done) + R_PROJECT_ANCHOR (done) ─▶ 7c1 control-strip ─▶ 7c2 anticipation
feed-loops + compass ───────────────────────────▶ (ramps 7c2 accuracy) ─▶ autonomous cycle
```

## Why last (capstone)
"Make AXON alive" (architecture-bones North Star). The surface PRs are shippable early
(mechanism), but their intelligence + the autonomous cycle require the engine items first.
**Wrong anticipation erodes trust — confidence-gate + measure before widening.**

## Start with
code-dev load axon-ascent → code-dev phase start 7-circulation
