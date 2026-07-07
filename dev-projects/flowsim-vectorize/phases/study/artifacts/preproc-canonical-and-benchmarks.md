# Preprocessor canonical + benchmark inventory

## Preprocessor: 3 variants, 1 canonical

| File | Lines | Functions | Callers | Verdict |
|---|---:|---:|---|---|
| `preprocessor.m` | 3363 | 15 | none in `.m` | historical |
| `preprocessor2.m` | 3299 | 15 (same names) | none in `.m` | modernized-but-unused cleanup of `preprocessor.m` |
| `preprocessormod.m` | 1642 | 14 (different set) | `main.m:28 → preprocessormod(1)` | **canonical** — the only one wired to the runtime |

### Function overlap
- `preprocessor.m` ∩ `preprocessor2.m` = **15/15 identical function names**. Only body differences: header comment tweaks, dropped `midflowcompared/nltol/maxiter/acel` from `getdatafile`, added `nonlinparam = [nltol maxiter]`, removed a MUSCL block, adjusted MOOD labels, simplified producer-face selection.
- `preprocessormod.m` shares **11 names** with the pair but adds `build_directories` and `build_connectivities` (its distinctive contributions), and drops `preprocessor`, `calcnormals_polarsys`, `getsurnode`, `calcelemarea_polarsys`.

### What `preprocessormod` builds (per data-flow agent)
- `env.geometry.coord`     — lines 16–19
- `env.geometry.elem`      — 21–25
- `env.geometry.centelem`  — 27–33
- `env.geometry.elemarea`  — 35–38
- `env.geometry.bedge`     — 40–47
- `env.geometry.inedge`    — 40–47
- `env.geometry.normals`   — 48–51
- `env.geometry.nsurn1/2`  — 56–117 (CSR build)
- `env.geometry.esurn1/2`  — 56–117 (CSR build)

**So preprocessormod is the sole producer of the mesh globals.** Every other file consumes these — nothing else writes them. This is the atomic "make FS.mesh + FS.geom" operation.

## Benchmark class inventory (`Caso*.m` files)

`factories/createBenchmark.m` dispatches to these numcases:
```
1, 21.1, 34.6, 34.7, 35, 36,
241, 245, 247, 249, 250, 248,
330, 331, 332, 333, 334, 335, 336, 337, 338,
341, 341.1, 342, 343, 347,
431, 432, 433, 434, 435, 436, 437, 438, 439
```
That's **35 distinct numcases** the factory expects to have benchmark classes for.

### What actually exists on disk
| File | classdef line | Base class exists? |
|---|---|---|
| `benchmarks/Caso1.m` | `classdef Caso1 < BenchmarkBase` | ✗ `BenchmarkBase.m` NOT FOUND |
| `benchmarks/Caso439.m` | `classdef Caso439 < SimulacaoBase` | ✓ `base/SimulacaoBase.m` |

**Only 2 of the 35 referenced Caso classes exist on disk.**

Even the 2 that exist have divergent base classes:
- `Caso1` inherits from `BenchmarkBase` — a **third class hierarchy** never defined in the repo
- `Caso439` inherits from `SimulacaoBase` — the correct base for the factory contract

`Caso1.m` is also **not referenced** by `createBenchmark` (it's in the file tree but the factory doesn't dispatch to `case 1`).

### Missing class files (33)
Every numcase the factory dispatches to, except 439, will raise `Undefined function or variable` at runtime:
```
21.1, 34.6, 34.7, 35, 36,
241, 245, 247, 249, 250, 248,
330, 331, 332, 333, 334, 335, 336, 337, 338,
341, 341.1, 342, 343, 347,
431, 432, 433, 434, 435, 436, 437, 438
```

### Interpretation
The OOP benchmark layer was **started for Caso439 only** and left as a template for the remaining 34. The factory is aspirational documentation of the intended structure. The actual runtime code path for those numcases still lives in the legacy `PLUG_*`, `benchmark.m`, `ferncodes_*` functions, dispatched by inline `numcase == N` branches rather than by OOP.

**Consequence**: any statement about "what the codebase does for numcase 341" needs to be read from the legacy branches, not from a `Caso341.m` (which doesn't exist).

## Three class hierarchies (only one alive)

| Base class | Referenced by | File exists? | Working subclasses |
|---|---|---|---|
| `MetodoBase` | `MetodoMPFAD`, `MetodoTPFA` | ✓ `solvers/MetodoBase.m` | 2 (MPFAD, TPFA) |
| `SolverBase` | `SolverMPFAH`, `SolverNLFVPP` | ✗ MISSING | 0 (broken) |
| `BenchmarkBase` | `Caso1` | ✗ MISSING | 0 (broken) |
| `SimulacaoBase` | `Caso439`, `SimRichards`, `SimGroundwater` | ✓ `base/SimulacaoBase.m` | 3 |

**Only `MetodoBase` and `SimulacaoBase` are alive.** The other two base classes exist only as references in derived-class `<` lines and would fail on class-file load.
