---
tags: [code, file]
path: workspace/programs/workflow-edit.md
---

# workspace/programs/workflow-edit.md

> 33 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `- Schema-checks via workflow-validate before write; aborts on failure.`
- `- Writes a `.bak` sibling so the prior version is recoverable.`
- `Banner + current-state summary + interactive prompts; final confirmation line on save.`
- `DIALOG`
- `HELP`
- `IDENTITY LOCK`
- `LOCATE TARGET`
- `OUTPUT → PYTHON_FAST · dialog`
- `PROGRAM: workflow-edit`
- `SAVE`
- `axon workflow-edit --path <path>`
- `budget:`
- `cache-prefix:  512`
- `contract-version: neuron-contract v1.1`
- `desc:    Interactive editor for an existing workflow file (rename synapse, change triggers, swap goal). Validates before save.`
- `desc:  Edit a saved workflow file (per WORKFLOW-FILE.md v1).`
- `dispatch-phrases: edit a workflow · change a workflow step · rename a synapse · swap the goal`
- `domain: workflow`
- `family: [workflow]`
- `glossary: AXON-GLOSSARY v2`
- `input-cap:    3000`
- `inputs-count: 4`
- `invocation_source: [program, user]`
- `next-suggests: [workflow-validate, workflow-simulate, workflow-run]`
- `notes:`
- `output-cap:   1200`
- `outputs-count: 2`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND target ≠ ∅ AND FILE-EXISTS(target)"`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `usage: axon workflow-edit --name <name>`
- `workflow-edit.md`

## Depends on
- (none)
