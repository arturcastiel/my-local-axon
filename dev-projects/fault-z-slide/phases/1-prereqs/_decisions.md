# Decisions (ADRs) — 1-prereqs

- **ADR-101 D1 approach.** Raw same-k i/j faces in faulted pillar stacks are dropped and
  replaced by fault faces from one shared helper `_fault_stack_faces` (MRST-style virtual
  cell above/below each side, pad = max(1, z-range)). Real–virtual overlaps = exposed pieces
  → boundary faces (other side −1).
- **ADR-102 cell_faces shape.** User chose padded `(Ncells, 6+E)`: 6 slots
  `[i-,i+,j-,j+,k-,k+]`, extras in columns 6+, −1 padding. Unfaulted grids keep `(N,6)`
  byte-identically. `split()` trims unused padding.
- **ADR-103 Release.** User chose minor bump → cpg2python v0.3.0.
- **ADR-104 Triangles.** 3-corner fault polygons (fault tips) stored as quads with last node
  repeated; 5+ corners / pillar-line crossings still raise `NonMatchingZError` (D2).
- **ADR-105 Commits.** User chose ONE commit for D1 + D4 + release docs.
- **ADR-106 P0.3 approach.** Table-driven keyword arity (as opm-common): known multi-record
  keywords skipped to their empty `/`; known data-less keywords (GRID, EDIT, ECHO, ENDBOX, …)
  consume nothing — the latter fixed silent swallowing of the next keyword. cpg2python only
  skips FAULTS (fault-projections' `from_faults` parses it). Branch stacked on D1 → ships in 0.3.0.
- **ADR-107 Fieldbook CI.** User chose a read-only fine-grained PAT as repo secret
  `FAULT_PROJECTIONS_TOKEN`. Applied via step-scoped `GIT_CONFIG_*` url.insteadOf rewrite (token
  never in pip args, direct_url.json or global git config). Missing secret → explicit error.
- **ADR-108 Example numbering.** Follow guide order: 01_read_grid, 02_egrid, 03…18 (+1 shift);
  single-pass regex rewrite of all references. Slide examples will be 19/20.
