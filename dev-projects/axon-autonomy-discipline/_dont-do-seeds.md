# Project-wide prohibition seeds — axon-autonomy-discipline

Seed each phase's `_dont-do.md`. INVARIANTS for every PR. The autonomy-specific ones (top) are the point
of this project; the standing ones (bottom) apply to all AXON work.

## Autonomy invariants (this project's reason to exist)
- **DON'T push through a red or ambiguous state.** A twice-red gate, repeated failure, or an
  escalation-surface op must HALT and surface a question with a clean resumable checkpoint — never
  "try once more and hope." (Lesson: I committed a RED gate twice by pushing on.)
- **DON'T act outside the declared contract.** Scope (files/dirs) and operations are an up-front
  allow-list; a touch outside it is a circuit-breaker stop, not a judgment call to make in the moment.
- **DON'T skip the reanchor** at a PR boundary or a context-compaction/resume boundary. Re-assert
  identity + goal + dont-do + done-state + scope BEFORE doing more work. (Lesson: compaction dropped the
  operating frame and it had to be re-derived from context.)
- **DON'T perform an irreversible action (merge / push / outward-facing) without the two-key check** —
  gate-green AND an independent verification (adversarial pass or pre-declared human sanction).
- **DON'T hardcode the shared/main tree in a fan-out prompt.** Each parallel agent works in its own
  worktree; never write to the shared tree concurrently. (Lesson: 27 agents wrote to `main` at once and
  contaminated every returned diff.)
- **DON'T weaken `autonomous_mode.py`'s ALWAYS_DENY (kernel-change) or the default-off destructive
  policy.** The grant model is the hard floor; this project adds layers ABOVE it, never erodes it.
- **DON'T act on a recalled memory without checking it still matches the code.** (Lesson: the memory
  index claimed F30 was held when it had already shipped.)
- **DON'T leave the ledger unreconciled.** Every autonomous action opens an `accountability` entry that
  must reconcile at run-end; an unreconciled entry means the run did NOT cleanly finish.

## Standing discipline (all AXON work)
- **DON'T merge on anything but `passed: true`.** Parse `crucible gate` JSON and check `passed` in a
  SEPARATE step before committing — never chain commit after the gate in one pipe.
- **DON'T do bulk landings.** Small, single-concern PRs, each independently gated. (The 65-bug bulk fix
  did not hold — it spawned 15 regressions.)
- **DON'T branch late** — branch before the first edit. **DON'T `git add -A`** — stage only your files.
- **DON'T ship a producer-only test** — assert the observed effect, not just that a value was written.
- **DON'T fix a confirmed bug without a red→green regression test first.**
- **Merge discipline** ([[axon-merge-discipline]]): brand-free commits, no `PR-<n>` tokens (the "Cursor"
  brand ban also trips on the `{cursor.*}` program variable — write `<id>` instead), trailer
  `Co-authored-by: AXON <axon@arturcastiel.github.io>`, pre-lint the squash via `--stdin`, merge by
  number with a 405-retry loop, NEVER `glab auth login`.
- **DON'T write under `axon/` without L:dev-mode=true** (restore OFF after); KERNEL-SLIM edits also need
  the F50 version-lock bump. Prefer keeping this project out of the kernel.
- **DON'T regress the freshness/doc gate** — after touching programs/generators run `freshness check`
  (stay `ok:true`) + `doc-anchors check`.
