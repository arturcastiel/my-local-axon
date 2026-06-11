# PR-1 — workflow tool-contract sweep [crit C2]

Status: merged
Merged: MR !164 → main (squash) · crucible green 28 controls · workflow scope now BLOCK
Branch: general-bugfix/pr-1-workflow-contract → main
Depends-on: PR-0b (merged !160)
Phase: 3-prs
Covers: C2 (every workflow gate dead), the workflow half of the conformance baseline

## Goal
Restore all workflow gating. `predicate eval` emits `{"result": …}` but every consumer reads
`.value` — so acceptance/rejection/edge gates NEVER fire (adaptive-free-text has no working
termination). `synapse-suggest rank` emits a bare list of `{name, score}` but programs read
`.candidates[].rank/.synapse`. Both `--state` call-sites pass inline objects where the tool
takes a file path. Then promote the conformance lint to BLOCK for the workflow scope so this
class cannot ship again.

## Change
- `workflow-run.md`: `.value → .result` (preflight, reject-mid, rule.if, accept/reject);
  adaptive ranking reads `ranking[0].name/score`; sg-state WRITTEN to a working file and
  passed as a path.
- `workflow-simulate.md`: FOLDED into `workflow-run --dry` (reduce-surface) — becomes a thin
  delegating stub; the duplicated (and equally dead) predicate logic is deleted.
- `workflow-run.md` gains the dry mode: `W:dry ≡ true` → no synapse EXEC side-effects;
  predicts transitions exactly like the old simulate.
- `workflow-new.md`: ranking list shape (`{i}. {s.name} ({s.score})`, pick → `ranking[n-1].name`);
  author-state written to file for `--state`; APPEND→STORE where the draft state is rebuilt;
  validate error-count guard reads the real `validate-draft` output keys.
- `goal-audit.md`: drop the unsupported `todo --tag` flag (filter on bindings in-program);
  predicate reads → `.result`.
- `program_tool_conformance.py`: `--scope workflow|conversational|all` (globs tagged by
  family). Crucible: existing all-scope control stays WARN; NEW BLOCK control
  `program-tool-conformance-workflow` (`check --scope workflow`) — green at wire time
  because this PR fixes the workflow-family violations.
- Tests: scope filtering + the workflow-scope-clean invariant.

## Guarded-by
- `program-tool-conformance-workflow` (BLOCK) — the promotion this PR earns.
- Full crucible gate.

## Out of scope
Conversational/library call-site fixes (PR-2 path-vars repoint, PR-6 library --stdin).
