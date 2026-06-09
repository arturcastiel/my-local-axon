# PR-F4 — Gate-rule soundness: canonical my-axon, status-aware coverage, phase reconcile

- **Status:** spec
- **Phase:** 2-followups
- **Complexity:** M
- **Depends on:** none (independent of F1–F3; the gate rule stays BLOCK throughout — this hardens it)
- **Why:** Harden `R_CODE_CHANGE_REQUIRES_PR_PHASE` — the one rule that is BLOCK and load-bearing — against
  the audit's two false-NEGATIVES (which silently DISABLE a gate sold as un-bypassable) and one
  false-POSITIVE (which bricks legitimate work):
  - **F4 (false-NEG):** `_project_dir` hardcodes `repo_root/my-axon`, ignoring `W:myaxon-path`. On a fresh
    worktree/clone where my-axon isn't symlinked but the pointer IS set, the project goes unresolved → the
    rule returns silently → the gate stops enforcing exactly when an autonomous run is in a relocated env.
  - **F5 (false-NEG):** "covering" = ANY `PR-*.md` filename, regardless of `Status`. A merged/closed/stale
    spec counts forever, so once a phase has ever produced one spec, off-workflow code slips through.
  - **F6 (false-POS):** `_active_phase` lets `_phases.json` (which WINS) disagree with `_meta.phase`, then
    checks the wrong phase's `03-prs/` → BLOCKs legitimate work.

## Mechanism (one file: the gate rule; the reanchor inherits the fixes)
`autonomy_reanchor.py` already resolves my-axon via the canonical `_resolve_myaxon` AND reuses the gate
rule's `_active_phase` + `_has_open_pr_spec`, so fixing the helpers fixes the proactive boundary check too —
no reanchor edit needed.

- **F4 — `_myaxon_root(repo_root)`:** honor `W:myaxon-path` (bare or `value:` form, read from
  `workspace/memory/working/myaxon-path.md`), else fall back to the repo sibling `repo_root/my-axon`.
  `_project_dir` resolves under it. (Deliberately NOT chasing `$MYAXON_ROOT` — the working pointer is the
  canonical relocation signal; the sibling is the safe default. Keeps the existing fallback so current
  fixtures/behaviour are preserved.)
- **F5 — status-aware coverage:** `_spec_is_open(path)` reads the `Status:` line; a spec is OPEN unless its
  status is terminal (merged/done/closed/abandoned/cancelled). A spec with NO parseable status → treated as
  OPEN (fail toward on-workflow — never block on a missing status line). `_has_open_pr_spec` counts only
  open specs. (File-level coverage — changed code ⊆ a spec's file-list — stays a documented future
  refinement: making it BLOCK risks false-positives on incomplete scope lists.)
- **F6 — `_candidate_phases(project_dir)`:** the UNION of v4 `_meta.phase` (preferred, listed first) and
  `_phases.json` active phases. `check()` is on-workflow if ANY candidate phase has an open spec → a
  `_meta`/json disagreement never false-blocks. `_active_phase` becomes `next(iter(_candidate_phases), None)`
  (kept for `autonomy_reanchor`; now `_meta`-preferred).

## Out of scope (documented)
- **F10** (autonomy_reanchor import-context fragility): held-refactor F21 territory (import-conversion was
  deliberately not done) AND latent (no current caller hits the broken `tools.autonomy_reanchor` path —
  only script-mode dispatch + tests call it). Deferred, not fixed, to avoid re-opening a held decision.
- **F11** (empty `03-prs/` → BLOCK): by design — you must `code-dev pr` before editing code; the violation
  message already points there. Status-aware coverage doesn't change this (no spec = not covered).

## Acceptance criteria
1. `_myaxon_root` honors `W:myaxon-path`; with it set to a relocated my-axon the project resolves (F4). With
   it absent, falls back to `repo_root/my-axon` (existing fixtures unchanged).
2. A phase whose only spec has `Status: merged` → NOT covered → the rule flags a fresh code change (F5). A
   spec with `Status: spec` (or no status) → covered.
3. `_phases.json` active=`A` while `_meta.phase`=`B` with the open spec under `B` → on-workflow, not blocked
   (F6).
4. All existing tests still pass (no-status PR-001 fixture still reads as open; the freelance reproduction
   still BLOCKs; `_phases.json`-only layout still works).
5. `crucible gate` passed:true on this PR's own on-workflow changeset (the new status-aware rule sees
   PR-F4.md as open).

## Test plan
Extend `tests/test_rules/test_r_code_change_requires_pr_phase.py`: my-axon via `W:myaxon-path` (relocated);
a merged-status spec does NOT cover (F5); a `_phases.json`-vs-`_meta` disagreement does NOT block (F6).
Keep all existing cases green. Full suite + gate. No dev-mode (tools/rules + tests only).
