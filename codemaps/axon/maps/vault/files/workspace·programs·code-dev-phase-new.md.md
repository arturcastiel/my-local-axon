---
tags: [code, file]
path: workspace/programs/code-dev-phase-new.md
---

# workspace/programs/code-dev-phase-new.md

> 49 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `(dag.py verify flags MISSING_CHILD_DAG if the target doesn't exist) — this is`
- `(project level). Bootstrap if absent, add the phase node, wire predecessor edges.`
- `ALREADY mutated → DAG has the node, the manifest does not = split-brain (the same class as the`
- `Before scaffolding the next phase, verify each predecessor satisfied its`
- `Bootstrap the phase's own PR-DAG so the child-dag link is valid from creation`
- `C1 split-brain fix (axon-hr-ui PR-001): DAG.json above is the render/graph, but the`
- `CASCADE TO PHASE-DAG (the project-level DAG is the phase graph — single truth)`
- `CASCADE TO PHASE-MANIFEST (_phases.json — the node-order SSOT)`
- `Each phase's PR-DAG nests under phases/{phase}/03-prs/DAG.json (infinite nesting).`
- `HELP`
- `IDENTITY LOCK`
- `OUTPUT`
- `PHASE-TRANSITION GATE (ADR-004) — warning-only rollout`
- `PR-001 bug). Validate every predecessor is a KNOWN phase BEFORE any mutation, so a bad`
- `PROGRAM: code-dev-phase-new`
- `Previously a custom phase NEVER reached it → an unresolvable PHASE SPLIT-BRAIN warning`
- `Register in masterplan`
- `The cascade below adds the phase node + edges to DAG.json, THEN `phase-model add --after``
- `VALIDATE PREDECESSORS (GAP-HARDENING rank 4b — prevent DAG/manifest split-brain)`
- `and a gate guarding the frozen default ladder. Add the node to the manifest too.`
- `at the moment it would happen. Flip L:phase-gate-enforce=true to make`
- `budget:`
- `cache-prefix: 2048`
- `closing-artifact contract. In warn mode (L:phase-gate-enforce=false,`
- `code-dev-phase-new.md`
- `contract-version: neuron-contract v1.1`
- `default) this NEVER blocks — it surfaces a ⚠ so phase drift is visible`
- `desc:    Scaffold a new phase folder with all 9 stub files; register in masterplan`
- `domain: code-dev`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    8000`
- `inputs-count: 2`
- `inputs:  interactive: phase-name, predecessor(s)`
- `invocation_source: [program]`
- `masterplan.md is a render; the phase graph itself lives in {proj-dir}/DAG.json`
- `node-order gate (R_WORKFLOW_NODE_ORDER / phase_model) reads {proj-dir}/_phases.json.`
- `output-cap:   2000`
- `outputs-count: 12`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND project ≠ ∅ AND meta.schema-version ≡ \"v4\" AND phase-name MATCHES \"^[a-z0-9-]+$\" AND NOT DIR-EXISTS(phase-dir)"`
- `predecessor fails cleanly with nothing half-written.`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `the explicit infinite-nesting link: project DAG ⊃ phase node → its PR-DAG.`
- `the gate fail closed once teams trust it.`
- `usage:   code-dev phase new`
- `writes _phases.json. If a predecessor is UNKNOWN, phase-model add RAISES — but the DAG was`

## Depends on
- (none)
