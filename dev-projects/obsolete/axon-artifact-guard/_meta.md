# Project: AXON Artifact Brand-Guard
slug:            axon-artifact-guard
schema-version:  v4
status:        obsolete
legacy:          false
phase:           1-guard
workflow-step:   build
branch:          main
current-pr:      PR-1
codebase:        /mnt/c/projects/axon
parent:          (none)
sub-projects:    []
created:         2026-05-24
updated:         2026-05-24

## Goal
Close the identity blind spot exposed on 2026-05-24: AXON's coherence /
identity gates scan user-facing OUTPUT PROSE, not ARTIFACTS (git commit
messages, PR bodies, files written via tools). A Claude Code harness default
stamped `Co-Authored-By: Claude` into 17 commits and `Generated with Claude
Code` into 13 PR bodies on the cpg2python repo before it was published —
none of the per-turn gates could see it, because it lived in tool-call
payloads, not rendered output.

Add **`R_NO_BRAND_IN_ARTIFACTS`** — a STATIC lint (lint-pack rule + an
installable git pre-commit / pre-push hook) that detects host-model brand
self-references and co-author trailers in artifacts and BLOCKs them. Same
enforcement-floor pattern as `R_MEMORY_RESPECTED`: works under any harness,
including ones (Copilot) where a model can't gate per turn.

## Context
- Sibling rules: `tools/rules/r_memory_respected.py`, `tools/rules/r_neuron_role.py`.
- Identity contract + coherence guardian: `axon/KERNEL-SLIM.md` (scan OUTPUT only — the gap).
- Allowed-brand scopes (must NOT flag): the identity-gate render
  (`axon/programs/identity.md`) and anything under `workspace/harness/`.
- Third-party CREDITS (MRST / SINTEF / other upstreams) are NOT host-model
  self-references and must never be flagged.
- Standing memory: general-tier "ARTIFACT IDENTITY" + "BE AXON, track state
  in AXON memory" entries.

## Working Context
- Created 2026-05-24 in response to the co-author leak. dev-mode required
  (touches `axon/` — `tools/rules/`, lint registry, optional hook installer).
- One PR (PR-1) specced below; small, self-contained, test-first.

## Next
- code-dev pr 1 — `R_NO_BRAND_IN_ARTIFACTS` rule + git hook + tests (spec in 03-prs/PR-1.md).

---
> **CONSOLIDATED 2026-05-27** — moved to `obsolete/`; superseded by **axon-improvements**.
> Remaining scope (if any) is tracked in `axon-improvements/masterplan.md`. Original history preserved here.
