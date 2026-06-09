# 01-study — validating the deep-study's claims against THIS dev axon

The deep-study analyzed a PRODUCTION AXON instance (OPM/reservoir work). AXON's *core* (tools, programs,
telemetry, memory) is shared with this dev checkout, so most core claims transfer — but this dev axon just
went through the re-MEGA (!135–140), so some are already-fixed. Each claim below was checked live (2026-06-04).

## Verdicts (claim · studied instance · THIS dev axon · verdict)

### P0 — the learning loop (telemetry + memory) — the study's force-multiplier
- **Telemetry inert** — VALID HERE. `usage-log.jsonl` empty/absent; `_axon_lib.record_usage()` has **0
  callers**; **11 cron jobs, every `run_count: 0`** (scheduler never ticked); no turn-writer. (One divergence:
  `prompt-log-enabled` is `true` here vs absent there — but with no producer wired, it's still dead.)
  → `usage top/suggest`, `igap report`, `dispatch-stats`, `compile rank` all read empty files. The learning
  loop is open here too.
- **Memory tiers empty** — PARTIAL. The general tier EXISTS here with **13 entries** (richer than the studied
  instance's empty tiers — this is the host auto-memory the study praised), but the **program tier is ABSENT**
  (`my-axon/memory/programs/`), and `longterm/` has 9 files (vs 3). So "tiers empty" is partly stale; the
  program-tier + the agent-memory integration gap remain.
- **L: split (files vs diskcache)** — VALID HERE. `kv_store` (cache.db) holds `L:health-score`,
  `L:health-score-date`, `L:dev-mode`; the file backend separately holds `dev-mode.md` (+8 longterm files).
  **`L:dev-mode` lives in BOTH** → divergence risk (this is the postmortem's D2). `health-score` only in
  diskcache. Two writers, no mirror.

### P1 — the GAP list (programs the OTHER agent hand-rolled) — which are MISSING here?
- **G1 `code-dev ship`** (commit→push→PR-body→reply→CI) — MISSING. VALID GAP.
- **G2 `code-dev status-deck`** (md+DAG → PPTX) — MISSING. VALID GAP. (no program mentions deck/pptx)
- **G3 `code-dev-pr-github` harden** (REST-PATCH + label-scrub) — program EXISTS. PARTIAL (audit it for the
  REST path + auto-scrub; the study said `gh pr edit` was broken on OPM and they fell back to `gh api PATCH`).
- **G4 `code-dev amend-push` / `rebase-onto-upstream`** — MISSING. VALID GAP (24 hand force-pushes there).
- **G5 `code-dev import-principles` / `dont-do import`** — MISSING. VALID GAP.
- **G6 `reviewer-track` populate-from-gh** — program EXISTS but does NOT read `gh` review comments (no
  `gh … review/comments` in any reviewer program). VALID GAP (populate).
- **G7 `code-dev knowledge-manual`** — MISSING. VALID GAP.
- **G8 DAG auto-cascade on PR-state change** — no program cascades `dag set-status` on PR mutation. VALID GAP.

### P2 — cleanup
- **semantic-search stale in compiled mirrors** — VALID HERE. The deprecated tool is still called by **3
  compiled mirrors**: `compiled/code-dev-init.cmp.md`, `compiled/code-dev-plan.cmp.md`, `compiled/meta.cmp.md`
  (the tool does not exist). → regenerate/retire those mirrors. (Same class as the 3 stale `.cmp.md` I deleted
  in PR-2F; these are 3 MORE.)
- **rtk OPTIONAL-but-required** — VALID HERE. `rtk` is OPTIONAL but hard-referenced by `gain.md` + `discover.md`
  → both fail if it's absent. → promote ACTIVE or guard the callers.
- **`list-programs` dangling in help.md** — VALID HERE (4 refs; should be `find-program`, which exists).
- **counts** — DIVERGED: 161 programs / 151 tools / **131 ACTIVE · 20 OPTIONAL** here (study: 139A/12O — the
  re-MEGA's PR-2E moved 8 entry tools → OPTIONAL). Orphan/STUB/compiled-hub specifics must be re-counted here
  during plan (the study's exact lists are for the other instance).

### Already-FIXED in this dev axon (do NOT redo — the study is stale on these)
- **`new-chat` / `plan-new` dangling (mode-router)** — FIXED in PR-R5 (mode-router fails gracefully; 0 EXEC refs).
- **kv-store silent no-op on positional** — the postmortem's D4 found this APPEARS FIXED (kv_store errors on
  missing --key/--value); re-confirm.
- **compile pipeline / stale `.cmp.md`** — PR-2F made compile honest + deleted 3 stale mirrors (different 3
  from the semantic-search set above).
- **`L:cognition-frame` never set at boot** — the R9 gate no longer depends on it (PR-R3); persisting it at
  boot is still open (postmortem D3).

## Scope for THIS project (valid-here gaps, prioritized per the study)
- **P0 (force-multiplier):** (1) wire usage-recording on every program/tool route (call the unused
  `record_usage` / a PreToolUse-or-dispatch hook); (2) auto-emit `igap record` on low-confidence / fallback-exec
  / find-program / absent-rule; (3) a turn-writer (Stop-hook) + actually tick the cron; (4) unify the L: backend
  (mirror diskcache↔files) + persist `L:cognition-frame` at boot + (re)confirm kv-store fails loud on positional;
  (5) create + populate the program memory tier.
- **P1 (build the hand-rolled programs):** G1 ship · G2 status-deck · G4 amend-push/rebase · G5
  import-principles · G7 knowledge-manual (new); G3 pr-github harden · G6 reviewer-track populate · G8
  dag-cascade (extend existing). Each needs tests (Core Rule 13).
- **P2 (cleanup):** retire/regen the 3 semantic-search compiled mirrors; rtk OPTIONAL→ACTIVE or guard
  gain/discover; `list-programs`→`find-program` in help.md.

## Sufficiency / next
Study is sufficient to plan. Recommended order mirrors the deep-study: **P0 first** (telemetry+memory closes
the learning loop so future gaps self-detect), then P1 (the high-frequency ship/review-loop programs — G1/G3/G6
pay off most per §4 usage), then P2 cleanup. P1's G1–G8 are real *product* additions (new agent capabilities) —
worth confirming the slate + priority with the owner before building. → propose 02-prs.md plan on go.
