# Project-wide prohibition seeds

These entries seed each new phase's `_dont-do.md` on `code-dev phase start`.
Add project-wide invariants here (e.g. 'never commit generated files').

# Seed prohibitions (vectorization project):
# match: for i=1:.*  reason: replace scalar for-loops in hot paths with vectorised ops (MATLAB)
# match: parfor  reason: prefer vectorisation over parallel loops until profiling justifies it
