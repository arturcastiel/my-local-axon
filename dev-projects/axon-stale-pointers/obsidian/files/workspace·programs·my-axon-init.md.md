---
tags: [code, file]
path: workspace/programs/my-axon-init.md
---

# workspace/programs/my-axon-init.md

> 49 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `A cloned repo lacks its gitignored dirs (memory/local, memory/working, log/turns…)`
- `BACKUP`
- `CONFIGURATION`
- `DISPATCH`
- `Explicit dispatch with an else — the old prompt had no else, so any typo fell`
- `FRESH, fresh-no-prompt re-runs, and CLONE (a cloned repo lacks its gitignored`
- `GUARD`
- `IDEMPOTENT — every op here is safe over a live my-axon/: mkdir -p and touch`
- `IDENTITY LOCK`
- `LOAD CONTEXT`
- `OUTPUT`
- `PATH MAP`
- `PROGRAM: my-axon-init`
- `Raw library files (PDFs) — shadow notes and explained docs are kept`
- `Runtime caches`
- `SECTION:CLONE`
- `SECTION:ENSURE-TREE`
- `SECTION:FRESH`
- `SECTION:PROMPT (mode = "prompt")`
- `SECTION:WRITE-MYAXON`
- `Scratch`
- `The old unconditional `echo '[]' >` TRUNCATED a populated event log on any`
- ``echo '[]' >` over a populated event log).`
- `below is guarded by existence, so a re-run over a live my-axon/ can never truncate`
- `contract-version: neuron-contract v1.1`
- `desc:    Initialize or clone the my-axon user-data folder`
- `dirs — memory/local, memory/working, … — so downstream writes used to target`
- `domain: my`
- `existence guard anymore — it runs in IDEMPOTENT-ENSURE mode instead: every create`
- `family: [my]`
- `fresh-no-prompt (used by migrate-workspace automation) is NOT exempt from the`
- `fresh-no-prompt re-run — the bugfix02 data-loss headline for this program.`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `inputs-count: 3`
- `invocation_source: [program]`
- `my-axon-init.md`
- `never destroy, and file WRITES are existence-guarded. This section is shared by`
- `nonexistent paths; bugfix02 CLONE-mkdir finding).`
- `or overwrite anything (bugfix02 data-loss class: the old exemption re-ran`
- `outputs-count: 18`
- `outputs: my-axon/ scaffolded + MYAXON.md written + W:myaxon-* keys set in session`
- `precondition: "L:cognition-frame ≡ \"AXON-OS\" AND url matches /^https?:\\/\\//"`
- `role: mutator`
- `status: ACTIVE`
- `straight through into the FRESH writes (bugfix02 data-loss class).`
- `synapse:`
- `usage:   my-axon-init [--mode=fresh | --mode=clone | --mode=fresh-no-prompt]`
- `— ensure the full tree before writing machine-specific MYAXON.md paths.`

## Depends on
- (none)
