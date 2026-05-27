# Study — dont-do-enforce: feasibility + gap measurement (2026-05-27)

Method: two parallel evidence-backed investigations — (A) enforcement mechanics in the
canonical tree `new-axon/axon`, (B) `_dont-do` data surface + blast radius across
`new-axon/axon` (programs) and `my-axon/dev-projects` (data).

## Headline
- **Achievable as ONE feature-PR chain — NO prerequisite plumbing PR.** `R_DONT_DO` is a
  near-clone of `R_NEW_NEEDS_TEST` (a STATIC/BLOCK `check(ctx)` predicate riding the existing
  `changeset-rules` control through `crucible gate`, the autonomous pre-merge gate).
- **Schema change is additive + backward-compatible.** An indented `match:` line is invisible
  to all ~10 consumers (every parser anchors on `^- ` at column 0); the schema doc already
  mandates additive-only upgrades, and inline-token precedent already exists in real data.
- **The original failure is reproducible IN CODE** — `code-dev-review-diff §3` only greps
  backtick-fenced substrings, case-sensitive `CONTAINS`, against the whole diff. A prohibition
  with no backticks silently never matches. This validates the effort.

## Gap measurement — how far are we
| Capability needed | Status | % there | Evidence |
|---|---|---|---|
| Pre-merge BLOCK gate phase | HAVE | 100% | `crucible gate` fail-closed, exit-code driven (crucible.py:101-196) |
| Merge-base changed-files | HAVE | 100% | `crucible.changed_files()` (crucible.py:124-144) |
| Added-line *content* extraction | NEAR | 80% | `scan_pre_push._staged_added_lines()` exists (:34-59); need ~15-line `added_lines(base...HEAD -U0)` helper, or read changed files |
| Predicate pattern + registration | HAVE | 100% | mirror `r_new_needs_test.py` + `rules/registry.py` |
| Always-on wiring into the gate | HAVE | 100% | `changeset-rules` BLOCK control already runs in `crucible gate`; just add `r_dont_do.check` to the `run_changeset` tuple (crucible.py:150-153) |
| `_dont-do` `match:` schema | PARTIAL | 70% | format is `- ` bullets; schema-v4 already defines optional fields + additive rule (_code-dev-schema-v4.md:8,24-35); precedent tokens `[[..]]`/`(R_..)` in dag-consistency seeds |
| Tripwire tests (prove the token bites) | NONE | 0% | new — trivial pytest fixtures |
| `dont-do lint` | PARTIAL | 20% | extend existing manager `code-dev-dont-do.md` (no new file) |
| Capture step (review-constraint → prohibition) | WEAK | 10% | `code-dev-safety-preflight.md` Gate 3 exists but is manual/opt-in |
| review-diff §3 upgrade to `match:` | FRAGILE | 50% | exists but backtick-only, substring, opt-in (code-dev-review-diff.md:89-106) |
| Backfill existing prohibitions | NONE | 0% | 25 real `_dont-do` files in my-axon to migrate |

**Read:** the hard *mechanism* is ~90% pre-built; the *discipline + data* parts (capture, tripwires, backfill, lint) are the real work — and they're exactly what makes it not-fail.

## Feasibility verdict per goal
- **Mechanical BLOCK gate:** FEASIBLE as-is. Hook = add `r_dont_do.check` to `crucible.run_changeset`'s hard-coded tuple; it rides `changeset-rules` (no new crucible.json entry). One in-PR decision: read changed-file contents (precedent: r_new_needs_test) vs add a tiny `added_lines()` helper (precedent: scan_pre_push). Either is inside the feature PR.
- **Additive schema:** FEASIBLE + safe. Indented `match:` ignored by all `^- ` parsers. Watch 2 edge cases: the retire path (`REPLACE-LINE`) orphans the `match:` line (hygiene); `CONCAT-FILES(dedup=true)` in combine could collapse identical `match:` lines (verify line-exact).
- **Always-on:** already true — `changeset-rules` runs every `crucible gate`. Not opt-in (unlike review-diff §3).
- **Phasing report-only → BLOCK:** supported via an `L:` opt-in flag pattern (precedent: R_GROUNDED_CLAIMS / R_MEMORY_RESPECTED).

## Polished PR plan (hardened against the failure modes)
- **PR-0 · Capture gate** — make "promote every review/design constraint → tokenized+tested prohibition" REQUIRED (wire into safety-preflight Gate 3 / review flow). *Fixes the UPSTREAM cause: the original constraint never became an artifact.*
- **PR-1 · `match:` schema + parser + `dont-do lint` + TRIPWIRE tests** — each prohibition carries `match:` (literal or `/regex/`) **and** a known-violating + known-clean snippet; lint/test asserts `match:` fires on the violator, not the clean one (proves the token bites; catches token-rot). A prohibition without `match:`+tripwire is *un-enforceable*.
- **PR-2 · `R_DONT_DO` predicate (report-only) + `added_lines()` helper** — `tools/rules/r_dont_do.py` mirrors `r_new_needs_test.py`; lands WARN-only to dogfood safely.
- **PR-3 · Fail-closed semantics** — token hit → BLOCK; un-tokenized prohibition while diff non-empty → BLOCK (force tokenization); un-tokenizable/semantic → BLOCK → mandatory human review. The conservative core.
- **PR-4 · Wire into `changeset-rules` (always-on) + gate tests** — add to the `run_changeset` tuple; gate red on violation, green on clean (mirror test_crucible.py:99-108).
- **PR-5 · Backfill 25 `_dont-do` files + lint-in-gate** — migrate to `match:`+tripwire; handle the retire-orphan + dedup edge cases.
- **PR-6 · Upgrade review-diff §3 + safety-preflight Gate 3 to `match:` + docs** — replace the fragile backtick-guess; KERNEL-SLIM note (axon/ → dev-mode + human).

## Honest ceiling (so we don't over-claim)
A **ratchet, not a net.** It guarantees you never repeat a *captured* mistake and forces capture+proof. It does NOT mechanically catch (a) novel/first-time violations (no token yet), or (b) purely semantic violations with no lexical signature — those fail-closed to human review. Token-matching is syntactic; PR-0 + tripwires + fail-closed convert "trust" into "prove + escalate," but human review + the broader gates remain the backstop for the un-tokenizable.

## Design inputs / cross-cutting risks
- **Data/programs/tree split:** `_dont-do` DATA lives in `my-axon/dev-projects/**/phases/*/`; the PROGRAMS + gate live in the repo. `R_DONT_DO` must load prohibitions from the project's phase dirs. And there are up to **4 axon trees** — the gate must land in the canonical one + propagate. This is **F0** (converge trees), a real prerequisite for the gate to bite everywhere.
- Canonical tree = `new-axon/axon` (newer, de-stubbed; `_dont-do` parse logic byte-identical across trees, so no semantic fork to reconcile).
