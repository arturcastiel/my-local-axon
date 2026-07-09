---
tags: [code, file]
path: workspace/programs/turn-log.md
---

# workspace/programs/turn-log.md

> 35 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `- Each entry: turn number · timestamp · active program · IN summary · OUT summary`
- `- Primary purpose: context reconstruction for `resume` and session handoff`
- `- Turn logging is ON by default (L:turn-log-enabled ≠ false)`
- `- Written automatically by the kernel response gate (!BG, non-blocking)`
- `DISPATCH`
- `FILTER`
- `GUARD`
- `LOAD TURNS`
- `OUTPUT`
- `PROGRAM: turn-log`
- `SECTION:TOGGLE-OFF`
- `SECTION:TOGGLE-ON`
- `contract-version: neuron-contract v1.1`
- `desc:    View, search, and manage the per-turn input/output summary log`
- `domain: turn`
- `family: [turn]`
- `glossary: AXON-GLOSSARY v2`
- `inferred-by: synapse-infer (PR-108 bulk migration)`
- `inputs-count: 4`
- `inputs:  workspace/log/turns/YYYY-MM-DD.md`
- `invocation_source: [program]`
- `notes:`
- `outputs-count: 2`
- `outputs: formatted turn log display`
- `precondition: "true"`
- `role: mutator`
- `status: ACTIVE`
- `synapse:`
- `turn-log --days N      — show last N days`
- `turn-log --off         — disable turn logging (L:turn-log-enabled ← false)`
- `turn-log --on          — enable turn logging  (L:turn-log-enabled ← true)`
- `turn-log --search STR  — search all turns for keyword`
- `turn-log --turn T      — show specific turn number`
- `turn-log.md`
- `usage:   turn-log               — show today's turn log`

## Depends on
- (none)
