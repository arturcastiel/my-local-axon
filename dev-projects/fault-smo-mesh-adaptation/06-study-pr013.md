# Study — PR-013: why Norne cannot be ingested

**Status:** complete · **Date:** 2026-07-28 · **Verdict:** the original scope was wrong
twice over. Three independent defects, one of them silent. Recommended fix is
conservative and staged.

---

## 1. The question

`build_topology` fails on Norne. PR-013 was planned as *"make `build_topology` survive
welded corners"* and estimated **L**. Is that right?

No. Two revisions were needed, each forced by measurement.

---

## 2. Investigation path, in order

### 2.1 First diagnosis — welded corners (WRONG, but the measurement was sound)

```
RuntimeError: face 40459 has more than 2 neighbours: [104513 104514] + 109665
```

Faces are deduplicated by their sorted 4-node-id set. Measured on Norne: **10,912 of
113,344 cells (9.6%)** have fewer than 8 distinct corner node ids — 1,137 with 7,
1,115 with 6, 286 with 5 — plus 8,374 pinched cells. Coordinate-based node dedup
(`np.round(xyz * 1e9)`) merges coincident corners, so two geometrically distinct faces
can share one node-id set and that entry acquires a third neighbour.

The measurement is correct. The *conclusion* — that fixing dedup fixes Norne — was not.

### 2.2 Second diagnosis — the 4-corner restriction (also incomplete)

Calling the fault-aware finder directly gives a **different** error:

```
find_i_faces : NonMatchingZError: fault polygon at connection 0 of stack i=4-5, j=2
               has 3 corners; v0.2.0 supports only 4-corner fault polygons
find_j_faces : NonMatchingZError: ... i=5, j=9-10 has 5 corners
```

`unstructured.py:327`. A deliberate, documented restriction — not a defect.

Corner-count distribution on Norne (sampled to the first raise):

| corners | count | share |
|--------:|------:|------:|
| 3 | 28 | 10.2% |
| 4 | 219 | **79.9%** |
| 5 | 27 | 9.9% |
| total | 274 | |

Plus **256 new intersection nodes** appended, which the same guard separately refuses.

`compute_face_geometry` (`_fault_geometry.py`, a direct MRST port) **already builds
3–8 corner polygons correctly**. The geometry needs no work. The blocker is that
`Faces.nodes` is a fixed `(Nfaces, 4)` array.

This led to an **XL** re-estimate. That was also wrong.

### 2.3 Third diagnosis — two disconnected code paths (CORRECT)

Attempting to simulate the fix — normalise every polygon to a quad and let the
pipeline run — produced **zero** polygons and the *original* neighbours error.
`compute_face_geometry` was never called.

Reading `build_topology` explains it: lines 1092–1102 call `_i_face_quads`,
`_j_face_quads`, `_k_face_quads` **directly**. It never calls `find_i_faces` /
`find_j_faces` — the fault-aware builders that carry the polygon restriction.

Two independent paths exist:

| path | fault-aware | fails on Norne with |
|------|-------------|---------------------|
| `build_topology` → `_*_face_quads` | **no** | "more than 2 neighbours" |
| `find_i_faces` / `find_j_faces` | yes | "3 corners" / "5 corners" |

The comment at `unstructured.py:1064-1067` says the top-level fault guard was removed
*"because find_i_faces and find_j_faces now dispatch matching vs faulted inline"* —
implying `build_topology` was meant to route through them. It does not. **That is the
integration gap.**

### 2.4 The silent defect

Do the two paths agree where both succeed?

| fixture | raw i-faces | fault-aware | identical |
|---------|------------:|------------:|:---------:|
| fault_simple | 12 | 12 | yes |
| hole_1x1x3 | 4 | 4 | yes |
| islands_5x1x1 | 6 | 6 | yes |
| pinched_1x1x3 | 4 | 4 | yes |
| pinchout_2x2x2 | 11 | 11 | yes |
| simple_2x2x2 | 12 | 12 | yes |
| simple_3x3x2 | 24 | 24 | yes |
| simple_3x3x3 | 36 | 36 | yes |
| **simple_faulted_2x2x2** | **12** | **14** | **NO** |
| simple_faulted_2x2x2_j | 12 | 12 | yes |
| **simple_faulted_3x3x2** | **24** | **27** | **NO** |
| simple_faulted_3x3x2_jfault | 24 | 24 | yes |

They disagree on exactly the **i-faulted** fixtures, and the fault-aware path produces
MORE faces — the fault splits the raw path merges. The j-faulted fixtures agree on
i-faces, as they should, since their fault is in the other direction.

> **`build_topology` is silently producing incorrect topology on faulted decks today**,
> in every case where it does not crash. The fixtures pass while the face set is wrong.

This is the most serious finding in the study and it was not on anyone's list.

---

## 3. What is actually wrong — three defects

| # | Defect | Severity | Evidence |
|---|--------|----------|----------|
| **D1** | `build_topology` bypasses the fault-aware finders, so faulted decks get merged faces | **silent wrong answer** | 12→14 and 24→27 faces on the i-faulted fixtures |
| **D2** | The fault-aware path refuses non-quad polygons | loud, documented | 20% of Norne's fault polygons are 3- or 5-corner |
| **D3** | Coordinate node dedup welds coincident corners, giving faces 3 neighbours | loud | 9.6% of Norne cells have <8 distinct corners |

D1 is the one to fix first. It is also the only one that is currently **lying**.

---

## 4. Recommended solution — conservative and staged

Each step is independently verifiable and independently shippable. Stop at any point.

### Step A — route `build_topology` through the fault-aware finders · **S**

Replace the direct `_i_face_quads` / `_j_face_quads` calls with `find_i_faces` /
`find_j_faces`. This is the integration the code comment already claims exists.

**Not behaviour-preserving, and that is the point:** it changes results on i-faulted
decks, and the change is the fix. Verification must therefore be explicit:

- all 8 non-i-faulted fixtures produce byte-identical topology (proven above — they
  already agree);
- the 2 i-faulted fixtures gain the expected extra faces, each checked by hand against
  the fault geometry;
- `tests/test_build_topology_faulted.py` will need its expectations updated — review
  each change as a **correction**, never a rubber-stamp.

On Norne this converts the failure from D3's neighbours error to D2's polygon error.
That is progress: one well-understood blocker instead of two.

### Step B — accept 3-corner polygons as degenerate quads · **S–M** (revised)

Store a triangle as `(a, b, c, c)`. `_real_cell_mask` already accepts faces with
*"≥ 3 unique node ids"*, so the face container needs no change.

**But measurement revised this estimate upward.** All **28 of 28** 3-corner polygons
on Norne reference an *appended intersection node* — a node `compute_face_geometry`
creates because the fault cuts an edge between existing corners. A second guard,
immediately after the corner check, refuses exactly that:

```
NonMatchingZError: unexpected intersection nodes from fault stack i=4-5, j=2
```

So Step B must also **adopt the grown node table** (`new_points` rather than
`points`). That is plumbing rather than redesign, but it has a real consequence:
appended nodes are face-only and belong to no pillar, so `pillar_of_node` returns
`-1` for them and any code assuming a node↔pillar correspondence must tolerate that.

Clears ~10% of Norne's non-quad tail.

### Step C — 5-to-8-corner polygons · **M–L**, decide only after B

Two routes, and the choice needs the open question below answered first:

- **fan-split into quads** — geometrically exact, but `cell_faces` is `(Ncells, 6)`,
  one slot per direction, so a cell gaining a second face on one side has nowhere to
  put it;
- **reduce to the best-fit quad** — cheap and structure-preserving, but perturbs face
  geometry and therefore transmissibility. Only acceptable with a measured area-error
  bound.

### Step D — ragged variable-length faces · **XL**, probably unnecessary

Generalise `Faces.nodes` to offsets + flat node list (the MRST representation).
Touches `geometry`, `graph`, `mesh3d`, `planview`, `minimal_surface`,
`prescribed_fill`. **Only if A–C leave real decks failing.**

---

## 5. Open questions

1. **Does `cell_faces (Ncells, 6)` bound faces per cell?** A faulted cell can face
   several cells across the fault. If the array already cannot represent that, it is a
   pre-existing limitation and Step C changes shape entirely. *Blocks Step C only.*
2. **What are the 256 appended intersection nodes for?** Step B likely does not need
   them (a triangle uses only pillar corners); Step C certainly does.
3. **Does OPM accept a degenerate quad face** in a written deck, or only in memory?
4. **Is D3 still reachable after Step A?** The fault-aware path may already avoid the
   node-set collision, in which case D3 needs no separate fix.

Question 4 is cheap and should be answered immediately after Step A — it may remove a
whole defect from the list.

---

## 6. Bearing on the mesh-adaptation project

**None.** The morphing engine reads `COORD` directly and never calls `build_topology`.
The Norne benchmark ran end to end without it: 5,311 pillars, real `m_east` fault,
distance 14.48 → 7.52 m, zero folds.

These defects block only FAULTS regeneration and full topology validation on faulted
decks. They are a `cpg2python` correctness project, not mesh-adaptation work, and
should be scheduled as such.

---

## 7. Estimate revision history — why this study was worth doing

| stage | estimate | basis |
|-------|----------|-------|
| plan | L | "make build_topology survive welded corners" |
| first re-scope | XL | triangular polygons are an explicit v0.2.0 restriction |
| **after study** | **S + S**, then decide | the real blocker is a missing call, not missing geometry |

The XL estimate would have funded a ragged-face rewrite to fix a problem that a
one-line routing change plus a degenerate-quad convention very likely resolves — while
leaving the silent wrong-topology defect (D1) undiscovered.
