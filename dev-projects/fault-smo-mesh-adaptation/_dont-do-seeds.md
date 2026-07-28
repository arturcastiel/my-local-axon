# Project-wide prohibition seeds

These entries seed each new phase's `_dont-do.md` on `code-dev phase start`.
Add project-wide invariants here (e.g. 'never commit generated files').

- Never edit the SUPERSEDED singular repos (`/mnt/c/projects/smo-faults`,
  `/mnt/c/projects/faults/fault-projection`) — this project targets the PLURAL
  `fault-projections` rewrite only. They share no history; a fix applied there does not
  reach this codebase.
- Never vendor or fork `cpg2unstructured` into this repo — it is a declared hard dependency
  installed from the sibling `../cpg2python` checkout.
- Never commit `out/` or other generated grid/deck artifacts.
