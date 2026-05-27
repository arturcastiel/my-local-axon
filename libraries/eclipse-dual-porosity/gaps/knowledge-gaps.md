# Knowledge gaps and unverified assumptions

> Format: each entry has a **claim** (what I currently believe), a **source** (where in the manual or elsewhere),
> a **confidence** (0–100%), and an **open question** to resolve.
> This is the honest map of where the study is solid vs hand-wavy.

---

## A. Foundational math — Kazemi's σ formula

### A1. Why the factor of 4 in σ = 4(1/lx² + 1/ly² + 1/lz²)?
- **Claim**: 4 comes from 1D analytical pressure-diffusion solution of a slab; for three-direction superposition Kazemi extended it heuristically.
- **Source**: TD cites Kazemi (1976) directly; no derivation given.
- **Confidence**: 60% — I know the constant has a 1D origin but I cannot show the derivation step-by-step.
- **Open question**: What is the exact analytical derivation? How do Warren-Root's π² and Coats's 8 compare to Kazemi's 4 in terms of underlying assumptions?

### A2. Is the shape factor truly an intensive property?
- **Claim**: σ depends on the matrix-block geometry, not on the simulation cell size.
- **Source**: TD p.100 — "lx, ly, lz are thus not related to the simulation grid dimensions".
- **Confidence**: 90%.
- **Open question**: But the transmissibility TR = σ · K · V multiplies by V = simulation cell bulk volume. So the *coupling* per simulation cell does scale with cell size. Is this geometrically consistent — i.e. does doubling the simulation cell give twice the matrix-fracture transfer for the same physical block size? Test mentally: a bigger cell contains *more* matrix blocks, each contributing the same intensive flux, so total Tx scales with V. ✓ Yes, this is correct. But verify with a simple test case.

### A3. What happens to σ near boundaries or in disconnected regions?
- **Claim**: σ is grid-block-local; no boundary correction.
- **Confidence**: 50%.
- **Open question**: Does Eclipse adjust σ for cells near pinch-outs or with low connectivity to active neighbours? Worth checking by running a 1-cell DP simulation.

---

## B. Quasi-steady-state assumption

### B1. When does the QSS assumption fail?
- **Claim**: Standard DP assumes matrix-fracture flow is in quasi-steady state — i.e. the time constant for matrix internal flow is much smaller than the simulation time step.
- **Source**: TD p.125 — discretized matrix justified by transient effects "for example a well test".
- **Confidence**: 80%.
- **Open questions**:
  - What's the rule of thumb for the matrix time constant τ_m vs simulation time step? Often quoted: τ_m ~ μφ/(k·σ). If τ_m > Δt, QSS fails and you should discretize.
  - How does Eclipse handle adaptive timestepping in DP — does it shrink Δt to stay under QSS validity?

### B2. Does adding NMATRIX preserve material balance perfectly?
- **Claim**: Yes — the partitioning preserves volumes.
- **Source**: TD p.126-127 describes the partitioning.
- **Confidence**: 90%.
- **Open question**: But how does the sub-cell rock compaction (if ROCK keyword is used) propagate? Is each sub-cell compressed independently?

---

## C. Gravity drainage subtleties

### C1. The "re-infiltration trap" in GRAVDRM
- **Claim**: Allowing re-infiltration (YES) makes final recovery depend on transmissibility.
- **Source**: TD p.109.
- **Confidence**: 95%.
- **Open question**: When IS re-infiltration physically real? In the original Quandalle-Sabathier paper, do they explicitly enable or disable it?

### C2. How does Eclipse 300 interpolate SIGMA / SIGMAGD smoothly?
- **Claim**: Per-phase weighting `ωp = Δθgd / (Δθgd + ΔΦij)` per Eq. 2.61.
- **Source**: TD Eqs. 2.60–2.67.
- **Confidence**: 80%.
- **Open questions**:
  - Δθgd has phase-specific definitions (Eqs. 2.63–2.65) — they are tied to vertical equilibrium. What if the cell is NOT in VE locally?
  - How is this interpolation numerically stable? If Δθgd is small and oscillating, does ωp oscillate too?

### C3. INTPC with GRAVDRM — what changed in 2007.1?
- **Claim**: A new pseudoisation specific to GRAVDRM was added; previously INTPC+GRAVDRM was discouraged.
- **Source**: TD comment on INTPC, p.1190 of Ref Manual.
- **Confidence**: 70%.
- **Open question**: What is the new pseudoisation algorithm exactly? OPTIONS item 107 (E100) / OPTIONS3 item 126 (E300) reverts to old behaviour — but what is the difference?

---

## D. Discretized matrix specifics

### D1. Outer sub-cell size — practical rule
- **Claim**: NMATOPTS item 2 = 0.05–0.1 is a sensible default.
- **Source**: Default is 0.1.
- **Confidence**: 50%.
- **Open question**: Is there a quantitative rule (e.g. outer cell must capture the first τ_diffusion period)?

### D2. Geometry choice (LINEAR vs RADIAL vs SPHERICAL)
- **Claim**: Geometry should match physical fracture-block geometry.
- **Source**: TD pp.125-127.
- **Confidence**: 70%.
- **Open questions**:
  - For a 3D matrix block bounded by fractures on all sides, is SPHERICAL really better than CUBIC?
  - Eclipse doesn't offer CUBIC. Why? Is the cubic limit too close to spherical to matter?
  - How sensitive is the recovery curve to geometry choice?

### D3. Why is the discretized matrix incompatible with DUALPERM, GRAVDR, LGRs?
- **Claim**: Restrictions listed in TD p.128.
- **Source**: TD.
- **Confidence**: 60% (I know the list but not the reasons).
- **Open question**: What is the technical reason for each restriction? E.g. GRAVDR uses pseudo-Pc on the matrix cell; the sub-cells don't have a single Pc to modify? VERTICAL is the workaround for gravity drainage with sub-cells — implies the issue is the gravity-head encoding, not the sub-cell itself.

---

## E. Wettability and saturation tables

### E1. Two SATNUM tables — matrix and fracture
- **Claim**: Standard practice is matrix table with full Pc and curved kr; fracture table with zero Pc and straight-line kr.
- **Source**: TD p.112, common practice; Ref Manual SATNUM example would show this.
- **Confidence**: 90%.
- **Open question**: Are there cases where fracture should have a non-zero Pc? Maybe in micro-fractures? At what scale does fracture-as-conduit break down?

### E2. KRNUMMF vs DPKRMOD item 3
- **Claim**: KRNUMMF gives full flexibility (separate table); DPKRMOD item 3 gives a quick scaling that approximates "fracture kr equals matrix max kr at displaced-phase residual".
- **Source**: Ref Manual DPKRMOD.
- **Confidence**: 80%.
- **Open question**: When is the DPKRMOD scaling sufficient vs requiring a full KRNUMMF table?

---

## F. Numerical and implementation

### F1. Nested Factorization with DK — 4-level nesting
- **Claim**: Adding DK extends the Nested Factorization preconditioner to 4 levels (matrix vs fracture is the innermost split).
- **Source**: TD Eq. 2.86.
- **Confidence**: 60%.
- **Open questions**:
  - What is the typical convergence rate degradation vs single-porosity?
  - How does it scale with grid size — is it still O(N) effective?

### F2. Schur complement for DP — exact or approximate?
- **Claim**: For DP, the matrix A is *exactly* diagonal, so the Schur complement reduction is exact, not approximate.
- **Source**: TD p.118 — "Because D·A^(-1)·C is diagonal it does not alter the banded structure of B."
- **Confidence**: 95%.
- **Open question**: What if NMATRIX is on (Russian doll)? Then A has tri-diagonal structure, not pure diagonal. The pre-conditioning still eliminates the tri-diagonals before solving fracture — so it's still exact?

### F3. Block-to-block transmissibility — how is it computed?
- **Claim**: Same as standard spatial transmissibility (TR = K·A/d in each direction), modified by BTOBALFA contact-area multiplier.
- **Source**: TD p.102.
- **Confidence**: 70%.
- **Open question**: BTOBALFA is just an area scaling — does the "depth difference" used in the spatial transmissibility account for the physical offset between matrix and fracture cells in the same cell location (which is zero by construction)? Is there a separate depth correction for BTOBALFA-type connections?

---

## G. NODPPM and fracture permeability semantics

### G1. Default fracture-permeability behaviour
- **Claim**: Without NODPPM, Eclipse multiplies fracture PERMX/Y/Z by φ_frac to give the *effective* fracture-network perm.
- **Source**: TD p.112 + Ref Manual NODPPM.
- **Confidence**: 95%.
- **Open question**: What is the intuition? It's because raw "intra-fracture" permeability is huge (e.g. 10⁵ md), but the fracture only occupies φ_f of the bulk volume, so the *effective* flow per unit cell is reduced. This implicit homogenization is convenient but if your input already represents the effective value, you must turn off the multiplication.

### G2. NODPPM impact on the matrix-fracture Tx (Eq. 2.54)
- **Claim**: The matrix-fracture Tx uses matrix permeability (PERMX or PERMMF), not fracture. So NODPPM does NOT affect Eq. 2.54.
- **Source**: Implied by TD p.100 — "K is taken as the X-direction permeability of the matrix blocks".
- **Confidence**: 90%.
- **Open question**: Confirm by reading more carefully — is there any way fracture perm enters the M-F coupling?

---

## H. Initialisation and equilibrium

### H1. EQUIL is required when NMATRIX is on
- **Claim**: Yes; explicit initialisation cannot reach sub-matrix cells.
- **Source**: Ref Manual NMATRIX.
- **Confidence**: 95%.
- **Open question**: For non-NMATRIX runs, can you use explicit init (PRESSURE, SWAT, etc.) for both matrix and fracture? Yes — but matrix and fracture might be specified separately?

### H2. Gravity drainage at t=0
- **Claim**: Initial solution does not account for gravity-drainage forces; if they are large at t=0, a fluid redistribution transient appears.
- **Source**: TD p.106.
- **Confidence**: 90%.
- **Workaround**: OPTIONS item 11 → makes initial solution a true steady state including gravity drainage.
- **Open question**: How significant is the typical t=0 transient? Worth measuring on a synthetic case.

---

## I. Software-engineering questions

### I1. How does Eclipse 100 vs 300 differ in DP implementation philosophy?
- **Claim**: E100 has a single legacy "discretized matrix" code path; E300 has unified multi-porosity for >2 porosities; their handling of SIGMAGD also differs.
- **Confidence**: 60%.
- **Open question**: What are the historical reasons? Probably E300's Newton/AD framework can handle the more general multi-porosity case more naturally than E100's IMPES/streamline-influenced solver.

### I2. What is the actual cost penalty of DK vs DP?
- **Claim**: 2–4× wallclock penalty.
- **Confidence**: 40% (cited in folklore but not verified by me).
- **Open question**: How does the penalty scale with problem size? Run a benchmark.

---

## Summary — confidence band on the whole library

| Topic | Confidence |
|-------|-----------|
| Core math (Eq. 2.54, σ definition) | 90% |
| Recovery mechanisms (what & why) | 85% |
| Keyword syntax | 95% (verbatim from Ref Manual) |
| Section assignments | 95% |
| GRAVDR vs GRAVDRM choice | 70% (theoretical understanding solid; practical "when" judgment requires field experience) |
| Discretized matrix / multi-porosity | 65% |
| DP vs DK trade-off | 80% |
| Numerical solver internals | 50% |
| Edge cases and gotchas | 60% (covered the documented ones; field experience would surface more) |

**Overall**: ~75%. To get to 90%+, I'd need to:
1. Run a half-dozen sensitivity simulations on a synthetic DP/DK model (effect of σ, DZMTRX, NMATRIX)
2. Read Warren & Root 1963, Kazemi 1976, Quandalle-Sabathier 1989, Gilman-Kazemi 1988 in the original
3. Talk to someone who has done a real history-match of a fractured-reservoir field study
4. Read the source code (not available)
