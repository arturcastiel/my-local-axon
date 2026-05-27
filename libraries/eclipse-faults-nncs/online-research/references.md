# Literature foundations of Eclipse fault/NNC modelling

> Annotated references for the math and conventions Eclipse implements.

## Tier 1 — foundational

### Hearn, C.L. (1971). "Simulation of Stratified Waterflooding by Pseudo Relative Permeability Curves". JPT 23(7):805–813 (SPE-2929-PA).
**Context**: Pseudo-curves and effective transmissibilities for upscaling. The conceptual basis for treating fractured/heterogeneous reservoirs through effective transmissibility scaling.

### Coats, K.H., Dempsey, J.R., Henderson, J.H. (1971). "The Use of Vertical Equilibrium in Two-Dimensional Simulation of Three-Dimensional Reservoir Performance". SPEJ Mar 1971, 63–71 (SPE-2797-PA).
**Context**: VE assumption underlying many of the Eclipse transmissibility scaling choices and the way Z transmissibility is treated.

### Ponting, D.K. (1989). "Corner Point Geometry in Reservoir Simulation". 1st European Conference on the Mathematics of Oil Recovery, Cambridge.
**Context**: The original derivation and justification of corner-point geometry as implemented in Eclipse. Defines the COORD/ZCORN convention and the NEWTRAN-style transmissibility calculation. Eclipse's NEWTRAN traces back to this paper.

### Coats, K.H. (1989) — and many subsequent SPE papers
**Context**: Compositional and implicit simulator framework that became the basis for E300. Includes treatment of NNCs in the Newton-Raphson loop.

---

## Tier 2 — fault-specific literature

### Knipe, R.J. (1992). "Faulting processes and fault seal". Norwegian Petroleum Society Special Publication 1, 325–342.
**Context**: Foundation of fault-seal analysis (SGR — Shale Gouge Ratio). Provides the physical basis for choosing MULTFLT values from geological fault attributes.

### Yielding, G., Freeman, B., Needham, D.T. (1997). "Quantitative fault seal prediction". AAPG Bulletin 81(6):897–917.
**Context**: SGR + Allan diagrams for predicting fault transmissibilities. Operational link between geological description and MULTFLT calibration.

### Manzocchi, T., Walsh, J.J., Nell, P., Yielding, G. (1999). "Fault transmissibility multipliers for flow simulation models". Petroleum Geoscience 5(1):53–63.
**Context**: Direct link between fault-seal analysis and reservoir simulator MULTFLT values. The reference for converting geological fault attributes (clay smear, juxtaposition) to numerical Tx multipliers.

### Fisher, Q.J., Jolley, S.J. (2007). "Treatment of faults in production simulation models". Geological Society Special Publications 292:219–233.
**Context**: Modern review of how faults are represented in commercial simulators including Eclipse. MULTFLT calibration in practice, history-match strategies.

---

## Tier 3 — NNC and grid technology

### Hægland, H., Assteerawatt, A., Dahle, H.K., Eigestad, G.T., Helmig, R. (2009). "Comparison of cell- and vertex-centered discretization methods for flow in a two-dimensional discrete-fracture network". Advances in Water Resources 32(12):1740–1755.
**Context**: Modern comparison of cell-centred (Eclipse-style) vs vertex-centred discretisations. Helps understand the trade-offs Eclipse made.

### Lim, K.T., Aziz, K. (1995). See also: dual-porosity literature in `eclipse-dual-porosity/online-research/`.

### Coats, K.H. (1989). "Implicit Compositional Simulation of Single-Porosity and Dual-Porosity Reservoirs". SPE Symposium on Reservoir Simulation, SPE-18427-MS.
**Context**: Compositional DP/DK formulation; relevant for how DP NNCs integrate with the simulator architecture.

---

## Tier 4 — modern / EDFM context

### Lee, S.H., Lough, M.F., Jensen, C.L. (2001). "Hierarchical modeling of flow in naturally fractured formations with multiple length scales". Water Resources Research 37(3):443–455.
**Context**: Multi-scale fracture modelling combining DP, EDFM, and discrete fractures. Conceptual framework for Eclipse's SCFDIMS/CONDFRAC.

### Karimi-Fard, M., Durlofsky, L.J., Aziz, K. (2004). "An efficient discrete-fracture model applicable for general-purpose reservoir simulators". SPE Journal 9(2):227–236.
**Context**: EDFM as an alternative to dual-porosity / corner-point fault representation. Not in Eclipse standard but conceptually adjacent.

### Moinfar, A., Varavei, A., Sepehrnoori, K., Johns, R.T. (2014). "Development of an Efficient Embedded Discrete Fracture Model for 3D Compositional Reservoir Simulation in Fractured Reservoirs". SPE Journal 19(2):289–303.
**Context**: 3D EDFM that explicitly meshes fractures, contrasting with Eclipse's DP/NNC philosophy.

---

## Lineage chart

```
1971: Hearn — pseudo-relative permeability / effective Tx
1971: Coats et al. — VE basis
1989: Ponting — corner-point geometry, NEWTRAN derivation              ← Eclipse NEWTRAN
1989: Coats — compositional DP/DK simulator architecture
1992-1999: Knipe, Yielding, Manzocchi — fault-seal analysis             ← MULTFLT priors
2001+: Lee, Karimi-Fard, Moinfar — EDFM / multi-scale fractures         (alternative paradigm)
```

Eclipse 2025.4 implements the 1989 generation as standard with all four modern tools (DP/DK, faults, NNCs, NMATRIX) coexisting. EDFM is the current research frontier.

---

## Practical reading priority

For a working reservoir engineer:
1. **Ponting 1989** — for the geometric basis of NEWTRAN/COORD/ZCORN
2. **Manzocchi et al. 1999** — for connecting fault-seal analysis to MULTFLT
3. **Fisher & Jolley 2007** — modern practitioner-oriented review
4. **Lee et al. 2001** — for context on where multi-scale fracture modelling is heading

For deep theory:
5. **Coats 1989 SPE-18427** — for the compositional Newton implementation
6. **Karimi-Fard et al. 2004** — EDFM as the alternative direction
