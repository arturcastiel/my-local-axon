# Masterplan — AXON HR Gap Findings

## Phase graph (directed)

- **study** → plan → pr → log → audit

## Scope

Close 8 ranked architecture gaps surfaced by hr-team advisory council (2026-06-19).

## PR Plan (v3 — council + source verified 2026-06-19)

> Corrections from v1: G5 symlink discovery (was MEDIUM → LOW), G2 hooks already installed
> (DO NOT re-run enable-enforcement.sh), shell-log + source-log removed from scope (structural),
> KERNEL-SLIM turn-logging confirmed core → PR-07 doc-only under dev-mode.

| PR    | Title                                            | Gap(s) | Python cost | Owner confirm? |
|-------|--------------------------------------------------|--------|-------------|----------------|
| PR-01 | drift `--no-program` mode + boot auto-init       | 1      | LOW (~20 ln)| No             |
| PR-02 | MYAXON.md path hygiene (symlink-safe)            | 5      | ZERO        | No             |
| PR-03 | health-score "smoke" qualifier (4-line edit)     | 6      | ZERO        | No             |
| PR-04 | igap daily log wiring (grep sites pre-flight)    | 3a     | LOW         | No             |
| PR-05 | phase-ledger program template hook               | 3b     | LOW         | No             |
| PR-06 | coverage cron + fix incorrect doc reference      | 4      | ZERO        | No             |
| PR-07 | orchestrator per-turn tick doc (KERNEL-SLIM gate)| 7      | ZERO (doc)  | YES (if code)  |
| PR-08 | self-care cron add (one CLI call)                | 8      | ZERO        | No             |
| PR-09 | enforcement L: flags (terminal-outputs first)    | 2      | ZERO        | YES — per flag |

**CRITICAL CONSTRAINTS:**
- PR-09: DO NOT re-run `scripts/enable-enforcement.sh --apply` — hooks installed, next_turn_gate.py would be REMOVED
- PR-07: KERNEL-SLIM.md lines 107-138 are core — any code change here needs owner explicit confirm
- PR-09 per flag: test in isolated workspace → document rollback one-liner → owner initiates

**Pre-flight items (before writing PR specs):**
- PR-04: `grep -rn "CONFIDENCE\|absent-instruction\|low-confidence" workspace/programs/ --include="*.md"` → find igap event call sites
- PR-09: test each L: flag in `--workspace /tmp/test-ws` before activating in production L:

## Suggested sequencing (5-week)

Week 1: PR-01 (drift auto-init — unblocks auto-improve + drift gate) · PR-02 (MYAXON hygiene)
Week 2: PR-03 (health smoke — 5 min) · PR-04 (igap daily wiring) · PR-05 (phase-ledger template)
Week 3: PR-06 (coverage cron) · PR-07 (doc-only; owner confirm if adding KERNEL-SLIM code)
Week 4: PR-08 (self-care cron — 5 min)
Week 5: PR-09 (enforcement flags — owner-confirm, one flag at a time)
