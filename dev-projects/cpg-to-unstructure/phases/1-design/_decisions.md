# Decisions (ADRs) — 1-design

## D-04 — Package + distribution name: `cpg2unstructured`  (2026-05-21)

**Context.** PR-1 spec proposed `cpg2unstructure` as the import package name
and PyPI distribution name. User confirmed final spelling with trailing `d`.

**Decision.** All Python identifiers, file paths, and config refs use
`cpg2unstructured` (one word, lowercase, trailing `d`).

**Consequences.**
- `pyproject.toml::project.name`           = `"cpg2unstructured"`
- `[tool.setuptools.packages.find].include` = `["cpg2unstructured*"]`
- Module folder                             = `cpg2unstructured/`
- All test imports                          = `import cpg2unstructured`
- README + LICENSE references               = `cpg2unstructured`
- AXON project slug stays `cpg-to-unstructure` (already created — internal
  bookkeeping only; not exposed in code).

**Cascade.** Applied to PR-1 spec in this commit. PR-2..PR-13 specs and
`02-prs.md` reference the old name; they will be updated in-line when each
spec is authored. The 02-prs.md plan file gets a top-of-file rename note.

## D-05 — Author identity in packaging metadata  (2026-05-21)

**Decision.** Use `Dr. Artur Castiel Reis de Souza` (full form) in:
- `pyproject.toml::project.authors`
- `LICENSE` copyright line
- README author attribution (when added in PR-13)

## D-06 — Distribution scope: private use first  (2026-05-21)

**Decision.** PyPI publication is **not** a v1 target. Repo is private.
PR-1 acceptance keeps `pip install -e .[dev]` (editable install) and
`python -m build` (sdist + wheel succeed locally) but drops any PyPI-publish
acceptance. README install instructions point to local editable install,
not `pip install cpg2unstructured` from PyPI. Public release decision
deferred until end of Wave 6 (PR-13).

## D-07 — PR-2 wave-spec arithmetic correction  (2026-05-21)

**Decision.** The Wave-1 PR-2 entry in `02-prs.md` originally claimed
"36 faces (8 inner + 28 boundary)" and "each inner cell has 6
face-neighbours" for a 2×2×2 grid. Both numbers are wrong:

- For 2×2×2: per-axis inner faces = (N−1)·N·N = 1·2·2 = 4; three axes →
  **12 inner faces**, **24 boundary faces**. Total 36 unchanged.
- A 2×2×2 grid has **no** strictly-interior cell — every cell is a
  corner cell, touching 3 inner faces → **3 face-neighbours each**.
  The "interior cell with 6 neighbours" property first applies at 3×3×3
  (one strictly-interior cell).

**Action.** `02-prs.md` PR-2 entry edited to use the corrected counts,
with a parenthetical note that the 6-neighbour property is exercised
in PR-7's general-N case. PR-2 spec (`03-prs/pr-02.md`) uses the
corrected invariants in its acceptance + tests from the start.
