# Implementation Log — AXON Bug-Free

## SESSION START — 2026-05-29

Project created as a workstream under `axon-improvements` (anti-proliferation guardrail).
Autonomy: grant ACTIVE on `artur.castiel-tno/axon`; AEGIS develop/pr-create=grant,
test-execution/merge=green-only, build=human; kernel/destructive = human-only.
Phase 1 study wave 1 launched (6 parallel auditors). Remediation PRs logged below as they merge.

## Entries

### PR-1 · BF-001 · MR !30 · ✓ merged (squash f51e23e) · 2026-05-29
`enforce.py` check-write `--axon` defaulted to the relative literal `"axon"` → cwd-only
bypass of the Core Rule 9 write gate. Fixed: absolute `AXON_DIR` default + `is_inside_axon`
default resolution. +1 hermetic regression test. FULL crucible gate green (20 controls, 0/0).
Loop: branch→commit f3188e6→gate→push→MR !30→squash-merge. Trailer: AXON.

### PR-2 · BF-002 · MR !31 · ✓ merged (squash 8a53b38) · 2026-05-29
`crucible.py cmd_gate` (the merge gate) passed vacuously on an empty/missing registry
(`verdict([])`→passed:true). Fixed: fail-closed (exit 1) when zero controls load. +1 test.
FULL crucible gate green (20/0/0). Note: merge needed 1 retry — GitLab returned 405 on the
freshly-created MR (async-mergeability race); retry after `mr view` succeeded.

### PR-3 · BF-003 + BF-013 · MR !32 · ✓ merged (squash de01642) · 2026-05-29
`r_coherence` had no brand/vendor patterns → "I am <brand>" self-identification passed the
identity gate. Added I-am-subject brand/vendor patterns (legit mentions + structured host
disclosure still pass) + the contraction refusal form. 7 tests incl. negatives. Gate 20/0/0.
Lesson: commit message had to be reworded — brand-name *examples* in the message tripped the
commit-msg brand-guard. Keep bug-free commit/MR text brand-free.

### PR-4 · BF-004 · MR !33 · ✓ merged (squash 7b0a212) · 2026-05-29
`r_new_needs_test` decided coverage by raw substring over the whole test corpus → new tools
with short stems (log/run/test/verify/enforce/…) passed untested (Core Rule 13 bypass). Now
requires a credible reference (test_<stem>, file/path, import, CLI dispatch); existing signals
preserved. +2 regression tests. Gate 20/0/0. Merge took 2 retries (405 race).

### PR-5 · BF-005 · MR !34 · ✓ merged (squash 9966031) · 2026-05-29
`doc_counts.count_programs` counted _-prefixed meta files docgen/R_NEW_NEEDS_TEST exclude
(187 vs 185 false drift). Mirrored docgen's filter. Also dropped `my-axon/*.md` from default
scan globs (private point-in-time handovers carry snapshot counts — false-positive class, same
as doc_anchors). Surfaced+fixed during local test (handover "187 programs" tripped the clean
check). +1 test. Gate 20/0/0. doc_counts is NOT a crucible control → no gate risk.

### PR-6 · BF-009 · MR !35 · ✓ merged (squash 79ad487) · 2026-05-29
Prereg fingerprint (`_PREREG_FILES`) omitted `proof_bl.py` (the BL analytical grader for bl:N
goals) though it claims to pin "the EXACT grader" → a registered run could be graded by a
quietly-changed BL grader. Added it. +1 test. Gate 20/0/0. First million-$ proof-integrity fix.

### PR-7 · BF-011 · MR !36 · ✓ merged (squash d0d4acf) · 2026-05-29
run.py resolved memory.py/log.py + the `--input` pre-seed via cwd-relative paths (the `--input`
join dropped the abs-workspace prefix → nonexistent path → silent no-op; STORE/LOG used relative
literals). Anchored all paths via `_axon_paths`, passed `--workspace` to the seed, narrowed the
bare `except`. NEW tests/test_run.py (2 cwd-independence regressions). Gate 20/0/0. 7/14 — halfway.

### PR-8..13 · 2026-05-29 · all ✓ merged, FULL gate green (20/0/0) each
- PR-8 BF-006 MR !37 (squash e30e508) — coherence_lint absolute --workspace/--axon defaults + _build_parser.
- PR-9 BF-007+008 MR !38 (squash 179b353) — scan_pre_push fail-closed on git error; redact catches
  fine-grained github_pat_ + gho_/ghu_/ghr_ tokens.
- PR-10 BF-019 MR !39 (squash 83018a7) — intent_queue tolerates a corrupt queue file + absolute workspace.
- PR-11 BF-014 MR !40 (squash 4449958) — verify load_state exposes workspace_root → R9 cwd-independent.
- PR-12 BF-015 MR !41 (squash 5074330) — dual_agent_eval pins sampling temperature (proof reproducibility).
- PR-13 BF-020 MR !42 (squash 3bb738b) — metric_integrity tripwire requires a real `def`, not a substring.

### SESSION PAUSE — 2026-05-29 06:07
13 PRs merged (MR !30–!42), 14 findings fixed, gate green every merge. Paused before the
risky-numeric (BF-010/016), methodology-prose (BF-017), gate-wiring (BF-018), and landmine
(BF-012) items — they need a fresh, focused pass (see 01-study.md "REMAINING — DEFERRED").
Human-only kernel items (BF-H1/H2/H3, BF-S1) handed to the owner.

### SESSION RESUME — 2026-05-29 (dev-mode pass)
- Owner enabled dev-mode → kernel-coherence items done.
- KERNEL PR · BF-H1+H2+H3 · merge 8fb5651 (squash 809b0d4) · ✓ HUMAN-merged by owner:
  G-02 now covers multi-turn UNTIL/LOOP(c) loops; interactive.md REPL gains the every-5-turns
  identity re-assert; BOOT step-count reconciled (3 phases / 5 steps). Gate green 20/0/0; commit
  carried the AXON trailer; owner ran push+MR+merge (kernel = human-merge per HARD RULE).
- dev-mode RE-LOCKED (false) after the edits; enforce confirms axon/ writes blocked again.
- NEW finding this pass: BF-021 — verify.load_state reads dev-mode.md as a whole string, so the
  `value: true` front-matter form parses as OFF (inconsistent with enforce; fail-closed). Fixing next.
