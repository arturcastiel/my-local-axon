# Project: State-Surface Integrity — menu warning fields code-resolved, not agent-guessed
slug:            axon-state-surface
schema-version:  v4
status:          complete
legacy:          false
phase:           audit
workflow-step:   build
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
workflow:        _workflow.yml
parent:          axon-stale-pointers
sub-projects:    []
created:         2026-07-10
updated:         2026-07-10

## Working Context
Owner-reported trigger (2026-07-10 boot): the menu rendered a FALSE warning —
"Backup ⚠ not configured — run: my-axon-init" — while backup was in fact configured and
healthy (enabled=true, url=github.com/arturcastiel/my-local-axon.git, status=ok, last push
2026-07-01). The `plans` probe hit the identical wrong-path pattern the same boot.

Root cause (owner correction, verbatim: "it was an error of the MODEL not the logic"): the
failure was EXECUTION-LAYER, not program logic. The menu neuron correctly specifies
`local-path ← RETRIEVE(W:myaxon-local) | {W:myaxon-path}/memory/local/`; the agent instead
hand-resolved that path with a wrong prefix (`../my-axon/…`, `workspace/memory/local/…`),
read nothing, and asserted the negative. The program was fine; the reasoning wasn't.

Enabling surface (the thing code CAN remove): `TOOL(axon-state, menu-snapshot)` — the
"one-call state" tool meant to carry every menu field — OMITS `backup` and `plans`. Those two
fields therefore fall back to agent-side `READ`/`SCAN` of a hand-resolved path. That fallback
IS the guess-surface. Two live instances confirmed this boot (backup mis-resolved; plans probe
same pattern). One class, two instances.

Sibling of parent `axon-stale-pointers` (both: "the menu surfaces wrong state"). That project
guards `active_phase_valid`; this one guards the filesystem-resolved warning fields.

Scope hypothesis (verify in study):
1. Move `backup` + `plans` into the snapshot tool, resolved in Python from the canonical keys
   (W:myaxon-local / W:myaxon-path / W:myaxon-plans) — render reads a value, never a path.
2. Strip the agent-resolvable READ/SCAN fallbacks for warning fields out of menu.md; the
   deterministic fallback lives inside the tool.
3. Regression test (Core Rule 13): assert no menu warning-field is sourced from an agent-side
   READ(/SCAN( — it must come from the snapshot. Pins the invariant so a NEW field can't reopen
   the hole.

Constraints (inherited reduce-surface): extend `axon-state` + `menu.md` — NO new top-level
tool, NO new state store. Honest boundary: this removes the surface + fallback path; it cannot
force a freeform render to consult the snapshot. Full determinism (tool renders the menu) is a
larger change — log as follow-up, out of this project's scope.

Run: code-dev study  to begin.
