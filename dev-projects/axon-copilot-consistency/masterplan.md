# Masterplan — AXON Copilot Consistency

## Phase graph (directed)

- ~~1-study~~ ✓ → **2-design** (active) → 3-build → 4-validation

Phase-1 closed 2026-05-20 (score 8.4/10). Phase-2 in progress — 6 PRs locked
(CC-201..CC-206), see `phases/2-design/_meta.md`.

Phases are added by: `code-dev phase new`

## Inputs from sibling project

- `my-axon/dev-projects/axon-copilot-anchor/phases/1-study/01-drift-vectors.md`
- `my-axon/dev-projects/axon-copilot-anchor/phases/1-study/02-anchoring-surface.md`

Both treated as **draft input, not authority** — re-validate from inside Claude
Code before lifting any claim.

## Existing harness files (reference, not target of phase-1 edits)

- `workspace/harness/copilot.md` — minimal stub (declares L:host-harness).
- `workspace/harness/claude-code.md` — minimal stub (declares L:host-harness + model from env).
- `startup.md` — "FOR THE AGENT (GitHub Copilot)" section explains the Copilot boot path.
- `.github/copilot-instructions.md` — (verify presence in phase-1).
- `.vscode/settings.json` — (verify presence + slot config in phase-1).
