# Masterplan — CPG to Unstructure Grid Python Generator

## Phase graph (directed)

- **1-design** ✓ shipped as v0.1.0 (2026-05-22) — matching-Z CPG to
  lean numpy. 13 PRs across 6 waves.
   → **2-faults** (active, 2026-05-22) — port Tier B of processGRDECL:
     non-matching-Z fault geometry, findConnections, face
     intersection. Closes the gap to "any CPG grid → unstructured".

## Out-of-scope (will NOT become phases — see refined goal)

- ~~First-class PORO/PERM/NTG/SATNUM API + transmissibility~~ —
  **CANCELLED** 2026-05-22. cpg2python's goal is CPG-topology only,
  not a reservoir-simulation library. `attach_props` (PR-12) is
  already enough for "properties live on cells".
- `.EGRID` binary format
- MAPAXES / coordinate transforms
- Visualization (handled by repo-local `viz/` sidecar, not as a
  release feature)
- PyPI publish (revisit at end of 2-faults if appropriate)

## Confirmed in scope under 2-faults (user decision 2026-05-24)

- **PINCH NNCs** — explicit non-neighbour connections from pinched-out
  cells. IN scope (Wave 6). Study how MRST handles them in Tier B's
  `findConnections`, then emit cross-layer NNCs.
- **Disconnected-grid splitting** — split a deck into independent
  connected components. IN scope (Wave 7).

Both moved from "possibly" to confirmed on 2026-05-24; v0.2.0 release
held (Wave 8) until both land — one bigger v0.2.0 instead of shipping
faults alone first.

Phases are added by: code-dev phase new
