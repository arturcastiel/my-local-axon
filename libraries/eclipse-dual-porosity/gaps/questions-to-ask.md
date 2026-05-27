# Questions to ask — ranked

> If you put me in a room with a senior reservoir engineer who runs DP/DK studies,
> this is what I'd ask. Ranked by what would most increase the *useful* depth of
> understanding for actual model-building.

---

## TOP PRIORITY — direct practical impact

### Q1. Calibrating σ from history
"When you take Kazemi's σ = 4(1/lx²+1/ly²+1/lz²) as your starting point, how do you adjust it during history matching? Do you just multiply by a global factor with MULTSIG, or do you change the block dimensions L_x,y,z? Have you found a typical multiplier range?"

### Q2. Picking GRAVDR vs GRAVDRM in practice
"For a real field — say a fractured carbonate with a gas cap — how do you decide between GRAVDR and GRAVDRM? Do you always default to GRAVDRM if the rock has any wettability heterogeneity, or do you start with GRAVDR and switch only if there's a measurable mismatch?"

### Q3. The re-infiltration question
"In your experience with GRAVDRM, does re-infiltration = YES ever match field data, or do you always set NO? What signal in production data tells you re-infiltration is real?"

### Q4. DK vs DP — when do you take the cost hit?
"In a typical study, what fraction of cells need matrix-matrix connectivity to justify DUALPERM vs staying with DUALPORO and using DPNUM to mark partial-fracturing regions?"

### Q5. NMATRIX in practice
"For a tight matrix study — say shale or tight chalk — how many sub-cells do you typically use? Does the answer change for radial vs spherical geometry? Have you ever validated the answer against a fine-grid single-porosity reference?"

---

## SECOND PRIORITY — quantitative subtleties

### Q6. The Kazemi shape factor — alternative formulas
"Kazemi's factor of 4 differs from Warren-Root's π² (≈9.87) and Coats's 8 — when do you reach for one vs the other? Is the factor itself a tunable history-match parameter, or do you treat it as a physical constant once chosen?"

### Q7. DZMTRX vs simulation cell DZ
"Beginners conflate DZMTRX with simulation cell DZ. In your experience, what's the typical ratio DZmtrx / DZ_sim for a real fractured-carbonate study?"

### Q8. Fracture perm semantics — NODPPM choice
"When you receive an upscaled geomodel from a geocellular team, how do you determine whether the fracture permeabilities are 'raw' (so you need the φ multiplier) or 'effective' (so you need NODPPM)? Is there a convention in the industry, or do you have to ask explicitly?"

### Q9. DPKRMOD usage in real history matches
"DPKRMOD is described in the manual as a tuning parameter for matching a single-porosity fine-grid reference. In actual field cases (where there is no fine-grid reference), how do you use it? Does it just become 'another knob' to fit production?"

### Q10. Block-to-block (BTOBALFA) — when is it physically real?
"BTOBALFA activates the lower-matrix to upper-fracture connection when block sizes are comparable. Is this ever the actual physical situation, or is it more often used as a numerical correction to avoid artificial decoupling? How do you set the contact-area multiplier?"

---

## THIRD PRIORITY — process and tooling

### Q11. Diagnostics: how do you know your DP model is right?
"What outputs do you check after the first run? Per-cell sigma map? Initial matrix-fracture flow rates? Recovery vs single-porosity equivalent? Is there a checklist?"

### Q12. INTPC — is it on by default in your shop?
"For gravity-drainage studies, do you turn on INTPC routinely? What about with GRAVDRM (which now has its own pseudoization)?"

### Q13. Verification against literature benchmarks
"Is there a standard benchmark problem in the SPE community for DP simulators? Something like the Kazemi single-block problem or the SPE10 dual-porosity equivalent?"

### Q14. Coupling with EOR
"For miscible gas injection in a fractured reservoir, how do you handle diffusion (DIFFDP) vs viscous displacement (VISCD)? Is one enough, or do you turn both on?"

---

## FOURTH PRIORITY — deeper theory / curiosity

### Q15. Multi-porosity (>2) for triple-porosity systems
"When do you reach for TRPLPORO or NMATRIX>1? Is it ever needed for conventional reservoirs, or is it CBM/shale-specific?"

### Q16. Comparison with MINC formulation
"The 'Multiple Interacting Continua' (MINC) formulation of Pruess & Narasimhan (1985) is conceptually similar to NMATOPTS+VERTICAL but with different geometry. Is Eclipse's discretized matrix essentially MINC, or are there differences in the volume partitioning?"

### Q17. Numerical stability under DK
"With DUALPERM the linear solver loses its Schur-complement reduction. Are there cases where DK convergence is poor enough that you'd prefer DP + DPNUM as a workaround, even at the cost of physical fidelity?"

### Q18. Sub-cell quantities for production diagnostics
"BOSAT_n reports per-sub-cell saturations. Do you ever use these to diagnose matrix invasion fronts, or is it mostly an academic feature?"

### Q19. Volume sharing rules in multi-porosity
"In E300 multi-porosity, the rock volume is partitioned between porosities. ROCKSPLV overrides the default. When have you actually needed ROCKSPLV?"

### Q20. The pre-97A vs post-97A DK solver
"OPTIONS item 60 > 0 reverts to the pre-97A DK linear solver. Has anyone you know actually needed to flip this switch for robustness?"

---

## How to use this list
- Top 5 are study-stoppers — without good answers, can't build a credible model.
- 6-10 are quantitative confidence builders.
- 11-14 are workflow questions.
- 15-20 are deep-water — only matter for unusual cases.

When I get answers, I'll log them in `gaps/answers.md` with date and source.
