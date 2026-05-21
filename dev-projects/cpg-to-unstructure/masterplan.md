# Masterplan — CPG to Unstructure Grid Python Generator

## Phase graph (directed)

- **1-design** — port matching-Z CPG to lean numpy; v1 (13 PRs, 6 waves)
   → **2-faults** (future) — port Tier B of processGRDECL: non-matching-Z fault geometry, intersection, findConnections
   → **2-properties** (future) — first-class PORO/PERM/NTG/SATNUM API + transmissibility helpers

## Out-of-scope for v1 (will become future phases)

- Non-matching-Z fault geometry
- `.EGRID` binary format
- PINCH NNCs (explicit non-neighbour connections)
- Disconnected-grid splitting
- Visualization

Phases are added by: code-dev phase new
