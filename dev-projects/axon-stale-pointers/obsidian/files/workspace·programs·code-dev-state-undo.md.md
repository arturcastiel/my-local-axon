---
tags: [code, file]
path: workspace/programs/code-dev-state-undo.md
---

# workspace/programs/code-dev-state-undo.md

> 31 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `<iso-ts>  <action-id>  <op>  <target>  <before-snapshot-path>`
- `HELP`
- `IDENTITY LOCK`
- `OUTPUT`
- `PROGRAM: code-dev-state-undo`
- `Parse: iso  id  op  target-path  snapshot-path`
- `Pick target action`
- `Record undo in actions log (so undo can be re-undone... eventually)`
- `Restore from snapshot (file-level) or copy back from snap directory`
- `budget:`
- `cache-prefix: 2048`
- `code-dev undo <id>        # reverse the action with given id`
- `code-dev undo list        # list last 10 reversible actions`
- `code-dev-state-undo.md`
- `contract-version: neuron-contract v1.1`
- `desc:    Reverse the last write recorded in _actions.log`
- `domain: code-dev`
- `family: [code-dev]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `input-cap:    8000`
- `inputs-count: 3`
- `invocation_source: [program]`
- `output-cap:   2000`
- `outputs-count: 2`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND project ≠ ∅ AND target ≠ ∅ AND snap-path ≠ ∅ AND FILE-EXISTS(snap-path) AND snap-path ≠ ∅"`
- `requires: write programs must append to {project}/_actions.log with format:`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `usage:   code-dev undo             # reverse the last write (asks confirmation)`

## Depends on
- (none)
