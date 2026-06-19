# Audit Report — AXON Bug-Free Hardening (completeness gate + arch audit)
Date:       2026-06-19
Project:    axon-completeness-gate
Codebase:   /home/arturcastiel/projects/new-axon/axon
PRs:        19 / 19 landed  ·  19 / 19 carry a test file
Findings:   18 / 18 dispositioned  (16 code-closed · 1 by-design · 1 transitive)
Method:     git ground-truth (commit ancestry of HEAD) + per-finding structural-fingerprint
            verification in landed source. NOT the stock log-block heuristic (which false-negatives
            here — 04-log is not in `pr: PR-NN` block form). See "Method & caveats" below.

## Verdict
**All 18 confirmed architecture findings from `phases/study/research/axon-arch-audit.md` are
closed in landed code.** Every dedicated PR's fix fingerprint was located in the actual source,
not merely inferred from "a PR exists". Two findings with no dedicated PR are dispositioned
explicitly (#16 by-design, #18 transitive).

Outstanding (not a finding): the **test suite has not been executed this session** — closure is
verified at the commit + code-structure level, not at a green-bar. Green-bar confirmation is the
one remaining step (human-gated test-exec, or AEGIS-gated autonomous run if crucible is green).

## Finding-closure matrix

| #  | sev  | finding (short)                                   | PR    | commit   | closure evidence in landed code | status |
|----|------|---------------------------------------------------|-------|----------|---------------------------------|--------|
| 1  | CRIT | PreToolUse matcher omits Bash (R9 hole)           | PR-07 | f055cae  | settings matcher = `Write\|Edit\|NotebookEdit\|MultiEdit\|Bash` | ✓ closed |
| 2  | HIGH | REQUIRED_OUTPUTS dup contradicts `# outputs:`     | PR-01 | a6ec042  | phase_model reads emits/manifest SSOT (45 refs) | ✓ closed |
| 3  | HIGH | compile_write.py path traversal into axon/        | PR-08 | 4b0fb8f  | `_axon_io` + `relative_to`/`resolve()` containment guard | ✓ closed |
| 4  | HIGH | _axon_io covers ~25/190 tools (raw open elsewhere)| PR-10 | ee00fc1  | `tools/axon_io_lint.py` raw-write gate + whitelist | ✓ closed |
| 5  | HIGH | verify-only BLOCK rules have no fail-closed runner | PR-11 | 592db96  | `verify.py merge` (MERGE_SENTINEL) + crucible verify-carriage control | ✓ closed |
| 6  | HIGH | getppid session-recovery liveness key             | PR-19 | fac6d90  | stable `run_id` token primary; getppid only pre-PR-19 fallback | ✓ closed |
| 7  | MED  | response gate fail-open (Stop hook exit 0)        | PR-13 | d69644e  | verify_stop persists `response-gate-pending.json`; `next_turn_gate.py` reads+injects+clears, wired w/o `\|\| true` (CAN block next turn) | ✓ closed |
| 8  | MED  | test pins stale hardcoded contract as truth       | PR-01/03 | a6ec042 | emits SSOT + drift-lock test (test_emits_drift); gate now reads `# outputs:` | ✓ closed |
| 9  | MED  | dispatch-index drift gate wired into nothing      | PR-14 | d69644e  | `dispatch_index` added to freshness checks (5 refs) | ✓ closed |
| 10 | MED  | DAG.json never reconciled vs 03-prs/PR-*.md       | PR-15 | d69644e  | dag_consistency PR-file cross-check (orphan/missing-node) | ✓ closed |
| 11 | MED  | enforce.py cwd-relative path classification       | PR-09 | 4b0fb8f  | relative targets anchored to AXON_ROOT (6 refs) | ✓ closed |
| 12 | LOW  | hooks gate on gitignored identity key (allow-all) | PR-12 | 87a02b3  | tracked `.axon-governed` sentinel; 4 hook/tool files reference it | ✓ closed |
| 13 | LOW  | dag_consistency enforced only at crucible merge   | PR-15 | d69644e  | dag_consistency added to freshness checks (3 refs) | ✓ closed |
| 14 | MED  | anticipator wired but never re-ticks per turn     | PR-16 | b5903c6  | reanchor_store runs `anticipate --footer`, refreshes orchestrator-last-tick | ✓ closed |
| 15 | MED  | turn-log/prompt-log `!BG` never fire              | PR-17 | b5903c6  | 2 hook files now drive turn/prompt-log (mechanical executor) | ✓ closed |
| 16 | LOW  | cron-auto=false → scheduled maintenance dormant   | —     | (by-design) | deliberate pref; boot-tick auto=true runs maintenance per-session; PR-14 folds dispatch-index into the same pipeline | ◐ by-design |
| 17 | MED  | event bus write-only: 24/26 EMITs unhandled       | PR-18 | b5903c6  | `tools/emit_listener_lint.py` emit-without-listener lint + triage | ✓ closed |
| 18 | INFO | hooks fire but are partial no-ops                 | —     | (transitive) | cross-ref #1/#3/#7/#14 — all four now act, not just log | ✓ closed |

Also landed (masterplan target #3 / ladder finding L4, not in the 1–18 list):
- **PR-06** (`c141d6f`) — workflow_run node `outputs:` schema + verify before `record_step(ok)`. Test: `tests/test_workflow_node_outputs.py`. Closes the "workflow nodes declare nothing to verify" gap.

## Method & caveats
- **Ground truth = git.** All 19 commits verified ancestors of HEAD `0dbf783`. Each finding's fix
  was confirmed by locating its structural fingerprint in the landed source (matchers, imports,
  containment asserts, new tools, hook wiring), not by trusting tracker tags.
- **Stock heuristic bypassed (and why):** `code-dev-safety-audit`'s default scoring keys on
  `pr: PR-NN` log-blocks + shadow file-mods. `04-log.md` records landings narratively, not in that
  block form, so the heuristic would have mislabeled landed PRs as "not-logged". Using it verbatim
  would have produced a false-red audit. Status here is git-grounded instead.
- **Spot-check depth:** fingerprint-level (1 high-signal grep per finding) + deep read on the two
  ambiguous ones (#6 residual getppid, #7 next-turn reader). Not a line-by-line re-review of all 19
  diffs. A full per-diff adversarial re-read is available on request (good fit for a fan-out).
- **Tests NOT executed this session** (Code-Development Rule: build/test-exec is human-gated; AEGIS
  autonomous test-exec requires an active grant + crucible-green). Every PR has a test file present;
  green-bar pass/fail is unconfirmed here.

## Recommended next steps
1. **Green-bar:** run the suite (`pytest` over the touched test files, or full) to convert
   "tests present" → "tests pass". Owner-run, or AEGIS if crucible is green.
2. **Working-tree triage:** uncommitted `axon/BOOT.md`, `tools/hr_team.py`, `tests/*`,
   `workspace/AXON-DOCS*`, episodic memory, `.claude/workflows/`, `_policy.md` — classify in/out of
   this project before commit.
3. **#16 disposition:** if "scheduled maintenance dormant" is acceptable as a pref, mark it
   accepted in the arch-audit doc so it doesn't resurface as an open finding.

## Audit Notes
Generated by AXON code-dev-safety-audit (git-grounded mode) on 2026-06-19.
Re-run any time: code-dev audit
