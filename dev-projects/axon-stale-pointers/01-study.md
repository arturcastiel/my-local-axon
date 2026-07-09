# Study — Stale Pointer Integrity
Updated: 2026-07-09  ·  Iterations: 1  ·  AXON: 8.5/10  ·  User: 9/10

## Goal
Find and fix stale pointers; make it impossible for a project's state pointers to go
stale. "Pointers" = the four state stores that describe where work stands:
W:active-phase · {project}/_phases.json · {project}/_meta.md (status/phase fields) ·
workspace/memory/longterm/last-test-run.json.

## Root-cause verdict (the owner's original question)
**Both workflow defect AND autonomous-discipline failure, meeting at one seam:**
every pointer writer is either optional or advisory at exactly the moment of
completion, and nothing ever audits cross-store coherence.

## Priorities
1. **pointer-lint** — one coherence check across all four stores: W:active-phase
   validity (program exists, phase token valid, not stale vs project state),
   phase_model.check() per active project, _meta "status: complete" vs manifest
   all-done, last-test-run.json freshness vs latest commit. Wired into self-care
   (new area, follows areas/attention pattern) + surfaced at boot so a stale
   pointer is caught next session, not weeks later.
2. **Loud completion** — a closeout path that refuses "status: complete" until the
   manifest agrees; best-effort `outputs-missing` escalates to human-handoff
   instead of LOG(ERROR).
3. **Repair current stale records** — axon-obsidian manifest (pr/log/audit) + any
   others pointer-lint finds on first run.

## Constraints
- reduce-surface: extend self_care.py / phase_model.py / code-dev exits — no new
  top-level tool unless justified; NO new state store (dont-do seed).
- tests-with-neurons: every change ships with tests (Core Rule 13).
- kernel-floor: if boot wiring touches axon/BOOT.md, that edit is per-change
  human-confirmed regardless of dev-mode.
- lossless-mandate · deterministic-spine · no-dense-rag · budget-human-wall.

## Tech Stack
Python 3 CLI tools (tools/*.py, argparse + JSON envelopes) · AXON-LANG markdown
programs (workspace/programs/*.md) · pytest suite · _phases.json manifest (schema v1).

## Key Concepts / Evidence (per-seam, shadow-indexed)
1. **W:active-phase** (tools/memory.py) — any caller sets any string; no validation.
   Incident: "code-dev-pr:1" persisted across sessions for a COMPLETE project and
   names a nonexistent program (code-dev-pr.md); boot resume-offer and the interrupt
   gate false-fired on it (2026-07-09). Kernel stamps are protocol-only.
2. **_phases.json** (tools/phase_model.py) — mechanically sound: done() gates on
   deps + declared outputs (OutputsMissing/DepsNotDone reason codes), check()
   detects _meta⇄manifest split-brain, stale_downstream() cascades. But PASSIVE:
   ladder programs call done() with --best-effort → refusal becomes a log line.
   Incident: axon-obsidian PR specs were batched into 02-prs.md; declared output
   03-prs/PR-*.md never existed; gate refused correctly; nothing reconciled; pr
   phase "pending" forever while 5 PRs shipped. check() has NO routine caller.
3. **_meta.md** — "phase: complete / status: complete" hand-written by the
   completing agent; "complete" is not a manifest id; the existing detector would
   have flagged it if anything ran it.
4. **last-test-run.json** (tools/test_runner.py, workflow_run) — stamps only via
   AXON's runner; the claimed 5296/0/15 suite ran through bare pytest → invisible.
   .pytest_cache showed 29 lastfailed (23:19 Jul 8, pre-commit) in non-obsidian
   areas; commits 23:43; untracked pytest activity 00:49 Jul 9.

## Open Questions
- Boot wiring point for pointer-lint: menu-snapshot field (workspace-side, no
  kernel edit) vs BOOT.md step (kernel-floor confirm needed)?
- Can bare-pytest runs stamp last-test-run.json via repo-root sitecustomize.py
  (already present), or is a documented test-cmd wrapper the cleaner path?
- Should the boot resume-offer run pointer-lint BEFORE offering resume (kills the
  false-fire class), and does that live in menu.md (workspace, safe) or BOOT.md?
- Who repairs axon-obsidian: done --force per phase (recorded) vs retro-fitting
  03-prs/PR-*.md artifacts from 02-prs.md content?

## Architecture Snapshot
(Populated in Phase 2 after codebase analysis)

## Sources
- file tools/phase_model.py (shadow written)
- file tools/memory.py (shadow written)
- file tools/self_care.py (shadow written)
- file workspace/programs/code-dev.md (shadow written)
- incident evidence: this morning's boot (stale code-dev-pr:1, gate false-fire),
  axon-obsidian project records, .pytest_cache timeline, memory/general/
  autonomous-loop-wired-resume-pointer.md (prior related seam)
