# CD·TOOLS·P3 — migration plan + risks

> Step-by-step path from today's 57 flat programs to the 10-verb umbrella in `cd-tools-p2-umbrella.md`. Each wave is small and independently shippable.

## Migration waves

### Wave T1 — Add verb routers (no behavior change)
Ship 10 new programs: `code-dev-{lifecycle,state,journal,pr,review,shape,safety,knowledge,flow,meta}.md`. Each routes `subcommand` to existing programs.

**Effect:** users gain `code-dev pr respond 3` AS A SYNONYM for `code-dev pr-respond 3`. Nothing breaks.

**Files:** +10 routers (~100 lines each).
**Risk:** zero — old commands still resolve directly.

### Wave T2 — Retire pure redundancies as alias-stubs
Replace 8 programs with 5-line stubs that warn + delegate:
- combine → `shape partition merge`
- divide → `shape partition split`
- hold → `safety freeze`/`thaw`
- since → `journal search --since`
- replay → `journal search --patterns`
- diff → `review --mode=diff`
- check-structure → `safety audit --structure`
- explain-reviewer → `knowledge reviewer-track --reviewer X --history`

**Effect:** old verbs print one-time deprecation warning then call the new path.
**Files:** -8 full programs, +8 stub programs (net source bytes drop significantly).
**Risk:** low — stubs preserve every old invocation; users see a warning.

### Wave T3 — Inline flag-merges
Move `--mode=`, `--since`, `--patterns`, `--structure`, `--history` flags into their host programs. Update each host's `## HELP` to advertise the new flags.

**Effect:** the alias-stubs in W2 now have a real target to forward to.
**Risk:** low — purely additive flag handling.

### Wave T4 — Sub-command file split (per verb)
For each top-level verb, split sub-commands into their own files using the new naming:
- `code-dev-pr-create.md`, `code-dev-pr-update-spec.md`, …
- Old `code-dev-pr-*.md` files become alias-stubs (5 lines each).

**Effect:** new file names match the verb-centric CLI; old names still resolve via stubs.
**Risk:** **highest** — touches every file in the family. Stage per cluster.

**Sequence within W4:**
1. `state` (7 files renamed) — low traffic
2. `safety` (5 files) — well-tested area
3. `journal` (4 files) — small
4. `knowledge` (5 files) — small
5. `flow` (5 files) — small
6. `review` (4 files) — small
7. `shape` (5 files) — small
8. `pr` (~11 files) — **largest, do last**

### Wave T5 — Drop the alias stubs
After ≥1 release where stubs printed warnings: drop them. Verb-centric is the only surface.

**Effect:** 8 deprecated programs disappear.
**Risk:** breaking change for any external scripts. Mitigate: announce in CHANGELOG one release prior.

### Wave T6 — Recompile + cache audit
- Re-run compile pipeline; verify new routers compile to small files (~1 KB each).
- Re-run compile-regression gate (T-A3 from cycle 3).
- Verify static-prefix discipline (Anthropic prompt cache fit).

**Effect:** measured compression % per program; benchmark-log updated.
**Risk:** zero — measurement only.

## Total effort
~5 incremental PRs (one per wave; W4 split into clusters). Each ship-able independently.

## Pre-conditions (must ship FIRST)
1. **T-A3** (compile-write regression gate) — prevents bloated routers from going live.
2. **D-B1** (`pr-list`) — easier to add as `pr list` if `pr` verb router is in place.

## Risk register

| ID | Risk | Severity | Mitigation |
|----|------|---------:|------------|
| R1 | User scripts break when stubs removed (W5) | high | 1-release warning period; CHANGELOG one release earlier |
| R2 | Confusion during W2–W4 transition (two ways to do everything) | medium | clear deprecation messages; `code-dev help <verb>` shows new path |
| R3 | Router files bloat (defeating purpose) | medium | T-A3 gate; cap router source at ~150 lines |
| R4 | Sub-command discovery harder if `code-dev help` doesn't enumerate | low | extend `help` to walk routers and list subcommands |
| R5 | `dispatch` (free-text routing) mis-routes old vs new verb during transition | low | dispatch index treats stubs as preferred-but-deprecated |
| R6 | Compiled router caches old subcommand list | low | invalidate compiled router whenever subcommand list mtime changes |
| R7 | `code-dev next` suggests old verbs | medium | update next's mapping; ship together with W1 |
| R8 | `help [program]` returns nothing if user types `pr-respond` after W5 | low | tombstone files: 1-line "moved to: code-dev pr respond" |

## Validation checklist (per wave)
- [ ] `code-dev help` lists current surface correctly
- [ ] `code-dev whatif <cmd>` works for both old and new verbs (during transition)
- [ ] `code-dev next` suggests new verbs
- [ ] `axon-audit` finds no broken references
- [ ] `lint-paths` clean (no new hardcoded paths in routers)
- [ ] benchmark-log shows no compression regression
- [ ] dispatch matches typical user prompts to expected verb (smoke test)

## Per-program decision table (extract — full list in repo PR)

| Today's program | Wave | Final form |
|-----------------|:----:|------------|
| code-dev-combine | T2 | stub → `shape partition merge` |
| code-dev-divide  | T2 | stub → `shape partition split` |
| code-dev-hold    | T2 | stub → `safety freeze`/`thaw` |
| code-dev-since   | T2 | stub → `journal search --since` |
| code-dev-replay  | T2 | stub → `journal search --patterns` |
| code-dev-diff    | T2 | stub → `review --mode=diff` |
| code-dev-check-structure | T2 | stub → `safety audit --structure` |
| code-dev-explain-reviewer | T2 | stub → `knowledge reviewer-track --reviewer X --history` |
| code-dev-pr-respond | T4 | rename to `code-dev-pr-respond.md` (kept) under `pr` router |
| code-dev-pr-update-spec | T4 | rename to `code-dev-pr-update-spec.md` |
| code-dev-pr | T4 | becomes `code-dev-pr-create.md` (verb-centric: `pr create`) |
| code-dev-status / next / resume / handoff / metrics | T4 | renamed under `state` router |
| code-dev-log / decision / event / search | T4 | renamed under `journal` router |
| code-dev-study / shadow / explain / impact / reviewer-track | T4 | renamed under `knowledge` router |
| code-dev-plan / merge / cascade / changelog / test-map | T4 | renamed under `flow` router |
| code-dev-phase-new / phase-start / plan-master / link / partition | T4 | renamed under `shape` router |
| code-dev-freeze / dont-do / preflight / audit | T4 | renamed under `safety` router |
| code-dev-new / init / load / tour | T4 | renamed under `lifecycle` router |
| code-dev-whatif / help | T4 | renamed under `meta` router |
| code-dev-tag → state save · code-dev-undo → state undo | T4 | moved into `state` |

## Roll-back plan
Each wave is its own PR. If any wave causes issues:
- T1 (routers): delete the new routers; old commands still work directly. Zero data impact.
- T2 (stubs): revert stubs; restore original files from git. Zero data impact.
- T3 (flags): revert the flag-handling commits; old separate programs still exist.
- T4 (renames): tracked via `git mv`; revertible. **Data risk:** `_actions.log` entries reference old program names — keep the rename log in `workspace/AXON-DOCS.md` mapping section.
- T5 (drop stubs): revert. Users get warnings back temporarily.

## What this migration WON'T fix
- Project state files (`_meta.md`, `_actions.log`) — same format.
- `last-program` in `_meta.md` will record new names post-migration; the rename map helps audits cross-reference.
- Memory keys (`W:code-dev-project`) — unchanged.

## Definition of done
- [ ] All 10 verb routers ship and pass `axon-audit`.
- [ ] Top-15 retire candidates have stubs; warnings emit cleanly.
- [ ] Flag-merges (W3) all advertised in `help`.
- [ ] File renames (W4) complete; old paths return tombstones.
- [ ] Compile-regression gate green.
- [ ] benchmark-log shows no compression regression.
- [ ] At least one release cycle elapsed before W5.

→ prior art for verb-centric design + migration playbooks in `cd-tools-p4-prior-art.md`.
