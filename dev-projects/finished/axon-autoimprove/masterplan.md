# Masterplan — AXON Auto-Improve

## Vision

> The composition path observes itself. Narrow, reversible improvements
> apply automatically when the user opts in. Every action is logged,
> every action is undoable, and the drift gate is never bypassed.

## Phase graph (directed)

```
1-study  →  2-design  →  3-implement  →  4-validate
  ACTIVE       ⬜            ⬜              ⬜
  audit AUDIT.md  contract specs  PR series      baseline +
  + risk map      for 3 actions   ~6-10 PRs      7-14 day
  + lived-data    + receipt       + telemetry    metric capture
  inventory       schema          baseline       + hit-rate proof
```

- **1-study** — re-read axon-synapse AUDIT.md; inventory what `L:auto-improve`,
  PR-120 cron stub, and synapse's hit-rate counter already provide; map the
  three actions (compile / tune / archive) against current `tools/` surface;
  list every reversibility primitive available today; identify gaps.
- **2-design** — author one spec per auto-action: contract, trigger condition,
  reversibility primitive, drift-gate integration, receipt schema. Author
  `E:auto-improve-log` schema. Decide ephemeral-promotion threshold (D-21
  inherited or revised). Ratify ADRs.
- **1-implement** — PR series, narrow scope each, all reversible:
  - PR-201 — `auto-improve` orchestrator program (cron entry + drift gate + opt-in + idle-gap confirm)
  - PR-202 — receipt writer + two-phase commit + idempotent key (D-A15)
  - PR-203 — auto-compile action + reversibility
  - PR-204 — auto-tune action **bidirectional** + closed-loop revert branch (D-A13/A16)
  - PR-205 — auto-archive action + rate limit + collision handling (D-A20, FA-04)
  - PR-206 — ephemeral-suggestion auto-promotion with D-A14 accept definition
  - PR-207 — telemetry baseline capture + monthly rotation
  - PR-208 — `auto-improve rollback --days N` global undo (D-A18)
  - PR-209 — axon-audit 1d section (auto-improve log row)
  - PR-210 (opt) — receipt line in OUTPUT-LAYER footer [dev-mode]
- **4-validate** — flip `L:auto-improve = true` on a real branch; run for
  14 days; capture baseline + post-baseline; verify hit-rate improved on at
  least one signal; rollback proof exercised at least once.

## Non-goals (Phase 1)

- No code changes in study phase. Only `phases/1-study/` artefacts.
- No new programs in study phase.
- No dev-mode flip in study phase.

## Phase progression

Phases are added by `code-dev phase new`. First phase `1-study` is
scaffolded — run `code-dev study` to populate `01-study.md`.

## Seed inputs

- `../axon-synapse/AUDIT.md` — the audit that motivated this project.
- `../axon-synapse/RETRO.md` § "What we deferred" — the explicit carry-forward.
- `../axon-synapse/_flaws.md` § "Carried forward as Phase-4 work" — GAP-07
  (ranker tuning labels) is a direct input here.
- `tools/synapse_suggest.py` — existing ranker; tune target.
- `workspace/programs/orchestrator.md` — existing loop; orchestration hook lives here.
- `axon/OUTPUT-LAYER.md` § SUGGESTIONS FOOTER — existing surface; optional receipt line.
