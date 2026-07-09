---
tags: [code, file]
path: tools/proof_mms.py
---

# tools/proof_mms.py

> 34 symbol(s) · 1 outbound file dependency(ies)

## Symbols
- `1D advection-diffusion (transport) goal: u_t + c*u_x = alpha*u_xx + f. A reservo`
- `1D heat/diffusion goal: u_t = alpha*u_xx + f. Returns (spec_without_u*, hidden u`
- `A CORRECT Crank-Nicolson reference solver for this goal — the known-good test fi`
- `A default mixed goal set across all operators — the proof's breadth in one list.`
- `Assemble a leakage-safe goal spec + the hidden u_func from a manufactured u* and`
- `CORRECT Crank-Nicolson + CENTRAL-difference reference solver for advection-diffu`
- `Dispatch a goal id ('heat:0' / 'advdiff:1' / 0) to its manufacturer -> (spec, u_`
- `Grade every reference solver in the goal set (each MUST pass) — proves the gener`
- `Manufactured solutions for the advection-diffusion operator (transport). Same sm`
- `Manufactured-solution family (sympy exprs in x,t), indexed by seed. Each is smoo`
- `Run artifact's solve(N) in the sandbox; return (x, u) arrays or None on failure.`
- `Run the artifact at each N, compare to u*, fit convergence order. PASS/FAIL + de`
- `The known-good reference solver for a goal id (test fixture).`
- `True iff u* is TRIVIALLY recoverable from the forcing — i.e. f is a constant mul`
- `_advdiff_family()`
- `_build_goal()`
- `_family()`
- `_forcing_leaks_solution()`
- `_parse_goal_id()`
- `_run_solver()`
- `build_parser()`
- `cmd_manufacture()`
- `cmd_selftest()`
- `default_goal_ids()`
- `grade()`
- `main()`
- `manufacture()`
- `manufacture_advdiff_1d()`
- `manufacture_heat_1d()`
- `op:seed' -> (op, seed). A bare int/str (no colon) defaults to heat (back-compat)`
- `proof_mms.py`
- `reference_advdiff_solver_code()`
- `reference_heat_solver_code()`
- `reference_solver_code()`

## Depends on
- [[_unknown_]]
