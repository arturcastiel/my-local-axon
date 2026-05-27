# Phase 1 — Study — CLOSURE

slug:            1-study
schema-version:  v4
status:          CLOSED
opened:          2026-05-19
closed:          2026-05-19
artifacts:       phases/1-study/01-drift-vectors.md

---

## Scorecard

Single-document study — `01-drift-vectors.md` (13 KB). Enumerated 7 drift vectors (D-1..D-7), mapped Copilot CLI's 3/7 defense layers against Claude Code's 5/7, and proposed 5 candidate PRs spanning 4 strategies (A baseline-strengthening, B externalized re-anchor, C slot-level instructions, D self-check checklist).

## User-locked decisions

| # | Question | Decision |
|---|---|---|
| 1 | `axon-reanchor` script as user-invoked rescue OR automatic? | **Both.** Manual `axon-reanchor` command + automatic invocation when AXON detects its own drift signals. |
| 2 | Commit trailer policy | **`Co-authored-by: AXON powered by Copilot <223556219+Copilot@users.noreply.github.com>`** — relabel the entity, keep the GitHub user-id for PR attribution. |
| 3 | `.vscode/settings.json` in repo | **AXON asks user first** (per session, per repo), then script writes it automatically on consent. Two-tier: per-repo `.vscode/settings.json` (opt-in by user) + dev's user-level config left alone. |
| 4 | Measurement harness (PR-CA-105) | **Replaced with PR-CA-105': lightweight drift-event logger.** 30-LOC `tools/axon-drift-log.py` + `my-axon/log/drift-events.jsonl`. Promote to full corpus harness only after ≥10 entries. |

## Outcome

Phase-2 PR queue locked at **5 PRs** (4 small + 1 small-medium). See `phases/2-design/_meta.md`.

## Lessons

1. **Drift is structural, not behavioural.** The asymmetry between Claude Code (5/7 layers) and Copilot CLI (3/7) is a vendor surface gap, not a model quality gap. Phase-2 work targets the gap, not the model.
2. **Self-rescue is a smell.** Needing to invoke `axon-reanchor` means the baseline failed. We ship the rescue anyway because some failure modes (D-6 context compression) have no native fix on Copilot — but the rescue rate is itself a metric we'll watch.
3. **Cheap observability first, harness later.** Skipping the corpus-paste harness for an append-only drift event log keeps friction near zero. If the data accumulates, build the harness; if it doesn't, we have evidence the baseline-strengthening worked.
