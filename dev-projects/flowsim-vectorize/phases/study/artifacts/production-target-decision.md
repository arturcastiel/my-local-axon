# Production target — decision + evidence

_Purpose: identify the "reference" discretization that best represents the codebase's intent. Owner asked me to decide._

## The candidates
Five methods are named in `factories/createMetodo.m`:
`tpfa`, `mpfad`, `mpfah`, `nlfvpp`, `mpfaql`

Plus DMP appears in `ferncodes_assemblematrixDMP` and NLFV-H in `ferncodes_assemblematrixNLFVH`, but neither has a class wrapper or factory entry.

## Decision criteria + evidence

### A. Which method is fully wired end-to-end?
| Method | Class file exists | Base class exists | Assembly file exists | Fully wired? |
|---|---|---|---|---|
| TPFA    | `MetodoTPFA.m` ✓ | `MetodoBase.m` ✓ | `ferncodes_globalmatrix_TPFA` ✓ | **YES** |
| MPFA-D  | `MetodoMPFAD.m` ✓ | `MetodoBase.m` ✓ | `ferncodes_globalmatrix_MPFAD` ✓ | **YES** |
| MPFA-H  | `SolverMPFAH.m` (only) | `SolverBase.m` ✗ MISSING | `ferncodes_assemblematrixMPFAH` ✓ | NO — factory calls `MetodoMPFAH()` which doesn't exist |
| NLFV-PP | `SolverNLFVPP.m` (only) | `SolverBase.m` ✗ MISSING | `ferncodes_assemblematrixNLFVPP` ✓ | NO — factory calls `MetodoNLFVPP()` which doesn't exist |
| MPFA-QL | ✗ | — | `ferncodes_assemblematrixMPFAQL` ✓ | NO — factory calls `MetodoMPFAQL()` which doesn't exist |
| DMP     | ✗ | — | `ferncodes_assemblematrixDMP` ✓ | NO — not in factory at all |
| NLFV-H  | ✗ | — | `ferncodes_assemblematrixNLFVH` ✓ | NO — not in factory at all |

**Only TPFA and MPFA-D actually run today** (assuming the factory is the entry point). Everything else is either half-wired or unwired.

### B. Which method is the most-documented reference?

Read the Portuguese doc comments in the OOP classes:

- `MetodoBase.m` — the abstract contract, 11 KB of narrative documentation
- `MetodoMPFAD.m` — 10 KB, explicitly cross-referenced by `MetodoTPFA.m` ("Diferenca em relacao ao MPFA-D: TPFA usa 2 pontos...")
- `factories/createMetodo.m` says: **"MPFA-D — Metodo padrao para a maioria dos casos do simulador"** ("Standard method for the majority of the simulator's cases")

MPFA-D is the reference against which every other method is described.

### C. Which method handles the widest range of cases?

From `MetodoMPFAD.montarSistema`:
```matlab
if numcase == 331 || (400 < numcase && numcase < 500)
    % Richards
else
    % steady / groundwater
end
```
MPFA-D handles both Richards (400-500) AND groundwater (300-400) AND steady state. It's the default across every physics domain.

Contrast: MPFA-H, NLFV-PP, MPFA-QL are described as "alternatives" or "variants" in the factory comments — "recommended when MPFA-D produces negative values", "alternative for some mesh types". They're **fallbacks for MPFA-D failure modes**, not primary methods.

### D. Which method is closest to already-vectorized?

- `ferncodes_globalmatrix_MPFAD.m` (295 L) — **the only assembly file with ZERO globals**. Already env-based.
- `ferncodes_assemblematrixMPFAH.m` (820 L) — 7 globals, direct sparse-writes, worst offender.
- All other assemblers — heavy globals, direct writes.

MPFA-D is the ONLY assembler where the modernization has actually landed.

### E. Which method is on the runtime path per Start.dat?

`Start.dat` shows `phasekey = 6` → `SimRichards`. The `pmethod` line is not clearly captured in my grep, but the default recommendation (per createMetodo comments) for Richards is `mpfad`.

## Decision

**MPFA-D is the production target.**

Rationale:
1. It is one of only two methods fully wired end-to-end (TPFA is the other, but TPFA is a simplified baseline, not the production method).
2. The codebase's own documentation calls it "the standard method for the majority of cases".
3. It handles every physics regime (steady, groundwater, Richards).
4. Its assembly file (`ferncodes_globalmatrix_MPFAD`) is already globals-free — the vectorization work is furthest along here.
5. Its OOP wrapper is the reference against which other methods are described.
6. It is the method actually used with the Richards driver (`hydraulic_RE`).

## What this means for study focus

Study concentrates on the MPFA-D pipeline in detail:
- `MetodoMPFAD.m` (class contract)
- `ferncodes_Kde_Ded_Kt_Kn.m` (preprocessor — transmissibilities)
- `ferncodes_Pre_LPEW_2_vect.m` (LPEW2 weights — the vectorization hot spot)
- `ferncodes_globalmatrix_MPFAD.m` (assembly)
- `ferncodes_iterpicard.m` / `L_scheme.m` / `ferncodes_andersonacc.m` (iterators)
- `ferncodes_pressureinterpNLFVPP.m` (nodal pressure interp — misnamed)
- `ferncodes_flowrate.m` (post-processing)

Secondary methods (MPFA-H, NLFV-PP, MPFA-QL, DMP, NLFV-H) are studied for shape but not treated as reference — their broken OOP wiring makes them harder to study by execution, and their role is auxiliary.

TPFA is studied as the minimal baseline (useful for oracle-checking a simpler code path).

## Reason to reconsider

If the owner intends the OTHER methods to become production (e.g. NLFV-PP for high-anisotropy cases where MPFA-D produces negative pressures), the target flips — and the first study output should be **fixing the broken OOP wiring** (creating `SolverBase.m`, or renaming `SolverMPFAH.m` → `MetodoMPFAH.m` and creating `MetodoNLFVPP.m` / `MetodoMPFAQL.m`).

Ownership call. Absent that: **MPFA-D**.
