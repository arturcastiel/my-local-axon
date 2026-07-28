# ADR-001 — PR-003 descoped: auto-recompile is infeasible; deliver diagnosability instead
date: 2026-07-13 · status: accepted (autonomous, within the plan-review amendments)

## Context
PR-003 (plan v2) was "auto-recompile mirrors ONLY (no auto-bless)". Two facts, verified:
1. The 8 compiled mirrors (menu, code-dev, …) are NOT deterministically generated from source —
   compilation is AGENT-ASSISTED (COMPILER.md Phase 4; compile_write.py takes agent-produced ops +
   token counts, not a pure source→mirror transform). So a pre-commit hook CANNOT deterministically
   recompile them.
2. Staleness is ALREADY gated: lossless-mandate (constraints, mechanical) + test_compile_write
   (test_compiled_not_stale + equivalence) both BLOCK on a stale mirror.
3. Auto-bless is a SECURITY HARD-STOP (risk seat): it defeats program_integrity's tamper-detection +
   doctrine_preflight's injection guard. Dropped.

## Decision
DESCOPE PR-003. The residual value is DIAGNOSABILITY: this session a stale menu mirror surfaced as
"14 unrelated doctrine tests failing" because doctrine_preflight's constraints check reports only
{ok:false} without WHICH constraint failed. Fix: surface the failing constraint id/detail so a stale
mirror is traceable to "lossless-mandate: <mirror> stale", not an opaque doctrine cascade. Safe
(read-only detail surfacing), addresses the actual pain, respects the two blocking facts above.

## Consequences
- No auto-recompile, no auto-bless. Staleness stays gated by the existing lossless-mandate + compile tests.
- PR-003 ships the diagnosability improvement to doctrine_preflight's constraints check + a test.
