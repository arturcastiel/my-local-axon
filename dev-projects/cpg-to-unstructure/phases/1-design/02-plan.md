# Plan — 1-design  ·  mode: tactical

> Grounded in `01-study.md` (Tier-A LOC dissection, parser spec, pipeline diagram).
> Target: lightweight Python port of MRST CPG → unstructured + graph.
> Dep budget: numpy hard-required, scipy.sparse optional via `[fast]` extra.

## Strategy

Build **bottom-up, vertical slice first**. PR-1 lands a tiny but
end-to-end smoke pipeline (toy 2×2×2 cartesian, no faults, no ACTNUM)
so every later PR has a working integration target. Then layer in
parser realism, fault handling (matching-Z), pinch-outs, properties,
graph, scipy fast path.

Each PR ends in green tests. No PR merges with red.

## Wave structure

| Wave | Theme | PRs |
|------|-------|----:|
| 1 | Skeleton + smoke | PR-1, PR-2 |
| 2 | Real parser | PR-3, PR-4 |
| 3 | Real CPG transform | PR-5, PR-6, PR-7 |
| 4 | Geometry + index map | PR-8, PR-9 |
| 5 | Graph layer | PR-10, PR-11 |
| 6 | Polish | PR-12, PR-13 |

13 PRs total. Mean PR size target: ≤ 200 LOC including tests.

## Out of scope (deferred to v2 phase)

- Non-matching-Z fault geometry (Tier B of `processGRDECL.m`)
- Property pass-through (PORO/PERM*) — PR-12 has the hook only
- Visualization
- Disconnected-grid splitting
- PINCH NNCs (explicit non-neighbour connections)
- `.EGRID` binary format

These will live in masterplan as future phases (`2-faults`, `2-properties`).

## Wave gates

- **End of Wave 1** → repo is `pip install`-able; CI green; toy round-trip works.
- **End of Wave 3** → Norne-style real `.grdecl` parses and produces graph.
- **End of Wave 5** → Dijkstra runs end-to-end on real grid with index-map round-trip.
- **End of Wave 6** → README, examples, `[fast]` extra working; v1 ready to use.

## See also
- 02-prs.md — PR list (numbered, with one-liners + acceptance bullets)
- 02-phases/ — empty (this is a tactical plan, no nested phases needed)
