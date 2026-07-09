---
tags: [code, file]
path: workspace/programs/gain.md
---

# workspace/programs/gain.md

> 37 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `(.estimated_tokens_used / .tee_saves) that `context status` never emits. Rebuilt over`
- `Deps:    context, stats`
- `Honest starvation statement (owner decision D2, bugfix02): per-program run counts`
- `LOAD CONTEXT`
- `OUTPUT`
- `PROGRAM: gain`
- `STEP 1 — Read the data that actually exists (bugfix02 C2 rebuild)`
- `STEP 2 — Compute period filter`
- `STEP 3 — Aggregate real activity signals`
- `STEP 4 — Read context tracker (real fields: accumulated_tokens/percent/pressure)`
- `STEP 5 — Read health score history`
- `STEP 6 — RTK panel (guard the stub: the probe returns a truthy JSON envelope even`
- `The old panels aggregated s.turn_count / s.programs_run / s.drift_events / s.errors`
- `Turn activity from the daily turn logs (real files; one `## <timestamp>` block per turn)`
- `and the real context-status fields.`
- `contract-version: neuron-contract v1.1`
- `desc:    Longitudinal session analytics — context savings, program usage, efficiency trends`
- `domain: meta`
- `family: [meta]`
- `gain.md`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `inputs-count: 3`
- `invocation_source: [program]`
- `need a usage recorder on the agent-side execution path; none exists (tools/run.py's`
- `outputs-count: 1`
- `per session-log row — fields the rows NEVER carry (real rows: | Time | Event | Notes |`
- `precondition: "true"`
- `real sources: E:session-log row counts, workspace/log/turns/ daily files (turn counts),`
- `recorder is off-path). Stating that beats rendering a plausible zero table.`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `the old truthy check made the panel read fields that don't exist, bugfix02 M-class)`
- `version: 1.0.0`
- `when the optional CLI is absent — its real marker is status="not_installed";`
- `with events `checkpoint`/`session-saved` only), and read context fields`

## Depends on
- (none)
