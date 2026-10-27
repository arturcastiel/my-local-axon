# Handoff briefing — fault-z-slide

Saved: 2026-10-26 (user: "save state now and we continue later")

## Where things stand

- Phase 1-prereqs. Spike passed. D1 and P0.3 are done in cpg2python; P0.2 (fieldbook CI) is done.
- The user asked for runnable examples of the Z slide, with figures, added to the fieldbook
  lessons. Lessons 19 and 20 are committed. **Lesson 21 is written and validated, but not
  committed.**
- Working style the user wants: act independently and commit locally without asking.
  **Never push.**

## Repo states at save time

| Repo | Branch | HEAD | Notes |
|---|---|---|---|
| cpg2python | `fix/grdecl-multirecord-keywords` | 2d41127 | Stacked on `fix/d1-fault-aware-topology` (1eef539). Not pushed. |
| fault-projections | `spike/z-slide` | 213e3af | Use main 0837f07 only temporarily, to verify the fieldbook at its pins. |
| cpg-fault-fieldbook | `docs/z-slide-examples` | 7ef6ba0 | Lessons 19–21 committed (21: 87a1a06 vertical, 7ef6ba0 dipping). Stacked on ac0ef09. Not pushed. |

## Uncommitted in the fieldbook (lesson 21, oblique fault)

- New: `examples/21_z_slide_oblique_fault.py` and `docs/assets/z-slide/oblique-fault.png`.
- Modified:
  - `docs/learn/z-slide.md`: new section "A fault oblique to the grid";
  - `README.md` and `docs/reference/coverage.md`: rows mention lesson 21;
  - `docs/reference/limits.md`: Z slide 19–21, plus a steep-trace `adapt_grid` bullet.
- Lesson 21 passes on both `spike/z-slide` and main 0837f07 (about 33 s).
- At save time, `doctor`, `fieldbook.docs --check` and the full pytest had been started in the
  background with fault-projections on main. Re-run them if their outcome is unknown.

## Resume steps

1. `cd /mnt/c/projects/library-development/fault-projections && git checkout main`, if it is
   not already there.
2. Verify the fieldbook at its pins (venv `.venv/bin/python`):
   - `-m fieldbook.cli doctor`
   - `-m fieldbook.docs --check` (expect 23 pages OK)
   - `-m pytest -p no:cacheprovider -q` (expect 37 passed: 36 + lesson 21; about 3.5 min)
3. `git checkout spike/z-slide` in fault-projections.
4. Commit the fieldbook locally on `docs/z-slide-examples`:
   - message: "docs: lesson 21, Z slide on an oblique (staircase) fault";
   - add the Copilot co-author trailer.
5. Append a log line with the fieldbook commit hash.
6. Then start P1, `zcorn_ops` in cpg2python, on a new branch stacked on
   `fix/grdecl-multirecord-keywords`.

## Lesson 21 key facts

- **Setup:** an 8×6×3 grid with vertical pillars. The trace runs from (300,0) to (600,600),
  26.6° off J.
- **FAULTS:** `fault_faces_for` gives a staircase of 9 faces (6 X, 3 Y).
- **Deck A (regular grid):** the fault is 900 m long in plan.
- **Deck B (`adapt_grid`):**
  - called with `boundary="pinned"`, `w0=0.05`, `polish="barrier"`;
  - `faces_invariant` is True and `faults_after` equals the staircase;
  - the fault is 710.6 m long, against 670.8 m for the trace;
  - fault pillars are within 16.5 m of the trace, against 44.7 m before.
- **The slide:** 7 m on the south-east block of 21 columns, ZCORN only.
- **Checks that pass:**
  - COORD and FAULTS unchanged;
  - the faces that open equal the FAULTS set (X and Y);
  - contact pairs are {k0|k0, k1|k0, k1|k1, k2|k1, k2|k2};
  - each contact area equals L × overlap, exactly;
  - exposed area is L × 14 (12,600 in A, 9,948 in B);
  - cell volumes are unchanged (vertical pillars).
- **Finding (fault-projections):** with traces about 30° or more off J that run rim to rim on
  this grid, the stitched path walks along the rim. The regenerated FAULTS then contain
  `(3,0,'Y')` (j=0 is a rim face) and `faces_invariant` is False. This happens on both main and
  the spike, and is documented in fieldbook limits.md. Candidate fault-projections issue.

## Figures (git-ignored, fault-projections/out/feature_demos/)

- 01–05: earlier Z-slide demos.
- 06: two sequential faults.
- 07: partial fault.
- 08: oblique fault — `08_oblique_fault.png`, `08_oblique_fault_3d.html`, and the decks plus
  `checks.txt` in `08_oblique_fault/`.
- Generators are in the Copilot session files: `tools/feature_demos/*.py`, including
  `oblique_fault_fig.py` (run with the cpg2python venv, `sys.path` += /tmp/pydeps for plotly).

## Waiting on the user

- **Push and PR approvals:**
  - cpg2python stacked branches go first; the fieldbook CI pin points at the unpushed 2d41127;
  - then fieldbook `docs/z-slide-examples`.
- **Set the `FAULT_PROJECTIONS_TOKEN` secret** for the fieldbook CI.
- **Volume-change policy for tilted fault pillars:** accept and report, or compensate.
- **Commit the my-axon changes?** The log, `_meta` and this handoff are uncommitted.
- **Figures:** keep them git-ignored, or move them into a repo.

## How to resume

1. `boot axon`
2. `code-dev load fault-z-slide`
3. `code-dev resume`, then follow "Resume steps" above.

## Update 2026-10-26 15:5x — lesson 21 done

Lesson 21 is committed and now dips 65.9° SE: the staircase pillars lean 40 m east by z = 80, and B is `adapt_grid` stage 1, which keeps the lean. Resume steps 1–5 above are done. **Next: P1 `zcorn_ops` in cpg2python.**
