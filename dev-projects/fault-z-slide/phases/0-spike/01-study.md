# Study — 0-spike

Spike: `fault-projections` branch `spike/z-slide` (NOT FOR MERGE, uncommitted),
`spikes/z_slide_spike.py`, run 2026-10-26 with `cpg2python/.venv` → **SPIKE PASSED**.

## Setup
6×4×3 cartesian deck, DX=100 m, 10 m layers; X-fault on pillar line i=3 across all J
(closed block: fault + model edge). Rigid +15 m ZCORN shift of the east block (1.5 layers).
Scenario A vertical fault pillars; scenario B fault pillars tilted 40 m over 60 m.

## Results
| Check | A vertical | B tilted |
|-------|-----------|----------|
| COORD unchanged | PASS | PASS |
| FAULTS unchanged | PASS | PASS |
| West ZCORN unchanged / east = +15 m | PASS | PASS |
| Layer thickness preserved | PASS | PASS |
| Read-back `find_i_faces` juxtaposition = analytic (k_w,k_e) {(1,0),(2,0),(2,1)} ×4 stacks = 12 | PASS | PASS |
| `build_topology` (D1 path) | (0,0),(1,1),(2,2) — **WRONG** | same — **WRONG** |
| Fault-pillar corner motion | Δz=15, Δx=0 (throw) | Δz=15, Δx=10, \|slip\|=18.03 m (**dip-slip**) |

## Findings → design
1. **ADR-002 confirmed.** ZCORN-only slide works; on tilted pillars it is true dip-slip with no
   extra machinery (Δx = Δz·tilt/height, exactly as predicted).
2. **D1 empirically confirmed as a blocker.** `build_topology` pairs same-k cells across the
   fault and ignores the throw; `find_i_faces` gets it right. 1-prereqs P0.1 stays mandatory.
3. **NEW gap P0.3 — reader.** `read_grdecl` skips unknown keywords with a single `_read_block`;
   multi-record keywords (FAULTS, MULTFLT, EQUALS, …) leave stray tokens →
   `GrdeclSyntaxError: unexpected token outside keyword: "'F1'"`. Workaround in spike: FAULTS in a
   sibling file. Fix: skip multi-record keywords to their terminating empty `/`.
4. **Corner addressing is trivial for the rigid case**: column mask →
   `np.repeat(np.repeat(mask, 2, 0), 2, 1)` over `(2NX, 2NY)` slots, applied to all k-slots.
   P1's `zcorn_ops` should expose `zcorn_3d`/`zcorn_flat` (public inverse of `cpg._zcorn_3d`,
   which the spike re-implemented) + column/corner-slot masks.
5. **Closed-block test = flood fill with fault faces cut** (BFS over the column graph); seed east
   never reaching west ⇒ closed. Directly reusable for P3 `auto` mode.
6. **Juxtaposition report (P5)** can be computed from `find_i_faces`/`find_j_faces` neighbour
   pairs decoded with Fortran-order cell ids — no new geometry needed.
7. `CornerPointGrid` is frozen; rebuilding it by hand drops `props`/`unrecognized` unless copied —
   P1 needs a `with_zcorn(grid, zcorn)` helper mirroring `apply_displacement`.

## Not covered (by design)
Open block / fault tips (smooth Laplacian mode), along-strike profiles, hanging-wall auto
detection, validity backoff, j-faults, Norne.
