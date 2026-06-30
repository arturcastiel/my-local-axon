# CONFLICT-HUMAN-EDIT policy
> The precedence rule the git↔DAG reconciler (PR-004) obeys. Written BEFORE the reconciler, per decision-council D-007 (HALT-as-default, 4/5). The reconciler is READ-ONLY in v1 — this policy governs what it REPORTS and what a future repair (PR-008) may/​may not auto-resolve. It NEVER auto-resolves in v1.

## The four sources of truth
DAG (`03-prs/DAG.json`) · git (commits/branches) · meta/phases (`_meta.md`/`_phases.json`) · narrative docs. Drift = any two disagree.

## Precedence (HALT-as-default)
1. **DAG wins** on **non-git-derivable hand-authored fields** — `disposition`, `goal-id`, `kind:gate`, `source-id`, free-form notes. git cannot know these; the DAG is authoritative. The reconciler must NOT propose overwriting them.
2. **git wins** **ONLY** when **no node exists for a merged commit AND no hand-authored field is implicated** — i.e. pure code-first drift with nothing human to lose. Here git is the truth and the resolution is *propose adding a node* (scaffold only; still no auto-write in v1).
3. **flag-and-HALT is the explicit DEFAULT** for **every other / residual case** — partial overlap, an unrecognized field on an affected node, a `merged` node whose commit git can't confirm (phantom merge), or any ambiguity rules 1–2 do not unambiguously cover. HALT = surface the finding, exit non-zero, never auto-resolve.

## Per-node schema mismatch
Moot under D-018 (no `SCHEMA_VERSION` bump). Any residual mismatch the (now-absent) normalization did not reach falls through to the rule-3 HALT default — never silently resolved.

## v1 stance
The reconciler **detects and HALTs**; it has **no `--fix`** (D-006). In a read-only tool a HALT is just a surfaced flag + non-zero exit. Any future mutation (PR-008) must (a) honor this precedence, (b) snapshot before every write (already wired, PR-002), (c) have full branch test coverage of all three rules, behind a named go/no-go.
