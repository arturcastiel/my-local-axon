# PR List — Stale Pointer Integrity
Updated: 2026-07-09  ·  Total PRs: 5

## PR-001 — Add pointer-coherence sweep to self-care
- **Status:** merged (928b54d, pushed to origin/main; gate 38/38 green)
- **Complexity:** M
- **Scope:** tools/self_care.py (new `pointers` area + check functions) · tests/test_self_care_pointers.py (fixture workspace per incoherence class)
- **Depends on:** none
- **Why:** The detector — everything else surfaces or acts on its verdicts.
- **Spec:** 03-prs/PR-001.md ✓

## PR-002 — Surface pointer lint at menu + guard the resume offer
- **Status:** implemented
- **Complexity:** M
- **Scope:** tools/axon_state.py (menu-snapshot `pointers` field) · workspace/programs/menu.md (OS STATE line + resumable-line guard) · tests
- **Depends on:** PR-001
- **Why:** Kills the false-fire class (2026-07-09 interrupt gate) at the render seam.
- **Spec:** 03-prs/PR-002.md ✓

## PR-003 — Loud completion: `code-dev complete` + handoff escalation
- **Status:** implemented
- **Complexity:** M
- **Scope:** workspace/programs/code-dev.md (new `complete` route) · 5 best-effort call sites in code-dev-study.md / code-dev-plan.md / code-dev-pr-create.md / code-dev-journal-log.md / code-dev-safety-audit.md · tests
- **Depends on:** none
- **Why:** Makes "complete" a gated claim, not freeform prose.
- **Spec:** 03-prs/PR-003.md ✓

## PR-004 — conftest.py test-run stamp
- **Status:** implemented
- **Complexity:** S
- **Scope:** conftest.py (new, repo root, pytest_sessionfinish → last-test-run.json) · tools/test_runner.py (de-dupe stamp path) · tests
- **Depends on:** none
- **Why:** The 5296/0/15 class of invisible test runs becomes impossible.
- **Spec:** 03-prs/PR-004.md ✓

## PR-005 — Repair stale records + docs/changelog
- **Status:** implemented (estate repaired: 20 findings -> 1 self-resolving)
- **Complexity:** S
- **Scope:** my-axon/dev-projects/axon-obsidian/_phases.json (pr: done --force recorded · log: done · audit: stays pending honestly) · CHANGELOG.md · docs
- **Depends on:** PR-001
- **Why:** Zero lint findings on the existing estate; uses PR-001 as the verifier.
- **Spec:** 03-prs/PR-005.md ✓
