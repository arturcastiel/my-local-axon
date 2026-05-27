# Proposed AXON workflow designs (study layer 4-5)

Three first-class workflows to carve out, expressed in AXON's Fixed/Adaptive/
Hybrid model. These exercise the existing workflow engine + orchestrator +
the new mcp_client + the domain review gate.

## WF-1 · reservoir-screening  (FIXED — linear DAG with gates)
The simplest complete end-to-end; best first build. Mirrors course modules 7→1→3→6.
```
[qa] ──ok──▶ [water-cut] ──▶ [dca-fit] ──▶ [eur] ──▶ [review] ──▶ DONE
  │                                                      ▲
  └─ fail ─▶ HALT "QA failed: {reasons}"                 │
            (schema/dates/nonneg/dup/monotonic)   domain-output-standard gate
```
- inputs: production CSV (date, well, oil/water/gas), economic limit
- each step emits the output-standard block (inputs/units/method/result/sanity/assumptions)
- `dca-fit` + `eur` call MCP `fit_decline` / `estimated_ultimate_recovery`
  (or hand-rolled exponential for the screening teaching case)
- review step = `reservoir-review` gate: units, monotonic EUR vs limit, nonneg rates
- termination: linear; rejection-criterion = qa fail OR review BLOCK

## WF-2 · reservoir-pvt-table  (FIXED — convergent DAG)
Builds a consistent black-oil table for a simulator. Mirrors modules 5/8.
```
[recommend-methods] ──▶ [oil-pvt] ──┐
                                    ├──▶ [harmonize] ──▶ [black-oil-table] ──▶ [review] ──▶ DONE
[recommend-methods] ──▶ [gas-pvt] ──┘
```
- MCP tools: recommend_oil_methods/recommend_gas_methods → oil_* / gas_* →
  oil_harmonize_pvt → generate_black_oil_table → review
- param-pitfall guard: oil uses sg_g, gas uses sg (the domain gate checks this)
- output: PVTO/PVDO/PVDG/PVTW table + provenance (every value's method+units)

## WF-3 · reservoir-sensitivity  (ADAPTIVE/HYBRID — fan-out + aggregate)
The headline machinery test. Mirrors module 9. This is where AXON's
orchestrator + SPAWN + workflow loop earn their keep.
```
                 ┌─▶ [case: STAN] ─┐
[expand-cases] ──┼─▶ [case: VALMC]─┼──▶ [aggregate] ──▶ [review] ──▶ DONE
                 └─▶ [case: VELAR]─┘        │
   (cartesian of                            └─ NO averaging across unlike methods;
    pb×Zmethod×skin)                           flag scenarios needing engineer review
```
- expand: build the independent case matrix (e.g. 3 pb × 3 Z × 3 skin = 27)
- each case: independent MCP calc returning {inputs, method, result, sanity}
  — fan out via orchestrator candidates or SPAWN(subagent) per case
- aggregate: structured table (Method|Units|Result|Sanity|Recommendation);
  the "do not average unlike methods" rule is a hard aggregation constraint
- this is ADAPTIVE because case count/ْchoice can depend on the recommend step;
  HYBRID if a fixed skeleton (expand→fan→aggregate→review) wraps an adaptive
  inner case-selection

## Connection architecture (layer 5 — "do we connect differently?")
1. **New connection type: MCP egress.** AXON gains an outbound tool-call path
   to external MCP servers via mcp_client. This is genuinely new wiring (AXON
   has only had internal tools). pyrestoolbox-mcp = first consumer.
2. **Domain review gate as a response-gate.** Not a program you call — a gate
   that fires on `reservoir-*` output, same architectural slot as the kernel
   coherence guardian, but domain-scoped + opt-in-enforced.
3. **Fan-out via existing orchestrator/SPAWN**, NOT a new parallel engine. The
   audit's anti-pattern warning applies: don't build multi-agent orchestration
   for parity — reuse workflow+orchestrator.
4. **Output-standard as a TRANSLATE convention** for the reservoir family, so
   every calc renders the inputs/units/method/result/sanity/assumptions block.

## What this proves about the machinery
- WF-1 proves Fixed workflows + gates handle linear engineering pipelines.
- WF-2 proves convergent DAGs + provenance tracking.
- WF-3 proves the fan-out/aggregate machinery (the audit's lever #16 SPAWN +
  workflow engine) on a real independent-case problem.
If all three run clean, AXON's workflow machinery is validated for a real
technical domain — which is itself a strong artifact for the axons-audit thesis.
