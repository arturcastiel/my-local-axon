# Implementation Log — axon-pkg-boundaries (F21)

> Goal: make tools/ a real package + kill the 49 sys.path.insert bootstraps. **During execution the
> plan's core (the import conversion) proved unsafe under the current dispatch model** — see below.
> Shipped the safe additive piece; deferred the conversion with the concrete technical blocker.

## Merged — 2026-05-30
| PR | MR | What |
|----|----|------|
| PR-1 | !90 | `tools/__init__.py` (docstring-only, side-effect-free) — realises pyproject's `packages=["tools"]` as an explicit regular package + `tests/test_tools_package.py` locking the invariant and the no-import contract. Gate 22/0. |

**main 9aae772.**

## Why PR-2/3/4 (the import conversion) were NOT executed — empirical finding
The plan was: convert `import X` → `from tools.X import Y` and delete the bootstraps. Verified on the
live tree that this **breaks the production invocation path**:
- AXON dispatches every tool as a **standalone script**: `run.py:36` / `axon.py` run
  `subprocess([sys.executable, "tools/<x>.py", ...])`. In script mode `sys.path[0]` is `tools/`, **not**
  the repo root — so `from tools.X import Y` (and relative `from .X`) raise `ModuleNotFoundError`.
- Proof: `python3 -c "import tools.verify"` already fails today with `No module named '_axon_paths'`,
  because **73 tools** do flat sibling imports (`from _axon_paths import …`) resolved only by the
  script-mode path. They are not importable as `tools.X` without tools/ also on sys.path.
- Converting them therefore requires **first migrating the dispatcher from script-mode to module-mode**
  (`python3 -m tools.x`) across run.py + axon.py + health.py + mcp_server.py + every caller, then
  rewriting all 73 flat imports. High blast radius, no program-execution test net → forcing it violates
  the owner's "nothing breaks." The study's 8/10 under-weighted this dispatch coupling.

## Bootstrap drift (noted, not fixed)
The 49 bootstraps use ~12 distinct spellings (`ROOT/"tools"`, `dirname(abspath(__file__))`, `HERE`,
`cwd`, …). Unifying them is churn with breakage risk for low benefit while script-mode stands; folded
into the deferred dispatch-migration project.

## UPDATE 2026-06-01 — bootstraps removed (F21 goal met without the risky conversion)
| PR | MR | What |
|----|----|------|
| net | !101 | script-mode import parity net — every ACTIVE tool imports with tools/ on path (closes F05 invocation-test gap) |
| remove | !102 | deleted **49 redundant** per-file `sys.path.insert` bootstraps; ruff-fixed the fallout; **kept 3 functional** inserts (crucible/dont_do_lint package imports need repo-root; _axon_lib dynamic loader); lint forbids re-introduction; parity net hardened to catch SyntaxError. Full suite 4028 green. |

**Outcome:** the headline goal (kill the bootstraps) is DONE. The planned module-mode conversion +
package-import rewrite proved UNNECESSARY — script-mode already puts tools/ on sys.path[0], so the
49 inserts were redundant. The 3 genuinely-functional inserts (package imports / dynamic load) stay.
Avoided the high-blast-radius dispatcher rewrite entirely. main 9c7029b.

**Landmines caught by the gate (why F21 was rated high-risk):** the editable install points at a
*different* checkout, so `from tools.rules ...` in crucible/dont_do_lint silently resolved there once
their repo-root insert was gone — caught by ruff's syntax check + the changeset-rules control + the
parity net (after hardening). Verify-don't-trust, again.
