---
tags: [code, file]
path: workspace/programs/workflow-new.md
---

# workspace/programs/workflow-new.md

> 57 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `(esp. when: vs if: in on-complete edges, dangling next:, missing`
- `- Calls workflow-validate before save; aborts on schema error.`
- `- Follows conversational-author-v1.md phases A→E.`
- `- Mid-dialog state preserved in W:_workflow-author-state (resumable).`
- `- Uses synapse-suggest for each synapse-by-synapse ranking.`
- `All user-facing → "..." lines below render through the OUTPUT layer.`
- `Banner: → "▶ AXON / workflow-new  ·  ..."  (rendered on entry to RESUME / PHASE-A).`
- `C9: the PHASE-C loop pre-wires each synapse with on-complete next:s{step+1}; the FINAL synapse then`
- `Convergence wiring: if the default-goal has a measurable acceptance metric, offer a`
- `Goal E — a workflow with a target/metric becomes self-improving by default).`
- `HELP`
- `IDENTITY LOCK`
- `OUTPUT → PYTHON_FAST · dialog`
- `PHASE-A — Name + domain + execution-mode`
- `PHASE-B — Goal capture`
- `PHASE-C — Synapse-by-synapse build (loop)`
- `PHASE-D — Triggers + suggestions controls`
- `PHASE-E — Validation + save`
- `PROGRAM: workflow-new`
- `Persist PHASE-D outputs + advance, so a resume into PHASE-E has triggers/allow-* (audit: resume read`
- `RESUME-IF-PRESENT`
- `Sub-goal C · pre-write validation: catch the common authoring traps`
- `a CONVERGENCE CONTRACT when the workflow declares a measurable target (wires Goal C into`
- `axon workflow-new from "<description>"`
- `axon workflow-new resume      — resume paused dialog`
- `axon-plus pr-21a — CLOSE the authoring loop: dry-run SIMULATE so the author previews`
- `budget:`
- `cache-prefix: 1024`
- `contract-version: neuron-contract v1.1`
- `desc:    Conversational author for a workflow file (per conversational-author-v1.md). Walks dialog phases A→E and emits a v1-valid workflow YAML.`
- `desc:  Interactive dialog that authors a workflow file from natural language.`
- `dispatch-phrases: author a new workflow · build a workflow · create a workflow file · design an automated flow`
- `domain: workflow`
- `family: [workflow]`
- `glossary: AXON-GLOSSARY v2`
- `input-cap:    4000`
- `inputs-count: 5`
- `invocation_source: [program, user]`
- `loop-contract so runs are tracked toward it (human-set budget — never inferred).`
- `next-suggests: [workflow-validate, workflow-list, workflow-simulate]`
- `notes:`
- `output-cap:   1500`
- `outputs-count: 3`
- `per-phase question lists this neuron SHOULD ask were extracted there`
- `points at an s{N+1} that is never created (dangling-next), which workflow-validate rejects — so`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\""`
- `registry is at workspace/programs/workflow-new-questions.yml — the`
- `required keys) BEFORE the YAML hits disk. The companion questions`
- `role: mutator`
- `so they can be reused, audited, and extended without code changes.`
- `status: ACTIVE`
- `synapse:`
- `the path before any real run (Goal-E pain: "preview what the run would do"), and attach`
- `unhydrated locals at D/E).`
- `usage: axon workflow-new`
- `workflow-new could never save a non-empty workflow. Make the last synapse terminal before validating.`
- `workflow-new.md`

## Depends on
- (none)
