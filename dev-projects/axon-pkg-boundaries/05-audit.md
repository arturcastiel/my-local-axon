# Phase 5 — Completion Audit · axon-pkg-boundaries (F21)

> Date 2026-05-30, main `9aae772`, gate 22/0. Method: re-check the goal against what's safe to ship,
> record the discovered blocker honestly, revise the study's confidence.

## Verdict
**Partial by design — the safe additive piece shipped; the conversion is correctly deferred.** tools/
is now an explicit regular package with a locked invariant. The headline goal ("kill the 49 sys.path
bootstraps") is **NOT done and should not be done in isolation** — it is structurally coupled to the
script-mode dispatch and would break production. Confidence in *this decision*: **9/10**. (The study's
original 8/10 *for doing the conversion* was wrong — corrected to "unsafe as scoped".)

## Goal coverage
- **"tools/ is a real package"** — ✅ explicit `__init__.py`, side-effect-free, invariant-locked.
- **"kill the 49 sys.path.insert"** — ⛔ DEFERRED. Blocked on a dispatcher migration script-mode →
  module-mode (`python3 -m tools.x`). 73 tools rely on flat sibling imports that only resolve with
  tools/ on sys.path (script mode). Empirically confirmed (`import tools.verify` fails today).
- **"enforced public surface"** — ◑ partial: the package exists, but the surface isn't enforced because
  submodules still import flat; enforcing it is part of the same deferred migration.

## The real follow-up project (scoped for whoever takes it)
"axon-dispatch-module-mode": (1) change run.py/axon.py/health.py/mcp_server.py to invoke tools via
`python3 -m tools.<x>`; (2) add a top-of-package bootstrap or rely on the install so `tools` is always
importable; (3) rewrite the 73 flat sibling imports to `from tools.X import Y` in dependency clusters,
gating each; (4) delete the 49 bootstraps + lint-test forbidding `sys.path.insert` in tools/. Each step
is gate-protected, but the **dispatcher change in step 1 has no behavioural test net** today — that net
(a script-vs-module invocation parity test) is its true PR-1.

## Honest note
This is a code-dev process working as intended: the study proposed an approach, execution proved it
unsafe against a load-bearing invariant ("nothing breaks"), so the audit ships the safe slice and
hands forward a correctly-scoped, de-risked follow-up rather than forcing the dangerous change.
