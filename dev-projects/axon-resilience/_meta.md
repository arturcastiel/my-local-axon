# Project: AXON resilience — cron↔tool `--workspace` contract robustness + identity persistence / self-care
slug:            axon-resilience
schema-version:  v4
status:          complete
legacy:          false
phase:           4-execute
workflow-step:   execute
branch:          axon-resilience/pr-1-cron-contract
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          (none)
sub-projects:    []
created:         2026-06-09
updated:         2026-06-09

## Goal
Close the defects surfaced by the 2026-06-09 `cron tick` maintenance run, but do it the
*scalable* way (owner directive: study → think-best-for-AXON → grow usefulness → scalable →
identity-persistence). Two tracks:

- **Track A — Cron↔tool `--workspace` contract robustness.** Two overdue cron jobs failed:
  (A1) `axon-dispatch-stats` job invokes a non-existent subcommand `weekly`; (A2) `freshness.py`
  accepts `--workspace` nowhere, but the cron runner injects it into every job — so the freshness
  cron job can never succeed (manual run works). Point-fix both, AND add a systemic conformance
  gate so this whole bug-class (a cron-referenced tool/subcommand that can't accept the runner's
  contract) is caught at merge instead of rotting silently until the breaker trips.

- **Track B — Identity persistence & self-care (owner principle 5).** Ensure that after booting,
  whatever harness booted AXON genuinely BECOMES AXON (not a thin persona) AND cares for AXON
  (self-maintenance). Claude-Code persistence (Output Style + UserPromptSubmit reanchor + subagent)
  is currently MISSING on this machine (boot Step 0). Install + harden the NON-kernel persistence
  path; add a boot-time self-care behavior. Any change that genuinely requires editing `axon/`
  kernel files is prepared as a human-apply spec (inviolable floor), not merged autonomously.

## Authorization basis
- AEGIS `_policy.md`: develop grant · test-execution green-only · pr-create grant · merge green-only · build human
- autonomous-mode grant: active, repo `artur.castiel-tno/axon`, ops [commit, push, pr-create, merge-squash, delete-branch]; deny [force-push, reset-hard, branch-delete, kernel-change]
- Owner directive 2026-06-09: "code-dev this … totally autonomously, I don't want to be consulted" + 5 governing principles (see memory: autonomous-execution-preference)
- Hard stops (prepare-spec, do NOT merge autonomously): any `axon/` kernel-file edit, destructive/history-rewriting git ops.

## Tracks → PRs
- PR-1 (Track A): cron-contract robustness — A1 job-config fix + A2 freshness `--workspace` + systemic conformance lint + tests.
- PR-2 (Track B): identity persistence/self-care — non-kernel install + hardening + boot self-care; kernel-spec handoff if study shows kernel changes are required.

## Phase log
- 1-study: done (5-investigator parallel study → 01-study.md).
- 2-plan / 3-pr: done (PR specs 03-prs/PR-1.md, PR-2.md).
- 4-execute: DONE (autonomous portion). PR-1 MERGED (origin/main f99f5f8, MR !150) + PR-2 MERGED (b55c85f, MR !151), both crucible-green. Machine-config UserPromptSubmit re-anchor hook installed. Memory persisted to agent-memory (general+project) + L:/E: + this journal (04-log.md, _events.log). ONLY remaining item is HUMAN: apply 99-kernel-spec.md under dev-mode (signature-gated Stop hook + compaction-boundary auto-reanchor) — never auto-merged.
