# High-Level Plan (DRAFT v8) — State-Surface Integrity
Revision: v8 (post hr-team round 7)  ·  Status: under council review, not finalized
# v8 delta (round-7): challenger + api + observability ENDORSED v7. Two one-line fixes applied:
#   - invariant (b) now requires BOTH conjuncts (snap.backup ≠ ∅ AND .enabled ≢ "true") on the
#     "not configured" line + forbids ≡ ∅ (eval-engineer's constructed ∅-gate-drop bypass);
#   - invariant (f) plans list now includes the 4th deleted gather var `plans-done` (harness-designer);
#   - prose: "reader==writer by construction" → "by init-invariant"; PR-001 import corrected.

## v7 delta (round-6 convergence — 3 verified fixes)
1. **Reader/writer path split ELIMINATED (challenger B, verified).** v6 read backup/plans via
   `MYAXON_ROOT`, but the writer (`workspace-backup.md:35`) and today's menu (`:72`) resolve via
   `W:myaxon-local | {W:myaxon-path}/memory/local` — so `MYAXON_ROOT` NEWLY introduced a split that
   diverges under `$MYAXON_ROOT`-env (present-but-empty dir → false "not configured", the incident).
   v7 resolves via `_axon_paths.read_myaxon_pointer(workspace)` (verified to exist, `:95` — it reads
   the SAME `W:myaxon-path` pointer the writer's fallback + boot gate use), so **reader == writer by the
   init-invariant** (`W:myaxon-local` is only ever init-stored to `{myaxon-path}/memory/local`; see PR-001).
   No coincidence-test workaround, no out-of-scope residual — the divergence class is gone (and degradation-safe even if it weren't).
2. **Invariant (f) no longer bans the retained `backup-warn`** (api-architect + challenger, CI-blocking):
   (f) now bans only the DELETED gather vars `backup-(enabled|url|status|last)`; `backup-warn` is the one
   allowed re-sourced derived var.
3. **Invariant (b) is now PER-LINE/arm-scoped** (eval-engineer, constructed bypass — `_both_menus` is
   whole-file `str.index`/`in`, verified): a whole-file check can't bind conjuncts to one arm. v7 (b) is
   a per-render-line assertion; the ∅ arm is anchored on the UNIQUE phrase "snapshot unavailable"
   (not "unknown", which occurs 4× elsewhere). The illustrative render below is un-aliased to match.

## Model (validated by all seats across rounds 3-6)
Snapshot code-resolves the raw backup/plans values; menu.md keeps today's proven render + os-warn
logic; the ONLY behavioral additions are the degraded-safe arms so a snapshot failure renders
"unknown"/silent, never a false "not configured". No `configured` tri-state (round-4 over-engineering);
no os-warn fold (round-4 noise regression). Reader uses the writer's own resolver (round-6).

## Why incident-safe
2026-07-10: the AGENT read a GUESSED path → false "not configured". v7: the snapshot reads via the
writer's pointer (reader==writer) and is the sole source. Outcomes: (1) true value resolved (this user:
enabled=="true" → ✓); (2) snapshot fails → `snap.backup ≡ ∅` → degraded arm. A false "not configured"
renders only when `enabled` is genuinely ≠ "true" at the writer's own path = genuinely not configured.

## PR-001 [M] — Snapshot carries raw backup + plans (writer's resolver) + fixture value-pinning
Scope: tools/axon_state.py::cmd_menu_snapshot + tests.
- Resolve the my-axon local dir via the WRITER's machinery: `myaxon = read_myaxon_pointer(ws) or
  default_myaxon()` (both from `_axon_paths`; axon_state.py:84 already imports `default_workspace` from
  that module — PR-001 adds the `read_myaxon_pointer`/`default_myaxon` import); `local =
  {myaxon}/memory/local`, `plans_dir = {myaxon}/plans`. This reads the SAME `W:myaxon-path` pointer the
  writer's fallback + boot gate use. Reader==writer holds by the init-invariant: `W:myaxon-local` (the
  writer's primary) is ONLY ever init-stored to `"{myaxon-path}/memory/local/"` (my-axon-init.md:180,205;
  migrate-workspace.md:201) — no code sets it otherwise — so both tiers resolve identically in every
  supported config; and even a hypothetical divergence is degradation-safe (missing dir → `snap.backup=None`
  → "snapshot unavailable", never a false "not configured"). Optional literal hardening (mirror the writer
  byte-for-byte): `local ← W:myaxon-local | {myaxon}/memory/local`.
- `backup`: ALWAYS-DICT `{enabled, url, status, last_push}` (raw stripped strings or None per file;
  pin `-last-push.md`, never `-last.md`). Resolve all-or-nothing: if the local dir is missing/unreadable
  or a read raises → `snap.backup = None` (→ the render's degraded arm). NO `configured` field — the
  render keys on `enabled`/`status` like today. `enabled = None` (dir readable, file absent) = "not configured".
- `plans`: WHOLE-FIELD None on failure; else `{active_count:int, done_count:int,
  active_stems:[≤3 plain strings]}` from `{plans_dir}/*.md` (exclude INDEX.md), replicating menu.md's
  exact filters (`Status:  active` two-space @:85; the 4-variant done match @:86).
- Conventions: backup = always-dict-when-present (like drift; EXCLUDE from test_failed_probe);
  plans = whole-field-None (like workflows).
- Fixtures (ABSOLUTE values, via a temp pointer the test writes — the repo pointer-test idiom):
  healthy(enabled=true,status=ok)→enabled=="true",status=="ok"; not-configured(dir present, no enabled
  file)→backup≠None, enabled is None; push-error→status=="error"; degraded(dir absent/unreadable)→
  backup is None; path-canonicity(-last-push read, -last NOT); pointer honored (write a pointer to a
  temp my-axon, assert the snapshot reads THERE — proves reader==writer); plans→counts+stems, None on
  missing dir.
Deps: none.

## PR-002 [M] — menu.md consumes snap.backup/snap.plans; degraded-safe both branches; delete resolution; twin + invariants
Scope: workspace/programs/menu.md + workspace/programs/compiled/menu.cmp.md +
tests/synapse/corpus/menu.contract.json (+header, optional hygiene) + tests.
- DELETE render resolution: backup gather (:71-76 READ), plans gather (:84-88 SCAN); source from `snap`.
- **Full-board backup render** (un-aliased `snap.backup`; today's 4-way + degraded arm FIRST):
  ```
  IF snap.backup ≡ ∅                                                        → "Backup  status unknown (snapshot unavailable) — run: self-care"
  ELSE IF snap.backup ≠ ∅ AND snap.backup.enabled ≡ "true" AND snap.backup.status ≡ "ok"    → "Backup  ✓ {snap.backup.url[:45]} · last: {snap.backup.last_push | 'never'}"
  ELSE IF snap.backup ≠ ∅ AND snap.backup.enabled ≡ "true" AND snap.backup.status ≡ "error" → "Backup  ✗ push failed — run: workspace-backup push"
  ELSE IF snap.backup ≠ ∅ AND snap.backup.enabled ≡ "true"                  → "Backup  {snap.backup.url[:45]} · not pushed yet this session"
  ELSE IF snap.backup ≠ ∅ AND snap.backup.enabled ≢ "true"                  → "Backup  ⚠ not configured — run: workspace-backup setup"
  ```
  (Every non-degraded arm is explicitly `snap.backup ≠ ∅`-gated; "not configured" sits on a line that
  ALSO reads `snap.backup.enabled ≢ "true"` — satisfying per-line invariant (b). No bare ELSE, no alias.)
- **Collapsed nudge (:181, +twin :152)**, ∅-safe: `IF snap.backup ≠ ∅ AND snap.backup.enabled ≢ "true"
  → "Backup  ⚠ not configured — run: workspace-backup setup"`. Degraded (∅) → no collapsed line (silent).
- **os-warn / backup-warn — today's semantics, re-sourced**: `backup-warn ← (snap.backup ≠ ∅ AND
  snap.backup.enabled ≡ "true" AND snap.backup.status ≡ "error")`. `backup-warn` is RETAINED (the one
  allowed derived var); os-warn (:169) unchanged. Not-configured stays advisory → NO noise regression.
- **Affordance (:402-405, +twin)**: `IF snap.backup ≠ ∅ AND snap.backup.enabled ≡ "true"` →
  `snap.backup.url[:40]`.
- **Plans — rewire ALL consumers**: `:231/232/234`→`snap.plans.active_count`; `:233`→
  `∀ p in snap.plans.active_stems → {p}`; `:235-236`→`snap.plans.done_count`; `:261`→
  `(snap.plans ≠ ∅ AND (snap.plans.active_count > 0 OR snap.plans.done_count > 0))`; each guarded by
  `snap.plans ≠ ∅`. Mirror in twin (:198-203,:220).
- Recompile menu.cmp.md (live target) + source↔compiled parity.
- Regenerate menu.contract.json + header inputs-count as OPTIONAL HYGIENE (verified NOT test-breaking:
  synapse tests assert shape + ≥80% corpus rate, never inputs-count; confirm the contract test tolerates
  the gather-deletion delta).
- **STATIC invariants** over BOTH menu.md + menu.cmp.md:
  (a) backup + plans sourced from `snap.*`, NO render `READ(`/`SCAN(`;
  (b) **per-line (arm-scoped), CONDITION-side, BOTH conjuncts AND-joined** — iterate render lines; for
      every line whose OUTPUT (right of `→`) contains "not configured", inspect ONLY its CONDITION (text
      left of `→`) and assert it contains ALL of: `snap.backup ≠ ∅`, `snap.backup.enabled` with `≢`/`≠`
      `"true"`, and the connective ` AND ` — and contains NEITHER ` OR ` NOR `≡ ∅`. (Condition-side scope
      defeats output-string token camouflage; the AND/¬OR check defeats an `AND→OR` mis-author that would
      otherwise fire the standalone collapsed nudge on a degraded ∅ snapshot — eval-engineer round 8.)
      Separately, the degraded arm's OUTPUT MUST contain the unique phrase "snapshot unavailable". Over both files;
  (c) os-warn's backup term is exactly `snap.backup ≠ ∅ AND snap.backup.enabled ≡ "true" AND
      snap.backup.status ≡ "error"`, and nothing about not-configured is in os-warn;
  (d) plans sourced from `snap.plans` (no `SCAN(`); consumed fields exactly {active_count,done_count,active_stems};
  (e) test pins workspace-backup.md's status WRITE vocabulary to exactly {ok, error} (at the
      `WRITE(...backup-status.md, X)` sites; excludes the reader `| "unknown"` fallback);
  (f) **no-dangling-var meta-guard**: assert NO deleted gather var `backup-(enabled|url|status|last)` or
      `plans-(active|done|count)` bare token survives in menu.md OR menu.cmp.md (the `done` substring
      also catches `plans-done-count`; `backup-warn` is retained + allowed — NOT in this list). Catches
      any omitted consumer (the :181 class).
Deps: PR-001.

## Constraints
reduce-surface — axon_state.py + menu.md + menu.cmp.md + menu.contract.json + tests ONLY. NO new tool,
NO new state store. Kernel floor untouched. All path resolution reuses existing `_axon_paths` helpers.

## Honest boundary
The rendered STRING is not CI-executed (run.py:96 punts render to the agent). Enforcement = Python
snapshot fixtures (PR-001) + static neuron-text invariants (a)-(f) (PR-002), the latter now per-line
where arm-binding matters. Deleting the READ/SCAN + the degraded-safe arms make a false "not configured"
from a degraded/failed snapshot fail CI (invariants b,f + fixtures). Reader==writer (via
read_myaxon_pointer) removes the path-divergence class. Residual: a freeform render otherwise
mis-authoring an arm is constrained by (a)-(f); "class closed" = closed at the enforceable layers.

## Round-6 findings → v7 resolution
- reader/writer path split (challenger B, MATERIAL, verified) → resolve via read_myaxon_pointer (writer's
  resolver); reader==writer by construction; coincidence-test/out-of-scope framing removed as no longer needed.
- invariant (f) bans retained backup-warn (api+challenger, CI-blocking) → (f) lists only deleted gather vars.
- invariant (b) whole-file bypass + vacuous "unknown" (eval, constructed) → per-line arm-scoped + unique
  "snapshot unavailable" anchor; illustrative render un-aliased + explicitly both-gated.
- pseudocode alias/bare-ELSE contradiction (harness+observability+eval) → render block rewritten un-aliased,
  every arm ≠∅-gated.
- minor line-cites → this draft's arm list is authoritative; (f) backstops any missed token.
