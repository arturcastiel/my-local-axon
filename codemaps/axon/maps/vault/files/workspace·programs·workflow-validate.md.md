---
tags: [code, file]
path: workspace/programs/workflow-validate.md
---

# workspace/programs/workflow-validate.md

> 49 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `Banner + valid/invalid verdict + error list + optional warnings. Side-effect-free.`
- `C1/C4/C8 workflow-death class. Scoped to the target file. Severity mapping:`
- `CLI-exposed, but validate never called them — the exact lints that would have caught the`
- `Cycle detection over on-complete.next (plan_dag.py Kahn's algorithm). Note:`
- `HELP`
- `LOCATE`
- `OUTPUT → PYTHON_FAST · doc`
- `PROGRAM: workflow-validate`
- `Reachability from start over on-complete.next: any synapse the start can never`
- `Semantic checks beyond JSON-schema (graph-level invariants)`
- `Soft warnings`
- `VALIDATE`
- `Wired lints (axon-bugfix01, H5): check-stale + check-templating existed, unit-tested and`
- ``errors`/`warnings` are the human-readable string lists; `error-count`/`warning-count``
- `acyclic — so a cycle is a WARNing here, not a hard error, lest validate reject`
- `are the integer tallies callers MUST guard on (workflow-run/simulate/edit compare a`
- `axon workflow-validate --name <name>          — workspace/workflows/<name>.yml`
- `axon workflow-validate --strict               — also fail on warnings`
- `budget:`
- `cache-prefix:  256`
- `canonical workflows DECLARE legal back-edges (e.g. self-review→fix, audit→plan)`
- `contract-version: neuron-contract v1.1`
- `count, not a list — `v.errors ≡ 0` against a list never matches). Prefer `ok`.`
- `desc:    Validate a workflow YAML file against workspace/schemas/workflow-file.schema.json (PR-105). Returns {ok, errors[]}.`
- `desc:  Schema-validate a workflow file (no side-effects). Wraps PR-105 schema.`
- `dispatch-phrases: validate a workflow · check the workflow schema · is my workflow valid`
- `domain: workflow`
- `family: [workflow]`
- `glossary: AXON-GLOSSARY v2`
- `input-cap:    1500`
- `inputs-count: 1`
- `invocation_source: [program, user]`
- `missing-neuron / tool-not-program → ERROR  (the workflow cannot dispatch that synapse)`
- `next-suggests: [workflow-edit, workflow-simulate, workflow-run]`
- `output-cap:    500`
- `outputs-count: 1`
- `precondition: "target ≠ ∅ AND FILE-EXISTS(target)"`
- `reach is an orphan (warn — it is structurally suspect but not schema-invalid).`
- `role: reader`
- `start must reference a real synapse id (WORKFLOW-FILE.md Validation item 2;`
- `status: ACTIVE`
- `stub-neuron                        → WARN   (runs but does nothing; stubs are grandfathered)`
- `synapse:`
- `templating (foreign-domain copy)  → ERROR  (the C8 copy-paste class)`
- `that workflow-run terminates via its step-count/rejection bound, NOT by being`
- `the JSON schema only enforces start is a non-empty string, not referential).`
- `the flagship's own runtime-bounded loops (and strand run/simulate preflight).`
- `usage: axon workflow-validate --path <wf.yml>`
- `workflow-validate.md`

## Depends on
- (none)
