# Project-wide prohibition seeds

These seed each new phase's `_dont-do.md` on `code-dev phase start`.
Add project-wide invariants here.

- Never fix a "bug" without confirming it reproduces against a test in `tests/`.
- Never edit `axon/` without first writing the PR spec under `phases/{phase}/03-prs/`.
- Never delete a program, tool, or workspace file during the audit phase — flag it
  in `_flaws.md` or `_demands.md` and decide in phase 2-prioritise.
- Never narrate a tool call (Core Rule 6) — every `python3 axon.py …` must actually run.
- Never bypass the write gate by routing through a non-`axon/` path that re-imports
  the target (e.g. symlink, shell expansion).
- Never let the audit balloon: time-box each of the 9 dimensions; carry leftovers
  to a sub-project rather than expand the current phase.
- Never commit generated files (`generated/`, coverage.xml, __pycache__).
