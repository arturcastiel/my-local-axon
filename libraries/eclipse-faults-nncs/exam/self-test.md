# Self-exam — Faults & NNCs

> 40 questions. Close this; answer; compare with `self-test-answers.md`.

## Section 1 — Geometry (8 questions)

1. Which two keywords together define corner-point geometry, and what does each store?
2. Where in the grid input is fault throw actually encoded — `FAULTS`, `MULTFLT`, `ZCORN`, or `COORD`?
3. What is the difference between OLDTRAN and NEWTRAN, and which is the default for COORD/ZCORN input?
4. Why is the combination NEWTRAN + DX/DY/DZ discouraged?
5. What is HALFTRAN and when would you use it?
6. What does the `NUMRES` keyword enable?
7. Pillars in `COORD` are stored as how many values per pillar? What do they represent?
8. What's the difference between a shale gap and a pinchout in terms of how Eclipse handles them?

## Section 2 — NNC mechanics (8 questions)

9. Name five mechanisms by which Eclipse generates NNCs.
10. From the solver's point of view, are NNCs different from regular face connections?
11. What is "NNC inlining" and when does Eclipse do it?
12. What is the minimum transmissibility below which an NNC is silently dropped?
13. Why is `MULTFLT 0` a bad choice for a sealing fault?
14. Can you EDITNNC a dual-porosity σ-NNC? If not, what do you use?
15. Can EDITNNC modify an NNC inside an LGR?
16. If you specify two NNC entries for the same cell pair, what happens?

## Section 3 — Transmissibility math (8 questions)

17. Write the NEWTRAN X-transmissibility formula and identify each term.
18. What is the dip correction `DIPC` and which formulas (OLDTRAN, NEWTRAN, OLDTRANR) include it?
19. Why doesn't the Z-direction transmissibility include RNTG?
20. Write the dual-porosity matrix-fracture transmissibility formula and contrast it with NEWTRAN.
21. If `MULTFLT = 0.001` is set on a fault and the underlying NEWTRAN Tx is 100, what is the final Tx?
22. What is the order of multiplier composition for a face Tx (MULTX, MULTFLT, MULTREGT, EDITNNC)?
23. For an NNC defined manually with `NNC` keyword, what items are required vs optional?
24. What does the `NNCGEN` keyword do differently from `NNC`?

## Section 4 — Workflow (8 questions)

25. Write a minimal sealing-fault recipe: keywords and a typical multiplier value.
26. For a fault in a `DUALPERM` model with `NDIVIZ = 8`, what K-range should the FAULTS record cover?
27. Wildcards in MULTFLT — show an example of applying one multiplier to a family of named faults.
28. Where can MULTFLT appear (which sections), and what is the difference in behaviour between GRID, EDIT, and SCHEDULE?
29. When would you use MULTREGT instead of MULTFLT?
30. How do you re-activate a fault dynamically at simulation time T = 500 days?
31. Suppose you want to model a karst conduit between two cells. Which keyword do you use?
32. The same NNC is multiplied by MULTFLT, then EDITNNC in EDIT, then EDITNNCR in EDIT. What is the final Tx (E300 ordering)?

## Section 5 — Debugging (8 questions)

33. What `RPTGRID` mnemonics would you set on a debug run to inspect NNCs?
34. Where do you grep the .PRT file to find the NNC count?
35. What does the "IN-LINE CELLS" section of the .PRT mean?
36. EDITNNC is being silently ignored — name three possible causes.
37. Your sealing fault isn't sealing in a DUALPERM model. What's the first thing to check?
38. The NNC count in the PRT is much higher than expected for your model. What's a common cause?
39. How do you verify that MULTFLT actually applied during a run?
40. What tool / output mnemonic shows inter-cell flows for diagnosing leak paths?

## Stretch — open-ended

A. **Build a deck**: 30×30×10 corner-point reservoir with:
   - A sealing fault along I=15, full K range
   - A leaky fault along J=20 with MULTFLT=0.2
   - A bypass NNC at (5,5,5)↔(7,5,5) with Tx=1500
   - One EDITNNC tweak

B. **Diagnose**: A colleague's DUALPERM model has a "sealing fault" but cross-fault production is identical on both sides. List the 6 things you would check, in order.

C. **Explain**: Why is `EDITNNC` not allowed on DP σ-NNCs, and what is the alternative?
