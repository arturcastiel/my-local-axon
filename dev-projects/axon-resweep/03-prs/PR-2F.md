# PR-2F — make the dead auto-compile pipeline honest (F-COMPILE + F-CMPSTALE)

- **Status:** merged (!140, 2ca670b)
- **Phase:** 2-reaudit-fixes  ·  **Complexity:** M  ·  **dev-mode:** no (tools/ + workspace/programs/ + tests/)  ·  **Depends on:** none
- **Decision:** owner chose **"make it honest"** (bounded) over full-revive / defer.
- **Source:** re-MEGA F-COMPILE + F-CMPSTALE. git history: `compile-write.py` NEVER had `--program` (the pipeline
  was born broken, not regressed). `COMPILER.md`: compilation is COGNITIVE (the agent maps NL→symbolic ops;
  compile-write only PERSISTS them) → a pure tool can't auto-compile.

## Fix (bounded — stop the silent failures; do NOT build full auto-compilation)
- **compile_suggest.py** — the `suggest --auto` loop and the `compile --program` action both called
  `compile-write.py --program {p}` (an interface compile-write never had → rc=2, compiled nothing, silently).
  Now: `suggest` returns candidates + `compiled_now=[]` + a note that compilation is cognitive; `compile`
  returns `{compiled: False, reason: "compilation is cognitive", next: …}`. No silent failure / pretend-register.
- **compile-optimizer.md** (the agent-run PROGRAM) — its loop called `compile format` with neither `--ops` nor
  the required `--src-tokens`/`--cmp-tokens` (→ exit 2). Now it does the COGNITIVE compile: READ source →
  `COMPILE(src)` per COMPILER.md → `TOKENS(ops)` → `compile format --ops --src-tokens --cmp-tokens`. Valid +
  honest (the agent produces the ops, as COMPILER.md intends).
- **F-CMPSTALE** — deleted the 3 stale compiled forms (workflow-run / workflow-new [old synapse-suggest];
  session-summary [old clock `--offset`, from PR-2D]) + nulled their `compiled` pointers in
  programs/REGISTRY.json. Dormant (no dispatch-index) + can't be auto-regenerated (cognitive); regenerated
  on-demand when next compiled.

## Adjacent findings noted (NOT fixed here — separate follow-ups)
- `auto_improve.action_auto_compile` (the real daily auto-compiler) calls compile-write CORRECTLY but with
  `--ops {src_text}` (source AS ops; src-tokens==cmp-tokens) → writes no-compression copies. Functional +
  honest (valid call) but doesn't compress — a quality follow-up (needs cognitive compression).
- `compile auto-compile` (unified compile.py) routes to a nonexistent compile_suggest `auto-compile` action
  ({suggest,compile,status} only) → invalid-choice. A separate dangling-subcommand follow-up.
- programs/REGISTRY.json `tools`-lists drifted from sources (prior PRs edited TOOL() calls w/o regenerating;
  mtimes volatile) — a periodic `programs-registry generate` resync; gate-untracked.

## Acceptance
1. Effect: `compile --program` honest (compiled False, cognitive); `suggest` no silent compile (compiled_now [], note). [test_reaudit_compile.py]
2. compile-optimizer.md uses the cognitive compile (`COMPILE` + `--ops` + token counts).
3. 3 stale .cmp.md deleted + pointers null; `programs-registry check` green.
4. `crucible gate` passed:true.

## Changes
- `tools/compile_suggest.py` · `workspace/programs/compile-optimizer.md` · `workspace/programs/REGISTRY.json`
  (3 pointers → null) · DELETED `workspace/programs/compiled/`{workflow-run, workflow-new, session-summary}`.cmp.md` ·
  `tests/test_reaudit_compile.py`
