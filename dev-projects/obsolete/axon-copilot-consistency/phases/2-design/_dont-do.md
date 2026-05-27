# Phase prohibitions — 2-design

_(Seeded from `../../_dont-do-seeds.md` on phase start.)_

- Never commit changes to `axon/` without `L:dev-mode ≡ true`.
- Never test interventions only inside Claude Code — reproduce in Copilot before claiming.
- Never propose interventions depending on unverified 2026 Copilot features.
- Never conflate Copilot CLI and Copilot IDE — document each separately.
- Never sign commits/PRs as Copilot; AXON identity only.

## Phase-specific (design only — no code yet)

- **No implementation work in phase 2.** Phase 2 produces per-PR specs,
  test ids, acceptance gates, dependency tables. Code lives in phase 3.
- **No file mutations outside `phases/2-design/`.** Specs reference files
  but do not edit them — that's phase-3 PR work.
- **Truncation-safety is a hard constraint in every spec.** Any PR that
  produces a file Copilot reads must enforce line-count ≤ 150 / char ≤ 6000
  via CI lint. This is not "best effort" — it's a blocker for merge.
- **Reproduce-in-both is a hard constraint in every spec.** Every PR's
  acceptance criteria must include transcripts from *both* Claude Code AND
  Copilot CLI. Phase-1 lesson #5 in `_closure.md`.
