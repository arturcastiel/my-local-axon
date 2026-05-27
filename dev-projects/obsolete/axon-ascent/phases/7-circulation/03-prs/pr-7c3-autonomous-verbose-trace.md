---
glossary:   AXON-GLOSSARY
audience:   tier-A
version:    1
---

# PR-7c3 — autonomous mode: verbose AXON-usage trace (separation + transparency)

**Phase**: 7-circulation
**Depends-on**: narrate (shipped) · E:session-log · R_PROJECT_ANCHOR (shipped)
**Relates**: PR-7c1 control-strip · PR-7c2 anticipation — the third proprioception surface
**Wave**: surface · **Reversibility**: reversible (gated, default-off)
**Domain**: system · **dev-mode required**: no · **Status**: merged (tno/main d7ccfba)

## Goal
Statement:  An `L:autonomous-mode` that makes AXON's *use* visible — **separating the
            autonomous agent's reasoning from AXON's program/tool execution**, narrating
            each AXON invocation verbosely (via `narrate`), and emitting a **structured
            trace** (ts · kind program|tool · name · why · result-summary) so a run can be
            replayed for reporting, training, and understanding "how AXON is being used."
Acceptance:
  - `L:autonomous-mode` (default OFF); when ON, every program EXEC + TOOL call is
    surfaced as a distinct, labeled line (agent-action vs AXON-execution visually
    separated) via `narrate`;
  - a parseable trace record per invocation appended to E:session-log (or a dedicated
    trace file);
  - a `trace` view that renders the run as a readable timeline — the reporting/training
    artifact;
  - OFF = zero overhead (no extra narration, no trace) — fully reversible.
Rejection:  on by default; narration without the structured trace (unreportable); trace
            not parseable; any non-reversible behavior; overhead when OFF.

## Why
Today the agent's reasoning and AXON's execution blur together in one stream. Making
them **separate + verbose** (a) lets you *see* how AXON is actually driven, (b) yields a
clean trace for reporting + for *training* future routing/anticipation, and (c) completes
the proprioception trifecta: control-strip = what's queued · anticipation = what's next ·
this = what AXON is doing now.

## Blast radius (I-05)
Affected: extend `tools/narrate.py` (structured-trace emit) · a trace view (`tools/trace.py`
or `narrate trace`) · workspace + REGISTRY · a small OUTPUT-LAYER gate for autonomous-mode
(kernel, human-merge). Default-OFF ⇒ no behavior change unless enabled.

## Tests (mandatory)
- mode OFF → no trace, no extra narration (zero overhead asserted).
- mode ON → each EXEC/TOOL emits a parseable trace record + a separated narration line.
- the trace view renders a readable timeline from the records.

## Notes
Builds on `narrate` (shipped) — extend it to emit the structured trace; do not reinvent.
The trace IS usage data, so it also feeds phase-1 telemetry and phase-7's anticipation
(training signal). This is the observability/reporting/training surface for "how AXON
operates" — the separation the user asked for.
