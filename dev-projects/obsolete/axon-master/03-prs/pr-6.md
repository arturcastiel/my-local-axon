# pr-6 — One-page cheatsheet

**Wave**: W1 · **Goals**: G.doc.10 · **Depends-on**: none

## Why (problem statement)
R4 documents F-F1 ("user can't find the right verb") with 57 user-facing verbs and no single-page entry point. R4 layer-1 helper `cd-wf-c1-p2-entry-points.md` literally proposes a cheatsheet as the #1 discoverability fix. The cheatsheet is a leaf deliverable (no upstream PR dependencies) and gives the rest of W1 a published reference. PR-34.5 later turns the verb table into an auto-generated section.

## Evidence (from studies)
- `helpers/cd-wf-c1-p2-entry-points.md` → "cheatsheet proposal" listed as the single best return-on-effort discoverability improvement.
- `helpers/cd-wf-c4-p1-synthesis.md` → cheatsheet appears in the three-pane view (Pane: "first 10 minutes").
- `helpers/cd-gap-c3-p3-documentation.md` → G.doc.10 acceptance: "one-page summary, ≤ 80 lines, links to existing docs only".
- `helpers/cd-gap-c2-p4-failure-modes.md` → F-F1 (Class F).
- R4 web findings `cd-wf-c1-p4-web-findings.md` → `kubectl` and `gh` both publish a one-page cheatsheet as primary onboarding artifact.

## Design notes
- `workspace/AXON-DOCS-CHEATSHEET.md`, ≤ 80 lines, sections:
  1. **Top 10 verbs** (one line each): `code-dev new / load / status / next / plan / pr / pr-review / pr-ready / study / handoff`.
  2. **5 canonical flows** (named WF1..WF5 per R4): onboard, start-PR, review-PR, ready-PR, resume-chat.
  3. **3 escape hatches**: `freeze`, `undo`, `state save/restore`.
  4. Links to deeper docs (only ones that exist after W1): `AXON-DOCS-GOVERNANCE.md` (PR-4).
- Reserve markers for PR-34.5 auto-section:
  ```
  <!-- AUTO-VERBS-START -->
  (verbs filled by docgen)
  <!-- AUTO-VERBS-END -->
  ```
  In W1, the section is hand-filled; PR-34.5 swaps to docgen output.
- No links to docs that do not yet exist (PR-23 etc.); the cheatsheet does not over-promise.

## Pitfalls (from failure-mode catalog)
- **F-F1 user can't find the right verb** → primary fix.
- **Cheatsheet bitrot** → tour cross-ref lint (PR-1, PR-31.5) + auto-section (PR-34.5).

## Interface sketch
```text
$ less workspace/AXON-DOCS-CHEATSHEET.md
# AXON code-dev — one-page cheatsheet

## Top 10 verbs
  code-dev new <slug>       create a project
  code-dev load             reattach to last project
  code-dev status           current state + next-action
  …

## 5 canonical flows
  WF1 onboard a repo:    new → load → study --mode=overview → plan
  WF2 start a PR:        plan → pr <N> → …
  …
```

## Spec (canonical)
- **Files**:
  - new: `workspace/AXON-DOCS-CHEATSHEET.md`.
- **Acceptance**:
  1. ≤ 80 lines.
  2. 10 verbs + 5 flows + 3 escape hatches present.
  3. Links resolve to existing W1 docs (no 404).
  4. Auto-section markers `<!-- AUTO-VERBS-START/END -->` present (filled by PR-34.5 later).
  5. HUMAN sign-off.
- **Rollback**: `git rm workspace/AXON-DOCS-CHEATSHEET.md`.
- **Owner**: AGENT writes; HUMAN reads + signs off.

## Codebase grounding
- **new**: `workspace/AXON-DOCS-CHEATSHEET.md` — alongside existing [`workspace/AXON-DOCS.md`](../../../../workspace/AXON-DOCS.md) (top-level reference). One-pager, ≤ 80 lines. Sections: 10 verbs (from `# desc:` in `code-dev-*.md` source files), 5 named flows (boot → study → plan → pr → review), 3 escape hatches (`code-dev resume`, `code-dev preflight`, `code-dev undo`).
- **inputs read**: walk [`workspace/programs/code-dev-*.md`](../../../../workspace/programs/) for `# desc:` lines (manual selection of 10 in W1; auto in PR-34.5).
- **future marker**: include `<!-- AUTO-VERBS-START -->` ... `<!-- AUTO-VERBS-END -->` markers now (no content yet) so PR-34.5 can fill them.

## Cross-refs
- Master plan: `../03-plan.md` § Wave 1 / PR-6.
- Helpers: `helpers/cd-wf-c1-p2-entry-points.md`, `helpers/cd-gap-c3-p3-documentation.md`.
- Future: PR-34.5 makes the verbs section auto-generated.
