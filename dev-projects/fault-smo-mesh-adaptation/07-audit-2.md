# Audit 2 — corridor, benchmark, and what shipped

**Date:** 2026-07-28 · **Scope:** everything after `05-audit.md`.
**Method:** every claim below is checked against a measurement made in this session,
not against memory. Where a claim from audit 1 turned out to be wrong, it is listed
as wrong.

---

## 1. Delivered

| item | state | evidence |
|---|---|---|
| chain-continuity fix (`_consolidate` order, `_bridge_segments` last) | shipped | 13 breaks → 0 |
| `FaultCellMap` / `fault_cell_map` | shipped | 22 faces, 30 cells, chain continuous |
| endpoint-ordering fix in `segment_incidences` | shipped | 58 entries/48 pillars → 23 unique |
| `fault_projections/corridor.py` | shipped | 26 tests |
| `AdaptResult.corridor()` | shipped | checked on the RESULT, not the input |
| `_inside_or_on_rim` (stage-2 rim containment) | shipped | 2 → 9 pillars claimed |
| `benchmarks/` — 35 cases × 22 configs | shipped | 770 runs, 0 invalid, 0 errors |
| `benchmark.pdf` (83 pp) · `winner.pdf` (22 pp) | shipped | in `~/projects/results-faults` |
| `benchmarks/prototype_barrier.py` + research note | shipped | §4 below |
| `benchmarks/audit_results.py` — the data's own self-audit | shipped | 30 checks, 0 failures |
| cpg2python `distortion.py` + `polish.py` (**PR #40, merged**) | shipped | §4 |
| cpg2python #38, #39 | **merged** | CI green on all four checks |
| fault-projections #1 | **open, CI red** | §5 |

## 2. Defects found and fixed

| # | defect | how it was caught | evidence |
|---|---|---|---|
| 10 | `segment_incidences` appended BOTH endpoint claims to the tail, so the walk doubled back and `_connect` filled the backtrack with real pillars | writing a uniqueness test that failed | 58 chain entries for 48 distinct pillars; after: 23 unique, mean distance 19.0 → 4.95 m |
| 11 | `targets_from_polygon` tested containment on points lying exactly ON the polygon rim, where a crossing-number rule answers arbitrarily | building the stage-2 figure and finding 2 claimed pillars where 9 were expected | all 11 pillars at the identical in-plane `v = +156.205`; 3 kept, 8 dropped silently. Reproduced on a stashed clean tree — pre-existing |
| 12 | mypy 2.3.0 INTERNAL ERROR on `np.unique(..., axis=0, return_inverse=True)` tuple-unpack against CI's numpy stubs | CI on PR #39 | passes locally on the same mypy, older numpy; fixed by indexing the result |
| 13 | fault-projections CI clones a PRIVATE dependency anonymously | reading the CI log rather than assuming the failure was ours | runs on `main` from 2026-05-29 fail identically — predates this work entirely |

## 3. Where THIS session's own claims were wrong

Recorded because the corrections are the useful part.

- **The benchmark's fidelity metric was wrong for three full runs.** It scored on
  `MorphResult.residuals`, which is *normal-only* by design: the objective constrains
  the component along each target's approach direction and leaves the tangential
  position free, so a pillar sliding far ALONG the fault still reports a small
  residual. Measured on the kinked case: `lap_free` reported **0.63 m** while sitting
  **5.27 m** from the trace; `bnd_free` **0.68 m** while sitting **7.95 m** away.
  Free-boundary settings were flattered ~6×, `base` only ~1.7×. Fidelity is now the
  distance to the fault polyline, which cannot be gamed by sliding. Every
  configuration lost ~10 points of `closer_pct`, and the winner did not change *at
  that point*. It changed later, when the barrier polish was added — see §4.

- **The chain-continuity metric was wrong for one run.** It measured one walk across
  *concatenated* faults, so a model with three faults reported a break at every fault
  boundary. `y_junction` scored 0.03 on guarantee with fidelity at 0.93 — entirely an
  artefact. Now measured per fault: 0.405 → 0.729.

- **The face-alignment tolerance was stricter than the method's own default.** 1% of
  a cell, against a quality-leaning default that lands ~1 m from a 100 m cell's trace
  by design. Raised to 5% and given a continuous companion term, because a hard
  threshold cannot distinguish "almost aligned" from "nowhere near".

- **Audit 1 claimed the sacrificial band was worth having.** With the chain ordering
  fixed, elastic alone already gives 0 cells below SJ 0.3 on the 12×12 case, and the
  band moves non-orthogonality p95 by 24.7° vs 26.0°. The band was mitigating damage
  the ordering bug was causing.

- **The first two PDFs were rejected by the owner as unusable** — table-heavy,
  figures a third of a page. Rebuilt as a landscape picture atlas, two pages per
  case. The lesson is that "documented" and "legible" are different claims.

## 4. Research outcome — the objective was wrong, and is now fixed

`research-mesh-quality.md`, with a working prototype
(`benchmarks/prototype_barrier.py`, analytic gradient verified to 8.5e-08).

Replacing the quadratic smoothness with TMOP metric 002 —
`0.5|T|²/det(T) − 1` against **per-cell original-shape targets** — removes **every**
cell below SJ 0.3 on all four cases tested, at every weight tried, and takes the
worst scaled Jacobian from 5.2e-04 to 0.39–0.77. On `diagonal_45` it is a strict win:
29.97 → 16.32 m closer *and* no quality cost.

The reason is structural: a quadratic energy is finite for an inverted cell, so
nothing in the objective resists a fold. A barrier metric diverges as the cell
degenerates, so a line search that keeps the energy finite cannot produce one.

**Shipped as cpg2python PR #40** (`distortion.py`, `polish.py`, 35 tests) and then
measured at scale over all 770 runs. `lap_free_polish` is a strict improvement on the
previous benchmark winner, and it **took the title from it**:

| | `lap_free` | `lap_free_polish` |
|---|---:|---:|
| score | 0.822 | **0.860** |
| closer to the fault | 86.0% | **87.1%** |
| true distance | 4.82 m | **4.37 m** |
| new cells below SJ 0.3, all 35 cases | 148 | **3** |
| worst cell anywhere | 0.0000 | **0.2726** |

The polish is not a trade when the rim is free: it is better on every axis. The
barrier lets fidelity be pursued harder without the quality collapse that forced the
old defaults to be timid.

## 5. Outstanding — owner only

| item | owner | note |
|---|---|---|
| `CPG2PY_TOKEN` secret on fault-projections | **owner** | a PAT with `repo` scope. Until it exists, fp CI cannot install its private dependency and PR #1 cannot go green. Locally: 175 pass, ruff + mypy clean |
| merge fault-projections #1 | **owner** | blocked by the above, not by the code |
| rebind the autonomy gate | **owner** | `AXON_HUMAN_GRANT=1 python3 tools/autonomous_mode.py bind --project-dir my-axon/dev-projects/fault-smo-mesh-adaptation` |
| measure the polish on a field deck (Norne) | decision | shipped and measured on synthetics; no default changed |
| PR-013 Step A | decision | unchanged from audit 1 |

## 6. The defect found here — now closed

**`check_validity` does not catch degenerate cells.** Verified directly: on the
`zigzag` case it returns `ok=True, n_folded=0` while the mesh contains a cell at
scaled Jacobian **5.2e-04** and 14 cells below 0.3.

A cell can be flattened to zero area without its corners crossing. The gate tests
crossing. Closed in cpg2python PR #40: `check_validity(min_scaled_jacobian=...)`, **off by
default** because switching it on changes what "valid" means for decks that pass
today. The barrier polish removes the cells that would trip it: across all runs the
total of new cells below SJ 0.3 falls from 147 (`base`) to 1 (`polish`), and to 0
with the area barrier as well.

## 7. Verdict

The feature works and is now measured rather than asserted: 770 runs across 35 fault
geometries and 4 grid types, no invalid grid, with three structural guarantees
(chain continuity, face alignment, cell corridor) checked on every applicable run,
and the dataset itself audited by 30 invariant checks (`benchmarks/audit_results.py`)
that pass with no failures.

Two honest caveats. The benchmark's own fidelity metric was wrong until this session
and flattered the winning configuration sixfold — the ranking survived the fix, but
the numbers in any earlier artefact do not. And the smoothing objective itself is the
wrong shape for the job: §4 measures a replacement that is better on quality in every
case tried, which means the shipped operator is a working first version, not the
right answer.
