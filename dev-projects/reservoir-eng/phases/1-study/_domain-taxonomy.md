# Domain taxonomy — reservoir engineering (study layer 1-3)

Source: Claude-for-reservoir-engineering (9 modules) + pyResToolbox v3.4.0 +
pyrestoolbox-mcp (108 tools) + canonical RE workflow knowledge (web research
2026-05-23).

## Layer 1 — calculation families (the atoms)
| Family | pyResToolbox module | MCP tools (count) | Method discriminators |
|--------|---------------------|-------------------|------------------------|
| Oil PVT | `oil` | 19 | pb/Rs: STAN·VALMC·VELAR · Bo: MCAIN·STAN · visc: BR |
| Gas PVT | `gas` | 15 | Z: DAK·HY·WYW·BUR · crit: PMC·SUT·BUR·BNS |
| Inflow (IPR) | `gas`/`oil` | 4 | radial/linear; sandface pressure = `psd` |
| Nodal/VLP | `nodal` | 6 | VLP: HB·WG·GRAY·BB |
| DCA | `dca` | 9 | Arps(b)·Duong·ratio models |
| Material balance | `matbal` | 2 | gas P/Z · oil Havlena-Odeh + drive indices |
| Simtools/relperm | `simtools` | 11 | tables SWOF·SGOF·SGWFN · families COR·LET·JER · Rachford-Rice flash |
| Brine/CO2 | `brine` | 3 | brine props · CO2 solubility · Soreide-Whitson VLE |
| Geomechanics | (mcp only) | 27 | stress/pore-pressure/frac-gradient/sand/fault — OUT of course scope, present in MCP |
| Layer/heterogeneity | `layer` | 5 | Lorenz↔beta · k-distribution |
| Recommend | `recommend` | 4 | auto method selection from fluid/API/deviation |
| Sensitivity | `sensitivity` | 2 | parameter_sweep · tornado |
| Library/EOS | `library` | 1 | component crit props · PR79/PR77/SRK/RK |

## Layer 2 — the course's 9 teaching tasks → which families
1. water-cut trend (hand-rolled; pandas)        → production diagnostics
2. API↔SG + pressure unit conv (hand-rolled)    → unit discipline
3. exponential decline + EUR (hand-rolled)      → DCA (subset)
4. CLAUDE.md domain memory                       → standards/policy
5. reservoir-engineering skill                   → ALL families (guidance)
6. reservoir-reviewer subagent                   → review gate (units/correlation/tests)
7. production CSV QA (shell+python)              → data QA
8. MCP pyResToolbox live calc                    → all families via MCP
9. parallel fan-out sensitivity                  → sensitivity + any family

Note: modules 1-3 HAND-ROLL math (teaching); modules 5/8/9 DEFER to
pyResToolbox/MCP (production discipline). The lesson is "prefer proven
tools over invented formulas" — directly relevant to AXON program design.

## Layer 3 — canonical end-to-end workflows (the decisions)
| WF | Pipeline | Input | Decision it supports |
|----|----------|-------|----------------------|
| W1 Screening | production QA → DCA fit → forecast → EUR | rate-time history, econ limit | reserves, abandonment, well ranking |
| W2 PVT→sim | recommend → oil/gas PVT → harmonize → black-oil table | API, GOR, SG, T, P, composition | fluid model for sim/MB/nodal |
| W3 Matbal | P/Z or Havlena-Odeh straight-line + aquifer | pressure history, cum production | OOIP/OGIP, drive mechanism |
| W4 Nodal | IPR + VLP → operating point | reservoir P, PI, geometry, THP | deliverability, lift, VFP tables |
| W5 Rel-perm | fit Corey/LET/Jerauld → SWOF/SGOF | core kr data or endpoints | saturation tables for sim |
| W6 Flash | Rachford-Rice + component props | feed composition, K-values | phase behavior |
| W7 Heterogeneity | Lorenz/beta → layer k-distribution | k profile or target | layering scheme |
| W8 Sensitivity | base case → sweep → tornado (fan-out) | base + param ranges | dominant uncertainties |
| W9 Deck QA | validate deck + extract PRT problem cells | Eclipse/IX deck | simulation debugging |
| (W10 geomech) | pore-pressure/stress/frac/mud-window | logs, stress | wellbore stability (scope?) |

## Cross-cutting discipline (the course's real teaching)
Every calculation must carry: **inputs+units · method/correlation · result ·
sanity check · applicability/assumptions · field-vs-metric · screening-vs-decision**.
Param pitfalls: oil uses `sg_g`, gas uses `sg`; inflow uses `psd` not `pwf`;
gas Z uses `zmethod`; rel-perm types SWOF/SGOF/SGWFN. This discipline IS the
spec for the AXON output-standard + domain gate (see _new-programs.md).
