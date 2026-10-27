# Deviations from plan — 1-prereqs

- **D4 added (scope +).** `face_geometry` took the 2 longest node-pair distances as the
  diagonals → wrong area/normal on trapezoids / sheared quads / triangles. Pre-existing on
  main: tilted-pillar deck (spike B) 16 % volume error, pinchout wedges 71 %. Fixed: pick the
  pairing with max |d1×d2|. Needed for D1 closure checks; shipped in the same commit.
- **D5 recorded (limitation, not fixed).** `mesh3d.face_edges` needs hex-edge faces; raises
  `ValueError` on faulted grids now that topology is correct (it "worked" before only because
  topology was wrong). Documented in README / TUTORIAL / CHANGELOG.
- Kept restrictions: inactive cells in faulted stacks raise; k-faults raise; D3 (welded
  corners, Norne) open.
