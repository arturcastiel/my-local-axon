# Implementation Log — Terminal-Transition Completeness Gate

## SESSION START — 2026-06-18T12:42:19Z
project:        axon-completeness-gate
phase:          study
workflow-step:  build
branch:         main

## Entries

### 2026-06-18 · study · seeded from axon-hr post-mortem
- Origin: axon-hr plan phase marked done with 03-prs/DAG.json never emitted; no gate fired.
- Root cause: cooperative state machine — terminal transitions guarded by pre-conditions
  (deps/order) not post-conditions (declared effects). Confirmed in tools/phase_model.py done()
  (deps-only) and tools/workflow_run.py advance() (order + sub-workflow anti-skip, but leaf-effect blind;
  workflow nodes declare no outputs).
- Partial fix already in tree: tools/phase_model.py done() output-completeness guard + tests. Drift risk:
  hardcoded REQUIRED_OUTPUTS decoupled from program `# outputs:`. This project generalizes it.

## SESSION CHECKPOINT — 2026-06-18 (owner: checkpoint after Wave A+B)
MERGED TO MAIN (each green + adversarially tested):
  a6ec042  Wave A — phase-output completeness gate (the opening post-mortem bug)
  f055cae  PR-07 — R9 Bash kernel-write hole (CRIT, was live-exploited via _pwned.cmp.md)
  4b0fb8f  PR-08/09 — compile_write traversal + enforce.py cwd→AXON_ROOT classification
STATUS: study ✓ · plan ✓ · pr (in progress) — Waves A+B done; C/D/E/F + PR-10 remain.
DEFERRED: PR-10 (_axon_io mandatory write primitive — 165-tool refactor, own session).
REMAINING (planned/specced/DAG'd): Wave C enforcement teeth (PR-11 crucible carriage,
  PR-12 identity-independent gate, PR-13 Stop-hook teeth — a DESIGN wave, do fresh);
  Wave D drift wiring (PR-14/15); Wave E firing (PR-16/17/18); Wave F resume (PR-19).
RESUME: code-dev load axon-completeness-gate → code-dev pr → implement PR-11 onward.
  Audit backlog: phases/study/research/axon-arch-audit.md (18 findings).

## SESSION RESUME — 2026-06-18T17:14:03.867150Z
project:         axon-completeness-gate
phase:           pr
workflow-step:   build
branch:          main  (git: main  ✓)
shadow:          fresh:0 stale:0 branch-stale:0
reviewer:        no PR in review
prohibitions:    5 active (0 promoted)
ground-truth:    landed PR-01,02,03,04,07,08,09 · NEXT(critical-path)=PR-05 R_TERMINAL_OUTPUTS
artifact-drift:  02-prs.md tags stale (04/07/08/09 mislabeled TODO); 04-log hint "PR-11 onward" wrong — PR-11 deps PR-05 (pending)


### 2026-06-18T17:41:34.709727Z · pr · PR-05 LANDED — R_TERMINAL_OUTPUTS
- commit e07154c on main (4b0fb8f..e07154c, pushed origin/main).
- RUNTIME/BLOCK/silent-until-flag rule (L:terminal-outputs-required default-off), modeled on
  R_STATE_SURFACED. On a program :done token, resolves declared # emits via the emits SSOT
  (tools/emits.py) and BLOCKs if a declared artifact is absent on disk. Fail-open on
  no-emits/no-project-dir. Complements phase_model.done() L2 (program-token :done class).
- Files: tools/rules/r_terminal_outputs.py (new), tests/test_rules/test_r_terminal_outputs.py
  (new, 11 cases), registry.py + manifest.py + verify.py (load_state: +terminal_outputs_required,
  +code_dev_project_dir). No KERNEL-SLIM edit.
- Gate: crucible GREEN (32 controls, 0 blocking; WARN freshness+residue-lint are PRE-EXISTING,
  not PR-05). Targeted pytest 17 passed (11 rule + 6 parity).
- Trackers reconciled this session: 02-prs.md tags + DAG.json (8 complete/11 pending).
- UNBLOCKS PR-11 (crucible carriage of verify-only BLOCK rules) — the next critical-path node.
  Wave C (PR-11/12/13) is a DESIGN wave; do fresh.
- Follow-up (non-blocking): code_map freshness drift now includes r_terminal_outputs.py —
  fold into the next "chore: regenerate maintenance artifacts" batch (do NOT entangle with
  the pre-existing AXON-DOCS/REGISTRY drift already in the working tree).

### 2026-06-18 · pr · PR-11 LANDED — crucible carriage of verify-only BLOCK rules
- commit 592db96 on main (e07154c..592db96, pushed origin/main).
- Adds verify.py `merge` subcommand (cmd_merge) that carries R_TERMINAL_OUTPUTS,
  R_TOKEN_BUDGET, R_DRIFT_GATE over the live workspace tree at merge time. Uses a
  MERGE_SENTINEL (non-empty ASCII string) to clear N/A presence guards; explicit
  carry-list (not run_runtime) is the firewall ensuring no content-driven rule fires.
  Fail-closed: any exception → exit 1. BLOCK control registered in crucible.json.
- Design crux: merge has no agent response → naive ctx would silently no-op all three
  rules (text is None). Sentinel + explicit carry-list resolves both the N/A-guard
  problem and the content-rule false-positive risk.
- Files: tools/verify.py (+cmd_merge, +merge subparser), tools/crucible.json
  (verify-carriage control), tests/test_crucible_verify_carriage.py (new, 9 cases —
  incl. sentinel firewall assert + fail-closed + carried-set invariant).
- Gate: crucible GREEN (33 controls, 0 blocking). Targeted pytest 9/9 passed (0.16s).
- UNBLOCKS PR-13 (Stop-hook honest scope / gate-on-next-turn). PR-12 (identity-
  independent gate) has no deps, ready independently.
- Open risk (noted in cmd_merge docstring): workspace/memory/working/ is gitignored;
  fresh clone/CI has no state → all three carried rules fail open. Closing that
  allow-all-on-clone gap is PR-12's domain.

## SESSION PAUSE — 2026-06-18 (Wave C study complete, awaiting design fork decision)
STATUS: pr · 9 complete / 10 pending · PAUSED at Wave C design debate.

LANDED THIS SESSION:
  592db96  PR-11 — crucible carriage of verify-only BLOCK rules (fail-closed merge runner)
  Trackers synced: 02-prs.md PR-11→[DONE 592db96] · DAG.json 9-complete/10-pending · 04-log PR-11 entry.

WAVE C STUDY COMPLETE — design forks open (owner decision required before implementation):
  PR-12 (finding #12, no deps): identity-independent response/dont-do gate
    Fork A — Full sentinel: `axon/.axon-governed` tracked file; both hooks' _axon_active()
              returns True when sentinel exists. Risk: response gate fires on plain Claude Code
              sessions ("As an AI" → false positive outside AXON persona).
    Fork B — Split sentinel (RECOMMENDED): sentinel + split predicate (_axon_persona_active
              for response gate / _axon_governed for dont-do). Response gate stays persona-scoped;
              dont-do gate becomes repo-governed. Two predicates, correct scope for each.
    Fork C — Fail-closed warn: log warning when cognition-frame absent in AXON repo. Allow-all
              still. Weakest option.

  PR-13 (finding #7, depends PR-11 ✓): Stop-hook honest scope / gate-on-next-turn
    Fork A — Gate-on-next-turn only: verify_stop writes response-gate-pending-block.md on BLOCK;
              reanchor_store reads + prints stdout warning (system-reminder injection); clears file.
    Fork B — Honest reclassify only: update KERNEL-SLIM line 87 + verify_stop docstring to
              explicitly scope "BLOCK-capable" to merge only (runtime is advisory). No behavioral change.
              NOTE: KERNEL-SLIM edit requires dev-mode + per-change confirm (axon/ kernel edit).
    Fork C — Both (RECOMMENDED): gate-on-next-turn injection + honest KERNEL-SLIM scoping.
              Mechanical improvement + architecture honesty. Requires the axon/ KERNEL-SLIM edit confirm.

NEXT STEPS (after owner picks forks):
  1. Implement PR-12 (both hooks + sentinel + tests/test_hook_identity_independent.py).
  2. Implement PR-13 (verify_stop + reanchor_store + KERNEL-SLIM edit if Fork C; tests/test_stop_hook_next_turn.py).
  3. Continue Wave D (PR-14/15) → Wave E (PR-16/17/18) → Wave F (PR-19).
RESUME: code-dev load axon-completeness-gate → code-dev pr → implement PR-12 onward.
