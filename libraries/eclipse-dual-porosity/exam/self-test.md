# Self-exam — Dual Porosity / Dual Permeability

> Close this file. Answer each question. Then open `self-test-answers.md` and compare.
> Rate confidence 1–5 per answer. Confidence below 3 → revisit the relevant note.

---

## Section 1 — Foundations (10 questions)

1. What two physical entities does the dual-porosity model represent, and which holds the bulk of the oil?
2. What is the *Z-doubling rule* and why does Eclipse enforce it?
3. In a DUALPORO run, which cells can wells be perforated in, and what is the exception?
4. Write the matrix-fracture transmissibility equation and identify each symbol.
5. State Kazemi's shape-factor formula and give the practical value (in FIELD units) for a 10-ft cubic matrix block.
6. What is the default unit of SIGMA, and what unit system does it depend on?
7. What does `NODPPM` do, and when must you use it?
8. What does PERMMF do, and in which simulator is it available?
9. How many porosities are present in the grid when GRAVDR is used vs when NMATRIX with VERTICAL geometry is used?
10. What is the fundamental difference between DUALPORO and DUALPERM in terms of cell connectivity?

## Section 2 — Recovery mechanisms (8 questions)

11. List the five recovery mechanisms by which oil leaves a matrix block in Eclipse.
12. Why does a fracture full of gas produce zero oil from the underlying matrix block, if no gravity-drainage model is active?
13. What is the keyword that enables molecular diffusion for matrix-fracture only (skipping fracture-fracture diffusion)?
14. What is the function of `DPKRMOD`, and is it physical or a tuning parameter?
15. What does the `INTPC` keyword modify, and when is it relevant?
16. Distinguish between *water imbibition* and *gravity drainage* — which one needs DZMTRX?
17. What is the Gilman-Kazemi viscous displacement mechanism, and which keyword activates it?
18. When you specify two SATNUM tables (matrix and fracture), what is the typical structural difference between them?

## Section 3 — Gravity drainage (8 questions)

19. Name the three gravity-drainage models in Eclipse and state when to use each.
20. What input keyword controls the strength of gravity drainage, and what is its default?
21. In GRAVDRM, what does "re-infiltration = YES" mean, and why is "NO" often safer?
22. How does Eclipse 300 use SIGMA vs SIGMAGD differently from Eclipse 100?
23. What is the role of OPTIONS item 11 in gravity-drainage runs at initial time?
24. In GRAVDRB (vertical discretized matrix), how do matrix sub-cells communicate?
25. What happens to gravity drainage if DZMTRX is left at default?
26. With GRAVDRM, what determines the upstream cell for an oil-phase flow?

## Section 4 — Discretized matrix / multi-porosity (8 questions)

27. What is the "Russian doll" model and what problem does it solve that classical DP cannot?
28. In Eclipse 100, what does NMATRIX = 6 do to the DIMENS NZ value?
29. In Eclipse 300, what does NMATRIX = 6 do to the DIMENS NZ value?
30. What is the function of NMATOPTS item 2 (outer-sub-cell size)?
31. Name the geometry options in NMATOPTS, including those exclusive to Eclipse 300.
32. List four restrictions on the discretized matrix model in Eclipse 100.
33. How is a sub-cell quantity reported in the SUMMARY section — show the syntax for oil saturation in sub-cell #7 of cell (1, 1, 2).
34. Why is the initialisation requirement (must use EQUIL) a consequence of the discretized matrix structure?

## Section 5 — Numerical implementation (6 questions)

35. Why is the DUALPORO Jacobian solve cheaper than DUALPERM's?
36. In the DUALPORO Schur-complement reduction, what is the key property of the matrix A that makes the reduction exact?
37. What does the OPTIONS item 60 switch do for DUALPERM, and when would you flip it?
38. Approximately how much slower is a DK run compared to an equivalent DP run on the same grid?
39. What is added to the Nested Factorization preconditioner when DUALPERM is active?
40. Why does the matrix-fracture coupling use the matrix bulk volume V (not pore volume) in TR = CDARCY·σ·K·V?

## Section 6 — Block-to-block and miscellaneous (6 questions)

41. What does the `BTOBALFA` keyword enable, and which physical situation does it model?
42. What is the restriction on BTOBALFA in multi-porosity runs?
43. What does DPNUM do, and is it compatible with DUALPERM?
44. What does the `LTOSIGMA` keyword override if it's used?
45. What is the role of `DPGRID`?
46. What is the difference between `KRNUMMF` and `DPKRMOD` item 3?

## Section 7 — Field-application judgment (6 questions)

47. You have a fractured carbonate with a strong gas cap. What minimum set of RUNSPEC/GRID keywords would you use?
48. You're matching the recovery vs time of a single-block lab experiment and the curve shape is wrong, but the endpoints match. Which knob do you reach for?
49. You receive a geocellular fracture-permeability map. How do you decide whether to use NODPPM?
50. You see a large initial fluid transient at t=0 in a gravity-drainage run. What two things would you check first?
51. You want matrix-matrix flow but cannot live with DK's 3× cost penalty. What is the partial alternative?
52. Your DPKRMOD parameter needs to be 0.9 to match recovery. Is this a red flag?

## Section 8 — Theory and literature triangulation (4 questions)

53. Whose paper does Eclipse's σ = 4·(1/lx²+1/ly²+1/lz²) come from? What did Warren & Root (1963) use instead?
54. What does Lim & Aziz (1995) suggest is the "correct" coefficient compared to Kazemi?
55. Which of the following is implemented in Eclipse: MINC (Pruess-Narasimhan), Subface (Penuela-style), or EDFM? More than one?
56. What is the conceptual difference between Eclipse's discretized matrix model and the original MINC?

---

## Scoring rubric
- 50+ correct → confident to deploy a DP/DK study under supervision
- 40–49 → strong working knowledge, will need to look up edge cases
- 30–39 → understand the basics, will produce technically valid but possibly sub-optimal models
- < 30 → revisit notes 01–08 and re-take

## Stretch — open-ended

A. **Build a minimal deck**: write the RUNSPEC, GRID, PROPS, REGIONS, SOLUTION, SCHEDULE skeleton for a 10×10×4 fractured-carbonate gas-cap study using DUALPORO + GRAVDR + DPKRMOD. Don't hard-code σ — use LTOSIGMA from LX/LY/LZ.

B. **Diagnose**: a colleague's DP simulation produces no production from the matrix. List the 6 things you'd check, in order.

C. **Explain to a junior**: write a one-paragraph explanation of why DUALPERM is needed for CBM with instant adsorption, but DUALPORO is enough for a classical naturally fractured carbonate.
