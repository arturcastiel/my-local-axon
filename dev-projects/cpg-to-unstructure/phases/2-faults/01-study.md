# Study — phase 2-faults

**Goal:** port Tier B of MRST's `processGRDECL.m` so cpg2unstructured
handles non-matching-Z (faulted) CPG grids. Build the design plan and
PR breakdown before writing any Python.

**Status of this document:** initial draft. The structural decision and
dispatch story are committed (Section 1-3). Per-function deep dives
(`findFaults`, `findConnections`, `computeFaceGeometry`) are sketched
from a first read; will be expanded as the study continues.

---

## 1. Source confirmation

- File:
  `/mnt/c/projects/darsim/darsim-release/src/darsim_legacy/CornerPointGridGenerator/MRST_Functions/processGRDECL.m`
- LOC: 1293 (DARSim-vendored MRST snapshot)
- Same physical file the 1-design study read for Tier A. No version
  drift risk against the matching-Z Python code path already shipped
  in v0.1.0.

Cross-check copy at
`/mnt/c/projects/prototype/mrst/MRST/core/gridprocessing/processGRDECL.m`
— diff if needed, but not required for the port.

---

## 2. What v0.1.0 covers (Tier A, recap)

The current matching-Z Python pipeline (`cpg2unstructured.unstructured`)
follows MRST's structure for the *easy* case:

```
read_grdecl(path)              ← PR-3, PR-4
  ↓
from_grdecl(grdecl)            ← PR-5  (cpg.py, corner-cube + node dedup)
  ↓
build_topology(cube)           ← PR-7  (unstructured.py — orchestrator)
  ├─ find_i_faces(cube)        ← PR-6
  ├─ find_j_faces(cube)        ← PR-6
  ├─ find_k_faces(cube)        ← PR-7
  └─ assemble + dedup faces + invert to cell_faces + drop pinched cells
```

Each `find_*_faces` runs `_verify_matching_z_{i,j,k}(P, actnum_3d)`
first, which **raises `NonMatchingZError`** if any cell pair fails the
"shared-pillar Z values must match" check.

Phase 2-faults removes that raise.

---

## 3. Tier B section map

From the MATLAB source, the fault-relevant code lives in this stretch:

| Lines (MATLAB) | Function | Role |
|---:|---|---|
| 502-648 | `findFaces` | Matching-Z fast path; **also computes the `h` mask that decides which stacks are matching vs faulted** |
| 649-686 | `findVerticalFaces` | k-direction, also matching-Z first |
| 687-825 | `findFaults` | **Discover faulted pillar pairs in i or j**; outer loop over stacks |
| 826-852 | (inside `findFaults`) | Orchestrates per-stack `findConnections` calls + appends to grid |
| 853-1163 | `computeFaceGeometry` | **Build the actual fault-face polygons** from a/b corner-z lists + a connection table |
| 1164-1193 | `intersection` | 2D line-segment intersection helper (used by `computeFaceGeometry`) |
| 1194-1250 | `findConnections` | **Pair up overlapping a- and b-segments** along a faulted pillar pair |
| 1251-1284 | `doIntersect` / `overlap` | Segment-overlap predicates (used by `findConnections`) |

**Algorithmic core:** `findConnections` (pure 1D segment pairing) +
`computeFaceGeometry` (turns the pairing into 3D polygons + node IDs).
Everything else is plumbing / dispatch.

Estimated Python port size: **~350-400 LOC** including tests
(applying 1-design's ~60% MATLAB→numpy reduction ratio).

---

## 4. The dispatch story — confirmed by reading `findFaces`

This is the critical structural insight from the first read.

`findFaces` builds the matching-Z faces, but it ALSO computes the
matching-mask `h` per pillar pair:

```matlab
% lines 588-589 of findFaces
% f and g are 4-corner-id arrays per pillar pair at all k levels
% (one set from cell B(i,j,:), one from cell B(i+1,j,:))
h = repmat(
      all(
        reshape(all(f==g, 2), sz/2-[1,0,0]),
        3),
      [1,1,sz(3)/2]);
% h is (NX, NY, NZ/2) — true means "every face in this i-j stack
% along the full k-column is matching across the pillar pair"
```

The semantics: **`h(i,j) == true` only if EVERY face along the
entire (i,j) pillar pair's k-column is matching-Z.** Even one
mismatch flips the whole stack to faulted.

Then `findFaces` keeps only the matching stacks (`f = f(h,:)`) and
moves on. The unmatched stacks are picked up by `findFaults`, which
runs its own loop over the same (i,j) pillar pairs and processes each
faulted stack via `findConnections` + `computeFaceGeometry`.

### Why this matters for the Python port

The dispatch is per-stack, not per-face. That's good news:
- The matching-Z fast path (current Python code) processes the
  same units (pillar-pair stacks) that we'd skip in the fault case.
- The fault path can be a separate function that processes only the
  faulted stacks, returning a `Faces` record that gets concatenated
  with the matching-Z output.

---

## 5. Structural decision committed (D-2F-1)

**D-2F-1 — Widen existing find_*_faces to dispatch matching-Z vs faulted
inline, rather than introducing a parallel `find_faulted_faces` API.**

**Context.** Two designs were considered before the study:

| Design | Pro | Con |
|---|---|---|
| **A — Widen inline** (chosen) | Single public entry per direction; matches MRST's design (one `findFaces` that branches); cleaner orchestrator | More invasive to PR-6 + PR-7 code |
| **B — Separate `find_faulted_*`** | Zero regression risk to PR-6/PR-7 code | Two public entry points; orchestrator must dispatch; doesn't match MRST design |

**Decision.** **A (widen inline).** Justified by:
1. MRST's processGRDECL.m has a SINGLE `findFaces` that handles both
   cases. The dispatch is internal — through the `h` mask. Mirroring
   that structure means lower drift risk against the reference and
   easier review for anyone who already knows MRST.
2. The fast matching-Z path can be preserved bit-identically by
   gating the new fault code on `np.any(faulted_mask)` first.
   When `h` is all-true (the common case for synthetic decks and
   the test fixtures we shipped), the new code path is one
   `np.all` call away from the existing PR-6/PR-7 vectorised
   implementation.
3. Single entry point per direction → `build_topology` stays one-line
   per call → no public API churn for users.

**Consequences.**
- `_verify_matching_z_i/_j/_k` stop raising. They become
  `_faulted_mask_i/_j/_k` (or similar) that RETURN a per-pillar-pair
  boolean array. Callers branch on this.
- `find_i_faces`, `find_j_faces`, `find_k_faces` keep their
  signature (`cube → Faces`) but internally:
  ```
  faulted = _faulted_mask_i(cube.P, cube.actnum_3d)
  if not faulted.any():
      return _find_matching_i_faces_fast(cube)       # PR-6 code
  matching = _find_matching_i_faces_fast(cube[~faulted])
  faulted_faces = _find_faulted_i_faces(cube[faulted]) # new
  return Faces.concat(matching, faulted_faces)
  ```
- `NonMatchingZError` still exists, but reserved for *genuinely
  unsupported* cases inside the fault code path (e.g. a degenerate
  geometry we explicitly don't handle yet). Most decks that used
  to raise will now succeed.
- The Tier A test suite must still pass unchanged (the matching-Z
  fast path is bit-identical when `faulted_mask.any() == False`).

---

## 6. Algorithmic narrative (deep read of lines 687-1293)

### 6.1 `findFaults(G, P, B, actnum, tags, opt)` — lines 687-849

The outer dispatch driver for the fault path. Three big things:

**(a) Layout transform — z to first axis (lines 753-756).**
```matlab
P = permute(P, [3,1,2]);   % now P[k_slot, i_slot, j_slot]
B = permute(B, [3,1,2]);   % cell-block array similarly
```
The corner-point array `P` is reshaped so that `k` becomes the first
dimension — consecutive elements in memory walk a single pillar from
top to bottom. This makes per-stack work cache-friendly. Python
equivalent: `np.moveaxis` or build the index arrays in the right
order from the start.

**(b) Recompute `h` and filter to faulted stacks (lines 781-791).**
The same matching-mask `h` from `findFaces` is recomputed at the
pillar-pair level — for each (i_pillar, j) pair, are ALL the
i-direction faces matching? Then `~h` selects the faulted stacks:
```matlab
a  = a(~h(:), :);    % only point ids from faulted stacks
b  = b(~h(:), :);
cA = cA(~h(1:2:end));  % only cells from faulted stacks
cB = cB(~h(1:2:end));
```

**(c) The dZ artificial-offset trick (lines 793-798).** ⚡ KEY TRICK.
```matlab
dz   = max(z) - min(z) + 1;                         % bigger than any geometry
auxz = reshape(1:prod(sz2(2:3)), sz2(2:3)) * dz;    % unique offset per stack
dZ   = permute(repmat(auxz, [1,1,szP(1)]), [3,1,2]);
dZ   = repmat(dZ(~h), [1, 2]);
```
Every faulted stack is given a HUGE artificial Z-offset (`dz × stack_id`)
before being fed to `findConnections`. This **separates the stacks
in z-space so the 1D sweep can process them all in one call** without
cross-stack contamination. After `findConnections` returns connection
pairs, the dZ is conceptually discarded (we only used it to keep stacks
sortable by stack-id).

This is the cleverest part of the algorithm and we must port it
faithfully — otherwise `findConnections` would erroneously connect
cells in stack A with cells in stack X just because their z-ranges
happen to overlap.

**(d) Inactive-cell filtering on BOTH SIDES (lines 803-811).**
Inactive cells are removed from each side's pillar-list independently.
After this, the cA/cB cell-index arrays may have different lengths —
that's fine for `findConnections`, which just iterates two lists.

**(e) The call sequence (lines 826-846).**
```matlab
C = findConnections(za, zb);              % sweep-line → connection table

% Build the face-to-cell map. Cell 0 = boundary.
ka       = zeros(...); ka(1:2:end) = cA(:);
kb       = zeros(...); kb(1:2:end) = cB(:);
new      = [ka(C(:,1)), kb(C(:,2))];      % (a_cell, b_cell) per connection
ind      = any(new ~= 0, 2);              % drop rows with 0,0

% Build the geometry
[points, ncor, cor] = computeFaceGeometry(a, b, C(ind,:), points);

% Append to grid
G.faces.neighbors = [G.faces.neighbors; new(ind,:)];
G.faces.nodes     = [G.faces.nodes;     cor];
G.faces.nodePos   = cumsum([1; diff(G.faces.nodePos); ncor]);
```

The `ka`/`kb` interleaving (`ka(1:2:end) = cA`) is because each cell
spans TWO rows in the (a, b) point-list arrays (top + bottom), so cells
sit at odd indices. The `C(:,1)` connection indices are 1-based and
point at the BOTTOM row of each cell — `ka(C(:,1))` retrieves the
cell ID at that row.

**(f) Direction handling.** `findFaults` is called separately for
i-faults (j-direction face stacks) and j-faults (i-direction face
stacks). The orchestrator (`processGRDECL` main) sets up the
appropriate permutation of P/B before each call. **k-direction
fault handling is rare and treated similarly via `findVerticalFaces`
+ a parallel `findFaults`-like flow.**

### 6.2 `findConnections(za, zb)` — lines 1194-1247

Pure 1D sweep-line algorithm. **No geometry, just integer index
pairs.** Easy to port + test in isolation — this is the natural PR-1
of the phase.

Input layout (the docstring's ASCII diagram is essential):

```
            (1)                       (2)         pillar pair
             |                         |
   za(i+1,1) o-------------------------o za(i+1,2)
             |                         |
   zb(j+1,1) * * * *                   |
             |       * * * *           |          ^
             |               * * * *   |          | z positive
             |                       * * zb(j+1,2)|
             |                         |
     za(i,1) o-------------------------o za(i,2)
             |                         |
     zb(j,1) * * * * * * * *           |
             |               * * * * * * zb(j,2)
```

- `za` is `(n_a_cells+1, 2)` — top row of cell `i` is `za[i, :]`, bot
  row is `za[i+1, :]`. Two columns = pillar 1 and pillar 2 of the pair.
- `zb` is `(n_b_cells+1, 2)` likewise.
- Output `C` is `(n_connections, 2)` — each row is `(ia, ib)`, an
  index pair: cell A-side `ia`, cell B-side `ib`.

The MATLAB body:

```matlab
C = zeros(0,2);
j1 = 1; j2 = 1;
for i = 1:numel(za(:,1)) - 1
    j = min(j1, j2);   % largest j where both
                       % zb(j,1) < za(i,1) AND zb(j,2) < za(i,2)
    while any(zb(j,:) < za(i+1,:), 2)
        if doIntersect(za(i,:), za(i+1,:), zb(j,:), zb(j+1,:))
            C = [C; i, j];
        end
        if zb(j,1) < za(i+1,1), j1 = j; end
        if zb(j,2) < za(i+1,2), j2 = j; end
        j = j + 1;
    end
end
```

**Sweep-line semantics:** outer loop over A-side cells (i). For each
i, inner loop over B-side cells (j) that COULD overlap (`zb[j,:]`
still above `za[i+1,:]` on at least one pillar). For each candidate
overlap, run the strict `doIntersect` predicate — if true, emit a
connection.

**The j1/j2 tracking is a per-pillar checkpoint** to avoid re-walking
the whole B-list for each new i. It tracks the largest j on each
pillar that's still below the top of the current A-cell — this is the
start of the inner loop for the NEXT i.

**Python port plan:** keep this exact algorithm. The MATLAB code is
already tight. Vectorising it is *possible* via segment-tree or
interval-overlap broadcasting but unnecessary — `findConnections` is
called once per faulted stack (rare), inputs are small (a few dozen
cells per stack), and clarity dominates micro-optimisation here.

Append the two helper predicates (next).

### 6.3 `intersection(La, Lb, PTS)` — lines 1164-1190

3D line-segment intersection, parametrised by z. Used by
`computeFaceGeometry` to compute the XY of where the A-line and the
B-line cross.

```matlab
za = z(La);                                  % start + end z of A-line
zb = z(Lb);                                  % start + end z of B-line
t  = (zb(:,1) - za(:,1)) ./                  % parameter along A-line
     (diff(za,1,2) - diff(zb,1,2));          %   where A and B z match
xa = x(La);                                  % start + end x of A-line
ya = y(La);
pts(:,1) = diff(xa,1,2) * t + xa(:,1);       % interpolate x
pts(:,2) = diff(ya,1,2) * t + ya(:,1);       % interpolate y
pts(:,3) = diff(za,1,2) * t + za(:,1);       % interpolate z (= intersect z)
```

Closed-form: `t = (zb1 - za1) / (Δza - Δzb)` where Δza = za2 - za1,
Δzb = zb2 - zb1. Works because we're intersecting two parametric line
segments in a 2D (z, x) projection then re-using `t` to compute y.

The "intersection in z" framing only works because pillars are
**roughly vertical** (Δz is the dominant gradient). Strongly tilted
pillars could break this — flag as a limitation in the spec.

### 6.4 `doIntersect(za1, za2, zb1, zb2)` — lines 1251-1281

Strict-overlap predicate between an A-face quadrilateral and a B-face
quadrilateral, given by their 4 corner z's on the 2 pillars.

```matlab
val = overlap(za1(1), za2(1), zb1(1), zb2(1)) ...  % overlap on pillar 1
    | overlap(za1(2), za2(2), zb1(2), zb2(2)) ...  % overlap on pillar 2
    | (za1(1)-zb1(1)).*(za1(2)-zb1(2)) < 0  ...    % "le fix speciale": cross
    | (za2(1)-zb2(1)).*(za2(2)-zb2(2)) < 0;        %   on a top or bot edge

if all(za1-za2 == 0), val = false; end             % pinched A → no overlap
if all(zb1-zb2 == 0), val = false; end             % pinched B → no overlap
```

Three cases for positive overlap:
1. The A-face and B-face overlap in z on pillar 1, OR
2. They overlap in z on pillar 2, OR
3. ⚡ "Le fix speciale": one face's top edge crosses the other face's
   top edge (or same for bottom). This catches the **diamond case**
   where the two faces don't share any vertical overlap on either
   pillar individually but DO overlap because their lines cross.

The pinched-cell guards at the end suppress connections involving
zero-thickness cells (pinch-outs).

### 6.5 `overlap(xa1, xa2, xb1, xb2)` — lines 1285-1292

Trivial interval-overlap predicate:
```matlab
val = max(xa1, xb1) < min(xa2, xb2);
```
Strict (`<`, not `<=`) — zero-width overlap is rejected.

### 6.6 `computeFaceGeometry(a, b, C, points)` — lines 853-1160

⚠ The heaviest function in Tier B. 300 LOC. Builds the actual 3D
polygons of fault-faces from the connection table.

**Setup (lines 964-972).** For each connection k:
- `pa[k]` = 4 point indices = `[a(C[k,0], 0:2); a(C[k,0]+1, 0:2)]`
  → 4 corners of the A-face for connection k
- `pb[k]` = 4 point indices on the B-side similarly
- The 4 corners are labelled (pillar 1 bot, pillar 2 bot, pillar 1 top,
  pillar 2 top) → reading order = `[A12_p1, A12_p2, A34_p1, A34_p2]`
  where A12 is the bot row and A34 is the top row.

**Fast path (lines 974-978).** If `pa == pb` for every row of pa/pb,
the A-face and B-face are identical → emit a 4-node face directly.
This handles connections that turn out to be matching after all.

**The general case (lines 982-1159) — the 8-position J-table.**
The output of `computeFaceGeometry` per face is a row of node ids,
already in CLOCKWISE order so face normal points from cell A to cell B.

**Layout of the 8 possible positions:**

```
  position 1    : pillar 1 BOT corner             (p1)
  position 2    : A12 × B12 intersection point    (p2)
  position 3    : pillar 2 BOT corner             (p3)
  position 4    : A12 × B34  OR  A34 × B12 (diamond case, right)
  position 5    : pillar 2 TOP corner             (p5)
  position 6    : A34 × B34 intersection point    (p6)
  position 7    : pillar 1 TOP corner             (p7)
  position 8    : A12 × B34  OR  A34 × B12 (diamond case, left)
```

Reading positions 1→2→3→4→5→6→7→8 traces clockwise around the
polygon. NaN positions are skipped (the face has anywhere from 4
to 8 actual corners).

**Step 1 (lines 989-993) — choose pillar points p1, p3, p5, p7.**
For each of the 4 pillar-corner candidates (top/bot × pillar1/pillar2),
pick the one closer to the OTHER side:
```matlab
i = [az(:,1:2) < bz(:,1:2),     % bot corners: pick higher one
     az(:,3:4) > bz(:,3:4)];    % top corners: pick lower one
I    = pa;
I(i) = pb(i);
```
The intuition: a fault face's pillar-corner is at the inner z-value
on each pillar (where both A and B cells exist). For the bottom of the
face, that's `max(za_bot, zb_bot)`. For the top, that's
`min(za_top, zb_top)`.

**Step 2 (lines 996-1006) — compute the 4 possible intersections.**
```matlab
PP = [pa(:,1:2); pa(:,3:4); pa(:,1:2); pa(:,3:4)];   % A-line endpoints
QQ = [pb(:,1:2); pb(:,3:4); pb(:,3:4); pb(:,1:2)];   % B-line endpoints
i  = (z(PP(:,1)) - z(QQ(:,1))) .* (z(PP(:,2)) - z(QQ(:,2))) < 0;
Q  = intersection(PP(i,:), QQ(i,:), points);
[Q, _, b] = unique(Q, 'rows');
```
4 stacked candidate pairs:
- A12 × B12  (top-top intersection candidate)
- A34 × B34  (bot-bot intersection candidate)
- A12 × B34  (cross-line: A bot vs B top)
- A34 × B12  (cross-line: A top vs B bot)

The predicate `(z[P1] - z[Q1]) * (z[P2] - z[Q2]) < 0` tests whether
the two lines actually CROSS in z on their pillar-pair span — same
test as `doIntersect`'s "le fix speciale".

Lines that don't cross get filtered out before calling `intersection`.

**Step 3 (lines 1027-1036) — assemble J's pillar positions.**
```matlab
J = nan(n, 8);
% Remove duplicate pillar points (pinches)
I(I(:,1) == I(:,3), 1) = nan;       % top-1 == bot-1 → pinch on pillar 1
I(I(:,2) == I(:,4), 2) = nan;       % top-2 == bot-2 → pinch on pillar 2
J(:, [1,3,5,7]) = I(:, [1,2,4,3]);  % pillar points in clockwise order
```
Note: `I[:, [1,2,4,3]]` swaps the last two columns because
J's "5,7" positions need pillar-2-top BEFORE pillar-1-top to maintain
clockwise order.

**Step 4 (lines 1065-1066) — assemble J's straight intersections.**
```matlab
J(:, 2) = f(:,1);   % p2 = A12 × B12  (bot-bot)
J(:, 6) = f(:,2);   % p6 = A34 × B34  (top-top)
```

**Step 5 (lines 1124-1149) — the diamond cases.**
This is the trickiest part. When the upper envelope intersects the
lower envelope on the LEFT or RIGHT side, the polygon becomes a
diamond and some pillar corners must be NaN'd out.

Four cases:
- **Case 1**: `A12 × B34` exists AND `A12 > B34 on pillar 1` (A bot
  is above B top on the left) → polygon has a vertex at position 8,
  positions 1 and 7 are NaN'd.
- **Case 2**: `A12 × B34` exists AND NOT case-1's left-condition →
  vertex at position 4, positions 3 and 5 NaN'd.
- **Case 3**: `A34 × B12` exists AND NOT case-4's left-condition →
  vertex at position 4, positions 3 and 5 NaN'd.
- **Case 4**: `A34 × B12` exists AND `B12 > A34 on pillar 1` →
  vertex at position 8, positions 1 and 7 NaN'd.

The "left vs right" decision is whether the crossing happens nearer
pillar 1 or nearer pillar 2.

**Step 6 (lines 1153-1158) — compact J → flat corner list.**
```matlab
Corners  = [J, inf(size(J,1), 1)]';
Corners  = rlencode(Corners(~isnan(Corners)), 1);
numNodes = diff([0; find(isinf(Corners))]) - 1;
Corners  = Corners(~isinf(Corners));
```
Append an `inf` sentinel per row, transpose to row-major, drop NaNs,
run-length-encode away repeats (catches duplicate corners that survived
step 3's pinch-removal). The `inf` sentinel marks face boundaries in
the resulting flat array — `numNodes[k]` is the corner count of face k.

### 6.7 Port plan implications

| MATLAB construct | numpy equivalent | Difficulty |
|---|---|---|
| `permute(P, [3,1,2])` | `np.moveaxis(P, 2, 0)` or pre-build indices in target order | trivial |
| `repmat(all(...), [...])` for `h` mask | `np.tile` + `np.all` along axis | trivial |
| **dZ artificial-offset trick** | direct port — `auxz * dz` and broadcast | trivial |
| `findConnections` while-loop | direct port to Python loop (small N) | trivial |
| `intersection` parametric line solver | vectorised numpy, identical formula | trivial |
| `doIntersect` 4-way predicate | direct port, vectorised | trivial |
| **8-position J-table assembly** | vectorised numpy with `np.where` for the 4 diamond cases | **medium** — most subtle part |
| `rlencode` compaction | bool-mask + flatten + np.unique | easy |

The hard parts are all in `computeFaceGeometry`. The 4-diamond-cases
branching and the clockwise-order invariant are easy to get wrong —
visual verification via the viz/ sidecar (ghost overlay + face-edge
view) is essential for every PR that touches this code.

---

## 6b. Worked example — what `findConnections` produces

For a simple deck with a single half-cell Z-offset on a 2×2×2 grid
(the proposed PR-1 fixture, see §7), consider the i-face stack
between i=0 and i=1, on pillar pair (i=1, j=0)-(i=1, j=1):

```
A-side cells (i=0):    B-side cells (i=1, offset +0.5):
  za[0] = (0.0, 0.0)     zb[0] = (0.5, 0.5)
  za[1] = (1.0, 1.0)     zb[1] = (1.5, 1.5)
  za[2] = (2.0, 2.0)     zb[2] = (2.5, 2.5)
```

(2 cells per side, 3 corner-z values each, both pillars identical
for simplicity.)

`findConnections(za, zb)` walks:
- i=0 (A-cell 0, z=0..1): finds B-cells whose z-range overlaps with
  (0, 1) → b=0 (z=0.5..1.5) → emit (0, 0).
- i=1 (A-cell 1, z=1..2): finds b=0 still overlapping → emit (1, 0).
  Then b=1 (z=1.5..2.5) overlapping → emit (1, 1).

Total 3 connections. Each becomes one fault-face polygon. The viz/
ghost overlay should show: A-cells in green (i=0 column), B-cells in
green (i=1 column, offset down 0.5), and the 3 fault-face polygons
visible as the "interlock" between them.

---

---

## 7. Test-deck strategy

We need a minimal faulted `.grdecl` deck to drive PR-1 of this phase.
Criteria:
- Smallest grid that exercises a real fault offset (4-8 cells).
- Single fault plane (no multi-fault interaction in PR-1).
- Z offset of ~½ cell height on the fault plane (easy to eyeball
  in the viz/ side-by-side render).

**Proposed fixture: `tests/fixtures/simple_faulted_2x2x2.grdecl`**
- 2×2×2 cartesian box, all-active.
- Fault plane between i=0 and i=1: cells in the i=1 column have
  their entire k-column shifted down by 0.5 in z relative to i=0.
- 8 cells, 1 faulted i-face stack (the i=1 face shared between
  i=0 and i=1), 4 matching-Z j-face stacks, 8 matching-Z k-face
  stacks (k-faces don't see the fault).

This is the smallest deck that has exactly ONE faulted stack so we
can hand-verify `findConnections` output.

We may also need a `simple_faulted_3x3x2.grdecl` later for multi-cell
fault propagation testing.

---

## 8. Port plan — wave structure (refined after deep read)

| Wave | PRs | Theme | LOC est. |
|---|---|---|---:|
| 1 | PR-1 | **Test fixture + faulted-mask helper.** Add `tests/fixtures/simple_faulted_2x2x2.grdecl` (half-cell Z offset between i=0 and i=1). Add `_faulted_pillar_mask_i/_j/_k(P, actnum_3d)` returning `(NX,NY,NZ)` bool arrays — i.e. rename + repurpose the existing `_verify_matching_z_*` helpers (stop raising, return mask instead). Tier A regression: no behaviour change yet — `find_*_faces` still raise `NonMatchingZError` if mask is non-empty. | +40 |
| 1 | PR-2 | **`find_connections(za, zb)`** as pure 1D function in a new private module `cpg2unstructured._fault_connections`. Direct port of MRST's `findConnections` + `doIntersect` + `overlap` predicates. Unit tests with hand-crafted z-list inputs covering: matching stacks, half-offset, full-offset (all cells on B-side below all on A-side → 0 connections), pinched cells. | +90 |
| 2 | PR-3 | **`intersection` line solver** as pure helper in `_fault_geometry`. Vectorised numpy implementation of MRST's parametric-line-in-z formula. Unit tests with horizontal + tilted line pairs. | +40 |
| 2 | PR-4 | **`compute_face_geometry`** — the big one. Port the 8-position J-table assembly + 4 diamond cases. Pillar-corner picking (max-of-bot, min-of-top). Intersection-candidate filtering. NaN compaction. Returns per-face node-id sequences ALREADY clockwise. Heavy testing on hand-built `(a, b, C)` inputs that cover each of the 4 diamond cases. | +150 |
| 3 | PR-5 | **dZ artificial-offset trick + `_find_faulted_i_faces`** glue function. Implements the `findFaults`-equivalent: filter to faulted stacks, apply dZ offset, call `find_connections`, call `compute_face_geometry`, build the (cell_a, cell_b) neighbour pairs. Returns a `Faces` record concatenable with the matching-Z output. Tests on the simple_faulted_2x2x2 fixture (expected 3 i-fault faces per the worked example in §6b). | +80 |
| 3 | PR-6 | **Widen `find_i_faces`** to dispatch matching vs faulted. Branch on `_faulted_pillar_mask_i.any()`. Concatenate matching + faulted face records. Remove the `NonMatchingZError` raise (move to `_find_faulted_i_faces` as a fallback for unsupported degenerate cases). **Tier A regression budget**: ALL 1-design tests must pass identically; the matching-Z fast path is bit-identical when no faults present. | +30 |
| 4 | PR-7 | **`find_j_faces`** widened symmetrically. Reuses `_find_faulted_j_faces` (same code as i but on transposed axes). | +40 |
| 4 | PR-8 | **`find_k_faces`** widened symmetrically. Faulted k-direction is rare in real decks (faults are typically vertical, hitting i/j) but the structure is identical, so port for completeness. | +30 |
| 5 | PR-9 | **Polish + viz validation.** Larger faulted fixtures: `simple_faulted_3x3x2.grdecl` with TWO adjacent fault stacks; `simple_faulted_with_inactives.grdecl` combining fault + ACTNUM. End-to-end pipeline test through `build_topology`. Viz/ sidecar verification: ghost-overlay should show fault faces matching the expected interlock pattern. | +60 |
| 5 | PR-10 | **README + CHANGELOG + v0.2.0 stamp.** Update `Limitations` section to remove "matching-Z only". Bump `pyproject.toml` + `__version__` to "0.2.0". Reorganise CHANGELOG under `[0.2.0] - 2026-...`. Release script analogous to v0.1.0's `release-v0.1.0.sh`. | +30 |

**Total estimate: 10 PRs · ~590 LOC Python.**

(The 8-PR estimate in the v1 draft missed the size of `compute_face_geometry`
— after the deep read it's clear PR-4 alone is ~150 LOC of subtle
branching, deserving its own PR. Adding PR-9/PR-10 for fixtures and
the release stamp brings the total to 10.)

### Wave dependencies

```
  PR-1 (fixture + mask)
    ↓
  PR-2 (find_connections)         independent of PR-3
    ↓
  PR-3 (intersection helper)
    ↓
  PR-4 (compute_face_geometry)    depends on PR-3 + PR-2 outputs
    ↓
  PR-5 (faulted_i_faces glue)     depends on PR-2 + PR-4
    ↓
  PR-6 (widen find_i_faces)       depends on PR-5
    ↓
  PR-7 (find_j_faces) ─┐
  PR-8 (find_k_faces) ─┴─→ PR-9 (polish/fixtures) → PR-10 (release)
```

### Matching-Z regression budget (Tier A invariance check)

After PR-6 lands, the following 1-design tests MUST still pass without
modification, byte-for-byte identical outputs:

- `tests/test_grdecl_reader.py` — parser tests (no change)
- `tests/test_cpg.py` — from_grdecl tests (no change)
- `tests/test_unstructured.py` — face finders + build_topology on
  matching-Z fixtures
- `tests/test_geometry.py` — face/cell geometry
- `tests/test_index_map.py` — IndexMap
- `tests/test_graph.py`, `tests/test_graph_fast.py` — graph layer
- `tests/test_props.py` — UnstructuredGrid + attach_props

The matching-Z fast path inside the widened `find_*_faces` is the
SAME numpy code that PR-6 (Tier A) shipped, gated on
`faulted_mask.any() == False`. If any of the above tests regress,
the dispatch was implemented incorrectly.

### Viz sidecar role per PR

Every PR from PR-5 onwards adds a viz check:
- PR-5 (faulted_i_faces): expect 3 fault-face polygons on the
  simple_faulted_2x2x2 fixture; viz ghost overlay shows them as the
  interlock between offset cells.
- PR-6/7/8 (widen): viz side-by-side renders pass; CPG and unstructured
  match topologically on faulted decks (the gap that was
  `NonMatchingZError` for v0.1.0 closes).
- PR-9 (polish): viz screenshots of the larger fixtures committed
  to `viz/screenshots/` for posterity (private dev tooling).

---

## 9. Open questions for the user (Q-2F-*)

- **Q-2F-1.** Should PINCH NNCs (line 1234 in MATLAB — "Precise check
  to avoid adding pinched layers") be implemented in this phase, or
  treated as a follow-up? *Recommendation: implement during PR-3
  (geometry) — the predicate is tiny and `findConnections` already
  emits the data we'd need. Skipping it leaves real decks broken.*
- **Q-2F-2.** Faulted k-direction (PR-7 in the plan above) — is it
  worth doing in this phase, or defer? Real CPG decks rarely have
  k-faults (k is usually the vertical/layering direction; faults
  are typically vertical, hitting i and j). *Recommendation: include
  it for completeness, ~30 LOC; symmetric to i/j once those work.*
- **Q-2F-3.** Naming for the new `NonMatchingZError`-free functions:
  keep the name `_verify_matching_z_*` (now returning a mask
  instead of raising) or rename to `_faulted_pillar_mask_*`?
  *Recommendation: rename to `_faulted_pillar_mask_*` — more honest
  about the new behaviour; the old name implied "raise on fault".*

---

## 10. Study status

### ✓ Done (this document)
1. ✓ Source confirmed (§1). DARSim copy, 1293 LOC.
2. ✓ Tier A recap + raise-point identification (§2).
3. ✓ Tier B section map (§3). 7 functions across lines 502-1284.
4. ✓ Dispatch story read from `findFaces` (§4). Per-stack via `h` mask.
5. ✓ D-2F-1 committed (§5). Widen-inline design.
6. ✓ Deep read of `findFaults` (§6.1). dZ artificial-offset trick captured.
7. ✓ Deep read of `findConnections` (§6.2). Sweep-line algorithm understood.
8. ✓ Deep read of `intersection` + `doIntersect` + `overlap` (§6.3-6.5).
9. ✓ Deep read of `computeFaceGeometry` (§6.6). 8-position J-table + 4 diamond cases captured.
10. ✓ Port-plan implications table (§6.7).
11. ✓ Worked example for the proposed PR-1 fixture (§6b).
12. ✓ Test-deck strategy (§7).
13. ✓ Port plan refined to 10 PRs across 5 waves with LOC estimates (§8).
14. ✓ Matching-Z regression budget appendix in §8.

### ⌛ Pending — handoff to 02-plan.md and PR-1

15. ⌛ Construct the faulted fixture's `.grdecl` text by hand and
    sanity-check it parses with the existing `read_grdecl`. (PR-1
    work; fixture text drafted as part of PR-1's spec.)
16. ⌛ Write `phases/2-faults/02-plan.md` — copy §8's wave structure
    into the plan format, add ADR cross-references, finalise.
17. ⌛ Write `phases/2-faults/03-prs/pr-01.md` — spec for PR-1
    (faulted fixture + `_faulted_pillar_mask_*` rename, no
    behaviour change yet).

### Open questions for the user
- **Q-2F-1.** PINCH NNCs — already handled by `doIntersect`'s pinched-cell
  guards (lines 1279-1280) + the rlencode dedup in
  `computeFaceGeometry`. Real PINCH NNCs (explicit cross-layer
  connections) aren't in scope unless the deck declares `PINCH`
  keyword — out of phase 2-faults scope; flagged for a follow-up
  if needed.
- **Q-2F-2.** Faulted k-direction — included as PR-8 per the plan.
  Symmetric to i/j and the structure is identical; ~30 LOC.
- **Q-2F-3.** Naming — committed to `_faulted_pillar_mask_*` (renames
  the `_verify_matching_z_*` predicates honestly).

### Risks identified during the deep read
- **R-1 (medium).** `compute_face_geometry`'s 4-diamond-case branching
  is the algorithmic hot spot. Subtle bug here would produce visually
  plausible faces with wrong corner ordering → wrong face normals.
  Mitigation: visual verification via viz/ ghost-overlay AT EVERY
  PR from PR-4 onwards. Add explicit normal-direction tests on the
  fault faces (face normal must point A→B per MRST convention).
- **R-2 (low).** The dZ artificial-offset trick assumes `dz` is
  larger than the deck's total z-extent. Edge case: a deck with
  z-extent > the int representation? Realistically not — deck
  z-extents are O(1000) meters, dz×stack_id easily within float64.
  Mitigation: assert `dz > z_extent` at runtime.
- **R-3 (low).** The `intersection` helper's z-parametrisation
  fails if pillars are heavily tilted (Δz tiny vs Δx/Δy). Real CPG
  decks have nearly-vertical pillars (deviation typically <10%);
  no real-world deck has triggered this. Mitigation: assert
  `abs(Δz) > epsilon` in the helper, fall back to a general 3D
  line-intersection if violated. Spec for PR-3 should include
  this guard.
