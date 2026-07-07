# Module encapsulation study — what naturally clusters together

_Purpose: understand which functions form natural, self-contained units. Study only — no migration plan._

## Observation 1: the two OOP class families

The `solvers/` folder contains **two distinct, incompatible class families**:

### Family A — `MetodoBase` (working, env-based)
```
MetodoBase.m           (abstract base, 11 KB, well-documented)
  ├── MetodoMPFAD.m    (10 KB — env-based, calls ferncodes_globalmatrix_MPFAD)
  └── MetodoTPFA.m     (6 KB — env-based, calls ferncodes_globalmatrix_TPFA)
```

**Contract:** `preprocessar`, `atualizarPremethod`, `montarSistema`, `resolver`, `calcularFlowrate`, `calcGravidade`.

**Uses:** `env` struct throughout. Stores per-method precomputed data in `env.premethod.MPFAD.*` or `env.premethod.TPFA.*`.

### Family B — `SolverBase` (broken — base class missing)
```
SolverBase.m           (DOES NOT EXIST)
  ├── SolverMPFAH.m    (1.2 KB — classdef SolverMPFAH < SolverBase)
  └── SolverNLFVPP.m   (1.2 KB — classdef SolverNLFVPP < SolverBase)
```

**Contract (inferred):** `preprocessar`, `resolver`, `calcGravidade`.

**Fact:** `SolverBase.m` is not in `solvers/` (verified via `ls` and `find`). These two files reference a base class that does not exist in the tree. **The MPFA-H and NLFV-PP methods cannot be instantiated as written** — MATLAB would fail on the `<` inheritance line at class-file load.

### The factory contradicts both
```matlab
% factories/createMetodo.m
case 'mpfah',  metodo = MetodoMPFAH();     % ← file MetodoMPFAH.m doesn't exist
case 'nlfvpp', metodo = MetodoNLFVPP();    % ← file MetodoNLFVPP.m doesn't exist
case 'mpfaql', metodo = MetodoMPFAQL();    % ← file MetodoMPFAQL.m doesn't exist
```
Only `case 'tpfa'` and `case 'mpfad'` resolve to real class files. The factory is aspirational for the other three — it names classes that would need to be created for `pmethod ∈ {mpfah, nlfvpp, mpfaql}` to work.

**Interpretation:** the OOP wrapping was started for MPFA-D and TPFA (finished, working), and left incomplete for MPFA-H, NLFV-PP, MPFA-QL. The `SolverMPFAH.m` / `SolverNLFVPP.m` files are earlier scaffold attempts under a different base class that was then abandoned.

## Observation 2: functional module boundaries (as they exist today)

Looking at the actual function-to-function call structure, **six natural clusters** emerge. Each is a candidate module — a group of functions that share callers, share globals, and rarely reach outside the cluster.

### Cluster 1: MPFA-D pipeline
- **Class**: `MetodoMPFAD.m`
- **Preproc**: `ferncodes_elementface`, `ferncodes_Kde_Ded_Kt_Kn`
- **LPEW2 weights**: `ferncodes_Pre_LPEW_2_vect` (+ transitively: `OPT_Interp_LPEW`, `angulos_Interp_LPEW2`, `netas_Interp_LPEW`, `ferncodes_Ks_Interp_LPEW2`, `Lamdas_Weights_LPEW2`)
- **Assembly**: `ferncodes_globalmatrix_MPFAD` (Richards) OR `ferncodes_globalmatrix` (steady/groundwater)
- **Iterators**: `ferncodes_iterpicard`, `ferncodes_iterpicardANLFVPP2`, `L_scheme`
- **Post-proc**: `ferncodes_pressureinterpNLFVPP`, `ferncodes_flowrate`

**Encapsulation quality**: HIGH. This cluster has a single entry (`MetodoMPFAD.montarSistema` → `MetodoMPFAD.resolver`) and could be moved wholesale to a `+fs/+mpfad/` package with minimal cross-cluster reference.

**Interesting**: MPFA-D shares `ferncodes_pressureinterpNLFVPP` with the NLFVPP pipeline. This is a cross-cluster reference — the interpolator lives in the NLFVPP naming space but is used by MPFA-D. Not a bug, but a signal that "pressure interpolation" is really its own concept.

### Cluster 2: TPFA pipeline
- **Class**: `MetodoTPFA.m`
- **Preproc**: `ferncodes_Kde_Ded_Kt_Kn_TPFA` (TPFA variant of MPFA-D preproc)
- **No LPEW** (that's the point — TPFA doesn't interpolate at vertices)
- **Assembly**: `ferncodes_globalmatrix_TPFA` (Richards) OR `ferncodes_globalmatrix` (steady)
- **Iterators**: same as MPFA-D (Picard, AA, L-scheme)
- **Post-proc**: `ferncodes_flowrateTPFA`

**Encapsulation quality**: HIGH. Smallest cluster. Shares the iterator surface with MPFA-D.

### Cluster 3: MPFA-H pipeline (incomplete)
- **Class**: `SolverMPFAH.m` (orphan, missing base)
- **Preproc**: `ferncodes_elementfacempfaH`, `ferncodes_harmonicopoint`, `ferncodes_coefficientmpfaH`, `ferncodes_weightnlfvDMP`
- **Assembly**: `ferncodes_assemblematrixMPFAH` (820 L)
- **Solver wrapper**: `ferncodes_solverpressureMPFAH`
- **Post-proc**: `ferncodes_flowratelfvHP`, `ferncodes_pressureinterpHP`

**Encapsulation quality**: MEDIUM. Distinct preproc + assembly, but shares `ferncodes_weightnlfvDMP` with the DMP cluster.

### Cluster 4: NLFV-PP pipeline (incomplete)
- **Class**: `SolverNLFVPP.m` (orphan, missing base)
- **Preproc**: `ferncodes_elementface`, `ferncodes_Pre_LPEW_2_vect`, `ferncodes_coefficient`
- **Assembly**: `ferncodes_assemblematrixNLFVPP`
- **Solver wrapper**: `ferncodes_solverpressureNLFVPP`
- **Iterators**: `ferncodes_iterpicardANLFVPP`, `ferncodes_andersonacc2`, `L_scheme`
- **Post-proc**: `ferncodes_pressureinterpNLFVPP`, `ferncodes_flowrate`

**Encapsulation quality**: MEDIUM. Shares `ferncodes_Pre_LPEW_2_vect` with MPFA-D, shares iterators, shares post-proc.

### Cluster 5: DMP / MPFA-QL / NLFV-H cluster
- **Assembly**: `ferncodes_assemblematrixDMP`, `..._MPFAQL`, `..._NLFVH`
- **DMP helpers**: `ferncodes_auxassemblematrixinteriorDMP1`, `..._interiorDMP2`, `..._contourDMP`, `ferncodes_calfluxopartialDMP`
- **Weights**: `ferncodes_weightnlfvDMP` (shared)
- **Solver wrappers**: `ferncodes_solverpressureMPFAQL`, no class file for any of these

**Encapsulation quality**: LOW. Three assemblers with different math but shared helpers and no OOP wrapper. If MPFA-QL, NLFV-H, DMP are separate methods, each deserves its own module — but the current file layout mixes their helpers.

### Cluster 6: Shared substrate (used by every method)
- **Mesh preproc**: `preprocessor.m`, `preprocessor2.m`, `preprocessormod.m` (3 variants — see `preproc-unify` finding)
- **BC flag construction**: `ferncodes_calflag`, `ferncodes_calflag_con`
- **Common iterators**: `ferncodes_iterpicard`, `L_scheme`, `ferncodes_andersonacc`
- **Time step drivers**: `IMPES`, `IMPEC`, `IMHEC`, `hydraulic`, `hydraulic_RE`
- **Common post-proc**: `postprocessor`, `plotandwrite`, VTK writers
- **Config / plumbing**: `Start.dat` reader, `soil_properties`, `PLUG_*` functions

**Encapsulation quality**: N/A — this is the shared substrate every method sits on.

## Observation 3: what "maximally encapsulated" would mean

If each method were a truly self-contained module, it would own:
1. Its **class** (Metodo/Solver wrapper)
2. Its **preprocessor** (Kde/Ded, harmonic points, coefficients — whatever it needs)
3. Its **LPEW weights** (if applicable) OR the specific interpolation it uses
4. Its **assembly** (matrix builder)
5. Its **flow-rate calculator**
6. Its **pressure interpolator** (facewise / nodewise)
7. Its **iterator selection logic** (if it needs a special iterator)
8. Its **doc** (README explaining the method + parameters)

Nothing from method A would appear in method B. Common infrastructure (mesh, BC, time loop) lives one level up.

### The compromise
Some sharing is unavoidable:
- `ferncodes_Pre_LPEW_2_vect` is called by BOTH MPFA-D and NLFV-PP (both use LPEW2 weights).
- `ferncodes_weightnlfvDMP` is called by MPFA-H and DMP (both use the same DMP weights).
- Every method eventually calls the same Picard/AA/L-scheme iterators.

So "maximally encapsulated" in practice means:
- Each method owns its **unique** assembly, preproc, flow, pinterp code.
- **Shared kernels** (LPEW2, DMP weights, iterators) live in their own module and are called by name.

## Observation 4: what a self-contained module looks like

Using **MetodoMPFAD** as the reference (the cleanest one):

```
+fs/+mpfad/               (a self-contained module — an "engine")
├── Metodo.m              (the class, ex-MetodoMPFAD.m)
├── preprocess.m          (ex-ferncodes_Kde_Ded_Kt_Kn)
├── elementFace.m         (ex-ferncodes_elementface — arguably shared, but MPFA-D-shaped)
├── build.m               (ex-ferncodes_globalmatrix_MPFAD — the assembler)
├── flowRate.m            (ex-ferncodes_flowrate)
├── pInterp.m             (ex-ferncodes_pressureinterpNLFVPP — misnamed, actually MPFA-D)
└── README.md             (Portuguese doc from MetodoMPFAD.m header, expanded)
```

**Public API surface**: only `Metodo.m` (the class). Every other file is internal to the module.

The shared kernels (LPEW2, iterators) sit adjacent:
```
+fs/+lpew/                (shared — used by MPFA-D and NLFV-PP)
+fs/+iter/                (shared — used by every method: Picard, AA, L-scheme)
+fs/+mesh/                (shared — used by every method)
```

**The module boundary test**: "if I delete `+fs/+mpfad/`, does everything else still work?"
- YES for MPFA-H, NLFVPP, MPFAQL (they don't depend on MPFA-D code)
- ambiguity for the shared `ferncodes_pressureinterpNLFVPP` — but it's misnamed; that function is actually an interpolator that MPFA-D happens to use. It belongs to `+fs/+lpew/` (or its own `+fs/+interp/`), not to either method.

## Observation 5: what breaks the encapsulation today

Concrete counter-examples where the current code entangles methods:

1. **`ferncodes_pressureinterpNLFVPP.m`** is called by BOTH `MetodoMPFAD.calcularFlowrate` AND the NLFV-PP pipeline. The name lies — it's a general nodal-pressure interpolator via LPEW weights.

2. **`ferncodes_iterpicardANLFVPP2`** is called by `MetodoMPFAD` (case `'AA'`) and by NLFV-PP paths. The Anderson-acceleration wrapper is method-agnostic despite its name.

3. **`ferncodes_Pre_LPEW_2_vect`** is shared by MPFA-D and NLFV-PP (both need LPEW2 weights).

4. **`ferncodes_weightnlfvDMP`** is shared by MPFA-H (via `SolverMPFAH.preprocessar`) and by DMP assembly.

5. **`ferncodes_globalmatrix`** (no method suffix) handles steady/groundwater cases for both MPFA-D and TPFA. Method-agnostic driver.

Naming discipline broke: functions with `NLFVPP` or `MPFAD` in their name are actually cross-method shared kernels. Renaming them by role (`nodalPressureInterp`, `andersonAccel`, `lpew2Weights`, `dmpWeights`) would reveal their true home.

## Observation 6: LPEW2 is a shared substrate, not a per-method concern

Six methods can be defined in this codebase:
| Method | Uses LPEW2? |
|---|---|
| TPFA   | NO |
| MPFA-D | YES (via `Pre_LPEW_2_vect`) |
| MPFA-H | NO (uses harmonic points instead) |
| NLFV-PP | YES |
| MPFA-QL | Partial — uses `w, s` (LPEW output) as input to `assemblematrixMPFAQL` |
| DMP     | NO (uses `weightnlfvDMP`) |

So LPEW2 is a **shared kernel** used by 2-3 of the 6 methods. It has its own natural module boundary independent of any single method.

## Summary

- **Two class families exist**; only one is complete (MetodoBase → MPFA-D + TPFA). The other (SolverBase → MPFA-H, NLFV-PP) is orphaned by a missing base class.
- **Six functional clusters** map naturally to modules; three of the six are only half-realised as OOP classes.
- **Shared kernels** (LPEW2 weights, DMP weights, Picard/AA/L-scheme iterators, nodal pressure interpolators) currently live under method-specific names, which obscures their true cross-cutting role.
- **Encapsulation is broken today by naming, not by structure.** The structure (function-to-function calls) is already close to modular; the labels lie about where a function belongs.
