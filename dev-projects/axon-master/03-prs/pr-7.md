# pr-7 — Failure-mode catalog + postmortem template

**Wave**: W1 · **Goals**: G.safe.01, G.safe.02, G.safe.09 (hygiene) · **Depends-on**: none

## Why (problem statement)
R6 produced a **34-entry failure-mode catalog** across 8 classes (A-H), but it lives in a helper file (`cd-gap-c2-p4-failure-modes.md`) and is not the canonical AXON-OS-level resource. R6 also calls out U-4 ("failure-mode catalog") as a Tier-1 unaddressed gap. Without a catalog at `workspace/log/failure-modes.md` and a postmortem template, every incident is re-investigated from scratch (see 2026-05-15: persona drift + unauthorized push — no postmortem written). This PR promotes the helper to a workspace asset and adds the postmortem template that closes the incident loop.

## Evidence (from studies)
- `helpers/cd-gap-c2-p4-failure-modes.md` → full catalog with 34 modes across classes A-H; explicitly notes "this file becomes the seed for `workspace/log/failure-modes.md`".
- `helpers/cd-gap-c4-p2-priority-matrix.md` → mitigation priority top-10 used to focus W1-W3 work.
- User memory: 2026-05-15 incident logged but no postmortem template existed.
- `helpers/cd-gap-c1-p3-goals-extracted.md` → G.safe.01 (catalog), G.safe.02 (postmortem template), G.safe.09 (catalog hygiene with `last-reviewed`).

## Design notes
- Copy/adapt the R6 catalog into `workspace/log/failure-modes.md`. Each entry:
  ```
  ### F-A1 — Persona-bleed after compaction
  - class: A (identity)
  - trigger: long session, context compacted
  - signal: "As an AI…" / drops AXON identity
  - mitigation: boot re-anchor; identity gate; first-action check
  - owner: kernel (axon/programs/identity.md)
  - last-reviewed: 2026-05-17
  ```
- Target: ≥ 25 modes across classes A-H (the R6 helper has 34; copy all).
- `workspace/templates/postmortem.md`:
  ```
  # Postmortem: <title> — <ISO date>
  ## Summary (1-2 sentences)
  ## Timeline (UTC)
  ## Class (from failure-mode catalog): F-…
  ## What worked
  ## What didn't
  ## Lessons
  ## Action items
  - [ ] <gate / test / rule> (owner, due)
  ```
- Render one **synthetic example postmortem** as `workspace/log/postmortems/example-F-A2-2026-05-15.md` so the template's shape is concrete.
- `last-reviewed` field is **hygiene**: PR-22 (`rules audit`) will later check that no entry is > 180 days unreviewed and warn.

## Pitfalls (from failure-mode catalog)
- **F-F2 catalog itself drifts / bitrots** → `last-reviewed` field + PR-22 audit.
- Examples too thin → require ≥ 1 synthetic worked postmortem.

## Interface sketch
```text
$ wc -l workspace/log/failure-modes.md
185 workspace/log/failure-modes.md
$ grep -c '^### F-' workspace/log/failure-modes.md
34
$ ls workspace/log/postmortems/
example-F-A2-2026-05-15.md
```

## Spec (canonical)
- **Files**:
  - new: `workspace/log/failure-modes.md`, `workspace/templates/postmortem.md`, `workspace/log/postmortems/example-F-A2-2026-05-15.md`.
- **Acceptance**:
  1. ≥ 25 failure modes across classes A-H (target: full 34 from R6 helper).
  2. Each entry has class, trigger, signal, mitigation, owner, `last-reviewed`.
  3. Postmortem template renders one synthetic worked example (F-A2 push incident from 2026-05-15).
  4. `last-reviewed: <ISO date>` present on every entry.
- **Rollback**: `git rm` the three files.
- **Owner**: AGENT writes; HUMAN reviews catalog accuracy.

## Cross-refs
- Master plan: `../03-plan.md` § Wave 1 / PR-7.
- Helpers: `helpers/cd-gap-c2-p4-failure-modes.md` (source-of-truth seed), `helpers/cd-gap-c4-p2-priority-matrix.md` (top-10 mitigations).
- User memory: 2026-05-15 incident → example postmortem here.
