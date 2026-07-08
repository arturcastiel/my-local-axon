# ADR-001 — Doctrine graph: workflow-YAML authored, DAG.json derived

**Schema**: adr-v1 · **Status**: accepted · **Date**: 2026-07-08
**Owner**: axon-next · **Supersedes**: the 01-study.md S4 lean ("extend dag.py")

## 1. Title
The doctrine graph is authored as workflow YAML and executed by the existing
advance-guard stack; DAG.json is a one-way derived ledger (statuses, provenance,
mermaid fluxogram).

## 2. Status
Current: **accepted** (owner: "continue" on the council-rebuilt plan, 2026-07-08)

## 3. Context
The doctrine needs ONE graph that is proposed by AXON, validated against the project,
rendered as a human fluxogram, and then obeyed at run time. The study found a
split-brain (G2): workflow YAML carries conditional edges + the entire execution stack
(schema, four lints, advance guard with trajectory anti-skip + sub-workflow +
output-completeness teeth) but no status ledger; DAG.json carries the status/provenance
ledger but no conditions and no executor. The study's lean was to extend dag.py.

## 4. Decision
Flip it. The plan council's architecture seat overturned the lean with source evidence:
- dag.py's cycle guard structurally REJECTS the legal back-edges real routines need
  (workflow_run.py:11-14 declares them legal; dag.py:160-163 refuses them) — execution
  edges would need a guard-exempt new kind that every existing dag algorithm ignores.
- The execution teeth are keyed to the workflow dict shape (advance/next_allowed/
  terminals/trajectory all read synapses[].on-complete) — a dag-based runner means a
  projection adapter, i.e. a second place edge semantics live.
- check-stale / validate-draft / check-templating have no DAG.json entry point — the
  "zero new detection code" preflight claim only survives under the YAML format.
- The repo already owns the needed idiom: canonical file + one-way rendered mirror
  (dag.py:23) and plan_dag's derive-DAG-from-source precedent.
We will author doctrine routines as workflow YAML (typed node kinds + outputs land as
schema enums — PR-010), and PROJECT the run's DAG.json + mermaid fluxogram from the
routine + trajectory + receipts (PR-013). The ledger is a view; authoring it is illegal.

## 5. Alternatives
| option | summary | why-rejected |
|--------|---------|--------------|
| Extend dag.py into an executor (study S4) | typed nodes + conditional edges + advance wrap | builds a second, worse workflow engine: cycle-guard exemption, fresh validators, rule-ordering respec, runner adapter — council 4/10 |
| Two formats, hand-synced | keep both authorable | the G2 split-brain the doctrine exists to kill |

## 6. Consequences
**Positive**: full reuse of the toothed execution stack; split-brain dead by
construction; preflight is pure composition; fluxogram = mermaid of the derived ledger.
**Negative / costs**: a ~100-line projector to maintain; dag.py stays a
plan/PR-ledger engine (its execution ambitions end here).
**Follow-up actions**: PR-010 (schema kinds), PR-013 (projector + render), PR-014
(runner binds the YAML), doctrine-v2 stub carries any future dag.py convergence.

## 7. Related
- Plan: [`../02-plan.md`](../02-plan.md) — decision D1 + council record.
- Study: [`../01-study.md`](../01-study.md) — G2/G3/G12, S4 (superseded by this ADR).
