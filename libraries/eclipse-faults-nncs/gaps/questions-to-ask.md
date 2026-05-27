# Questions to ask — ranked

## TOP PRIORITY — direct practical impact

### Q1. MULTFLT calibration practice
"For a fault you're history-matching, how do you decide between MULTFLT = 0.001 (strongly sealing), 0.01 (sealing), 0.1 (leaky), and 0.5 (open)? Do you use fault-seal analysis (SGR/Allan) as a prior, then refine, or do you fit blindly?"

### Q2. Detecting bad-NNC inputs
"What's the first thing you check when production rates from a faulted model don't match? Multipliers? NNC list? RPTGRID outputs?"

### Q3. DUALPORO vs DUALPERM with faulted grids
"When you have a fractured carbonate with major sealing faults, do you typically run DUALPORO or DUALPERM? When does the cost of DK justify itself for fault studies?"

### Q4. NEWTRAN vs OLDTRAN reliability
"Have you ever seen NEWTRAN produce wrong NNCs from a Petrel-exported grid? Any specific Petrel settings to avoid?"

### Q5. Sealing fault with MULTFLT vs MINPV trick
"For a 'truly sealing' fault, do you use MULTFLT = 1e-6 (just above the drop threshold), or do you set MINPV to deactivate the fault-zone cells, or both?"

## SECOND PRIORITY — workflow

### Q6. MULTFLT in SCHEDULE for dynamic faults
"Have you ever needed MULTFLT in SCHEDULE for a real reservoir (pressure-induced fault re-activation)? How did you decide when to fire it?"

### Q7. MULTREGT vs MULTFLT in practice
"Do you ever use MULTREGT instead of MULTFLT for fault-like barriers, or do you always use named faults? Pros/cons in your experience?"

### Q8. Bypass channels via NNC keyword
"Have you used the NNC keyword to model a karst conduit or fault-zone damage zone? How did you estimate the Tx value?"

### Q9. EDITNNC outliers
"In a history match, how often do you reach for individual EDITNNC tweaks vs adjusting MULTFLT globally? At what point would you say 'the geological model is wrong, stop tweaking NNCs'?"

### Q10. Debugging silent NNC drops
"When EDITNNC silently doesn't work because of inlining, what's your usual debugging path?"

## THIRD PRIORITY — deeper

### Q11. Fault capillary trapping for CO2 storage
"For CO2 storage, the *seal* is governed by capillary entry pressure, not just Tx. Have you handled this in Eclipse — KRNUMMF in a fault-zone region, or other approaches?"

### Q12. Tx threshold interpretation
"The 1e-6 NNC drop threshold — is it unit-aware? How do you handle very small but physical Tx values in METRIC units (where they're naturally smaller)?"

### Q13. HALFTRAN in production decks
"Have you ever used HALFTRAN in a real field deck? Most workflows seem to rely on standard upscaled PERMX/Y/Z."

### Q14. Aquifer NNCs (AQUNUM, AQUCON)
"For numerical aquifers connecting to faulted reservoirs, do you treat aquifer NNCs differently? Use NOAQUNNC in MULTREGT?"

### Q15. Inter-LGR NNC editing
"EDITNNC can't reach NNCs inside an LGR. What's your workaround when you need to edit a cross-LGR connection?"

## FOURTH PRIORITY — research / curiosity

### Q16. Geomechanics-coupled fault Tx
"For pressure-depletion induced fault re-activation, do you use VISAGE/MoRes coupling, or just empirically adjust MULTFLT in SCHEDULE?"

### Q17. Embedded discrete fracture networks (EDFM)
"Have you used Eclipse's CONDFRAC + SCFDIMS for large discrete fractures? How does it interact with FAULTS?"

### Q18. Multi-NUMRES region stitching
"Have you used NUMRES > 1 for combining regional and near-wellbore models? How are inter-region NNCs handled?"

### Q19. Streamline / dynamic NNC visualisation
"Are there post-processors that show real-time NNC flows as streamlines? Useful for diagnosing fault-leakage paths?"

### Q20. Future direction: fully unstructured grids
"Eclipse's NNC machinery is essentially a workaround for the Cartesian indexing constraint. Is there work toward fully unstructured grids that would make NNCs unnecessary?"

---

## Use note
Top 5 are show-stoppers for confident fault modelling. Q11-Q15 are deeper details only relevant to specific projects. Q16+ are research-grade curiosity. Capture answers in `gaps/answers.md` when you get them.
