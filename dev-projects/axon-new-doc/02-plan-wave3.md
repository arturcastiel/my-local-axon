# Wave 3 plan — code-dev getting-started tutorial (APPROVED + EXECUTED 2026-06-17)

Key findings confirmed. There's a `code-dev-lifecycle-tour` neuron ("Interactive guided tour of code-dev for new users") — an overlap risk the plan must distinguish from. And the GitHub-vs-GitLab discrepancy is real: neurons print `git push` + GitHub `pr-github`, but owner memory documents a GitLab `glab` loop. The tutorial must reflect what the neuron actually prints, not fabricate. I have everything I need to synthesize the plan.

---

# Wave-3 PLAN — code-dev getting-started TUTORIAL

**Project (single-umbrella):** `my-axon/dev-projects/axon-new-doc` — wave 3. The wiki is this project's deliverable; follow-on tutorial work is more PRs here, NOT a new top-level project.
**Status:** awaiting owner **PLAN-DONE** sign-off. Markdown-only; not for execution.
**Mode/budget:** tactical · budget 4 · 1 wave (wave-3), 4 firm PRs, dependency-ordered.
**Grounding verified this session:** both tool-run anchors run live; `test_wiki.py` contract read in full; `code-dev-new.md` prompts confirmed; `code-dev-next.md` and `code-dev-pr-ready.md` exist and were read.

---

## 1. The tutorial deliverable — wiki files under `workspace/wiki/`

### NEW: `workspace/wiki/getting-started.md` (the tutorial — the on-ramp)
A single narrated journey from a booted-but-empty session to one printed push command, doing **one tiny real change**. It is the WALK; `code-dev.md` remains the REFERENCE. It follows `_template.md` so `test_wiki.py` auto-guards it (it is a `*.md` not in `NON_MANUALS`). Section shape (template-conformant + beginner-arc):

- `## Purpose` — on-ramp that PRECEDES `code-dev.md`; one-sentence destination; the two fears it defuses ("can I break it?" / "what next?").
- `## The two hard contracts (read first)` — **AXON never implements, AXON never pushes**, surfaced ABOVE any verb (the beginner's biggest surprise). This is the owner's actual operating model, slowed down.
- `## Before you start — environment check` — bordered 60-second checklist: canonical tree `{path/to/axon}` (note stale checkouts exist elsewhere), `boot axon` succeeded, a real codebase path in hand. Portable forms only.
- `## Invocation` — required by `REQUIRED_SECTIONS`. States both surfaces: type `code-dev <verb>` in a booted session (NOT a shell command); backing tools (`phase-model`, `study-modes`) run via `python3 axon.py …`.
- `## The 5-phase ladder in plain words` — re-captioned `study→plan→pr→log→audit` table: study="where does it live?", plan="smallest set of steps", pr="write down what one step changes", log="I edited it; record done-vs-planned", audit="did I do what I planned?". Load-bearing rule: a phase is done only when YOU mark it.
- `## Command / option reference` — required substring `Command`. The minimal **"your first 7 verbs"** table (`new · study · done · plan · pr · log · pr-ready`) + the safety-net verbs `next` / `status`. DELEGATES all flags to `code-dev.md` by link (no flag re-tabling → avoids freshness coupling).
- `## Worked examples (hybrid contract)` — **3 examples** (2 tool-run + 1 session-transcript; see §3/§4).
- `## When you get lost — `code-dev next`` — the 10-moment classifier as the antidote to fear #2, with `code-dev status` as the "where am I?" companion.
- `## The gates are your friend` — reframe: a red gate is the system doing its job. Beginner subset only (tree clean, shadow fresh, commit-trailer lint blocks internal PR-N refs); one line on the bigger rule (full gate before push, merge on green) → link `code-dev.md`.
- `## What this leaves out` — honest scope: waves/many-PRs, study swarms + adversarial-critic confidence, goal-define interrogation, DAG critical paths, full crucible set, autonomous/dev-mode. One line + pointer each. Plants the **single-umbrella** habit ("more PRs under THIS project, never a new top-level one").
- `## Gotchas / notes` — beginner traps distinct from `code-dev.md`: (a) neurons are NOT shell commands (`python3 axon.py code-dev-study` → real `Unknown tool` error shown); (b) AXON won't advance phases for you — `code-dev done` is yours; (c) AXON edits nothing and pushes nothing; (d) a fresh project's `phase-model render` shows all-pending — that's the start line; (e) a boot path-mismatch warning is a known env note, not your fault.
- `## Where to go next` — three-rung ladder: `code-dev.md` → `plan.md` → `goal-define.md`.
- `## Guarded by` — `tests/test_wiki.py` (verbatim contract line).

### EDIT: `workspace/wiki/INDEX.md`
Add a new top section **"Start here"** linking `getting-started.md` ABOVE "Flagship programs" (so the newcomer sees the on-ramp first). Required regardless: `test_every_manual_is_linked_from_index` asserts `(getting-started.md)` appears in INDEX.md.

> **No third file.** The beginner-lens "synthesis" is fully carried by these two. The other two designs (a `code-dev.md` reference-deepening and a flagship `lifecycle.md`) are folded as link targets, not new pages — keeping freshness surface minimal.

---

## 2. The chosen WORKED EXAMPLE

**A fresh tiny project, slug `my-first-fix`, doing a one-line docs micro-fix** — narrated as a `[session-transcript]`. **Plus** `axon-new-doc` reused (read-only) as the **"finish-line" tool-run** so the beginner sees the goal-state before climbing.

**Rationale (synthesis of all three lenses):**
- **Fresh `my-first-fix` for the walk** (beginner lens): near-zero blast radius defuses fear #1; still exercises the FULL five-phase spine honestly; still trips real gates (tree-clean, shadow-fresh, commit-trailer) on a change small enough to reason about completely. A first win must be safe AND complete.
- **Reuse `axon-new-doc` for the finish-line tool-run** (lifecycle lens): `phase-model render --project my-axon/dev-projects/axon-new-doc` returns all five phases `done` — real, captured, portable (relative path, no `/home/`). "See the finished ladder before you start the bottom rung." Reuses what already exists per the verify-before-build habit; couples the page only to a finished, stable project.
- **`onboard` study mode** (study lens, lite): `study-modes resolve --mode onboard` is literally the beginner's study mode (input-cap 8000, questions "Who is the newcomer and their goal?" / "Smallest mental model that unblocks them?"). It connects the tutorial to the heavy study phase without dragging the beginner through swarms.

**Why not reuse axon-new-doc for the WALK too:** its real PRs are wiki manuals (meta/confusing for a newcomer) and its history is multi-wave (firehose). The walk needs the smallest honest change; the finish-line needs a real finished project. Use each for what it's best at.

---

## 3. Dependency-ordered PR breakdown — Wave 3

Theme order = foundation → content → linkage → bookend (matches the owner's wave semantics: instrument/floor first, completeness-keystone last).

| PR | Complexity | Depends-on | Scope (exact) | Acceptance |
|----|-----------|-----------|---------------|------------|
| **PR-w3-1 · scaffold + anchors** | S | — | Create `getting-started.md` with all `REQUIRED_SECTIONS` (`## Purpose`, `## Invocation`, `Command`, `Worked examples`, `## Guarded by`) as headed stubs. Capture the **two real tool-runs** verbatim into the Worked-examples section: `study-modes resolve --mode onboard` and `phase-model render --project my-axon/dev-projects/axon-new-doc` (both re-run at build time, output pasted exactly, labeled `(tool-run)`). | File exists; `test_every_manual_has_required_sections` passes for it; both tool-run blocks present and labeled; output byte-matches a fresh re-run; no `/home/` literal. |
| **PR-w3-2 · the walk (session-transcript)** | M | PR-w3-1 | Author the central `[session-transcript]`: `code-dev new` (4 prompts verbatim from `code-dev-new.md`: slug/name/codebase/first-phase → "✓ v4 scaffolded") → `study --mode=onboard` → `done --phase study` → `plan --mode=tactical --budget 1` → `pr` → **human edit (AXON waits)** → `log` → `audit` → `pr-ready` (prints the HUMAN push line, does NOT run). Each step ends with a literal `NEXT ·` line. Label `(session-transcript)`. Mirror the **exact** push output `code-dev-pr-ready.md` actually prints (`git -C {codebase} push…` + `code-dev pr-github`) — see §6 GitLab/GitHub note. | Transcript is one continuous labeled block; prompts match `code-dev-new.md`; printed push line matches `code-dev-pr-ready.md` actual output; `test_every_manual_has_two_hybrid_examples` now sees ≥3 examples; tree-clean / shadow-fresh / commit-trailer narrated as PASSING green. |
| **PR-w3-3 · beginner-arc prose + INDEX linkage** | M | PR-w3-2 | Write the narrative sections: two-hard-contracts, env-check checklist, ladder-in-plain-words, `code-dev next` safety-net, gates-are-your-friend (beginner subset), leaves-out + single-umbrella, gotchas (incl. real `Unknown tool` error block), where-to-go-next. **Edit `INDEX.md`**: add "Start here" section above "Flagship programs" linking `getting-started.md`. Distinguish from the existing `code-dev-lifecycle-tour` neuron (interactive tour) — this is the static reference manual; cross-reference, don't duplicate. | All narrative sections present; `(getting-started.md)` in INDEX.md → `test_every_manual_is_linked_from_index` passes; no flag-tables duplicated from `code-dev.md` (links only); no `/home/`. |
| **PR-w3-4 · gate run + freshness bookend** | S | PR-w3-3 | Run the **FULL crucible gate** (whole pytest suite + predicates), not just `test_wiki.py`. Confirm `test_wiki.py` green for the new page; re-run both tool-runs and reconcile any drift; run `freshness`/`drift` on the wiki; verify push by reading PUSH_RC (not exit code) when the human pushes. | Full suite green; all 8 `test_wiki.py` assertions pass for `getting-started.md`; tool-run outputs still byte-match; freshness/drift clean; PUSH_RC verified. |

**Critical path:** PR-w3-1 → PR-w3-2 → PR-w3-3 → PR-w3-4 (strictly linear; the page is one artifact).

---

## 4. Hybrid example contract + `test_wiki.py` guard

- **≥2 labeled examples (`test_every_manual_has_two_hybrid_examples`):** satisfied with **3** — two `(tool-run)` (real captured output, re-run at build) + one `(session-transcript)`. Counted via the literal substrings `(tool-run)`/`(session-transcript)` the test greps for.
- **Required sections (`test_every_manual_has_required_sections`):** all five substrings present (`## Purpose`, `## Invocation`, `Command`, `Worked examples`, `## Guarded by`).
- **Path portability (`test_manuals_are_path_portable`):** zero `/home/` literals — use `{path/to/axon}`, `my-axon/dev-projects/{slug}`, and the already-portable relative `my-axon/dev-projects/axon-new-doc` for the tool-run.
- **INDEX linkage (`test_every_manual_is_linked_from_index`):** `(getting-started.md)` added to INDEX.md in PR-w3-3.
- **Flagship rule (`test_flagship_manuals_have_a_real_tool_run`):** does NOT apply — `getting-started.md` ∉ `FLAGSHIPS`. But it carries 2 real tool-runs anyway (anti-mimicry hedge), exceeding the bar.
- **`R_NEW_NEEDS_TEST` (BLOCK):** satisfied with **no new test** — the page lives under `workspace/wiki/` and is auto-held to the full `test_wiki.py` contract. No code/program/tool ships, so the existing guard IS the test. The `## Guarded by` line names `tests/test_wiki.py` verbatim.
- **Anti-mimicry / never-fabricate:** the only hand-authored block is the `[session-transcript]` (the agent-driven verbs can't shell out) — explicitly labeled, prompts mirrored from `code-dev-new.md`, push line mirrored from `code-dev-pr-ready.md`. Paired with two REAL tool-runs as the hedge.

---

## 5. Owner-grounded design principles (from the research)

1. **Study-first, gated, phase-marked-by-the-human.** The walk teaches the canonical `audit-what-exists → study → plan → pr → log → audit` spine with explicit sign-off gates ("a phase is done only when YOU mark it"). Source: `memory/general/verify-before-build-plans-drift.md`; `entries/2026-05-29.md` (STUDY-DONE/PLAN-DONE tokens).
2. **AXON never implements, never pushes — high-autonomy, not chatty.** Surfaced above any verb. The tutorial models terse imperatives and the agent deciding, NOT a confirm-every-step loop the owner finds frictional; the slow hand-holding is framed as "training wheels you'll drop." Source: `memory/general/owner-full-authorization-decide-autonomously.md`; `memory/local/autonomous-grant.json`.
3. **Gate discipline is non-negotiable.** Tests ship in the same PR (here: zero new test, satisfied by the existing guard); run the FULL crucible gate before push (PR-w3-4), never a subset; merge only on green; verify push by reading PUSH_RC. Source: `memory/general/new-program-or-tool-requires-tests.md`, `run-full-gate-before-push.md`, `verify-git-push-not-exit-code.md`.
4. **Single-umbrella, anti-sprawl.** The page lives under the existing `axon-new-doc` project; the tutorial itself teaches "follow-on work = more PRs under THIS project, never a new top-level one" — directly targeting the owner's #1 pain (project sprawl across ~46 projects). Source: `memory/general/axon-improvements-single-umbrella.md`.
5. **Environment hygiene + grounded sourcing.** The env-check checklist names the canonical tree and the my-axon Linux-ext4 store, and flags the live MYAXON.md path-mismatch as a known note. Worked examples use only real captured surfaces; the plan explicitly does NOT mine `retrieval-traces/evals/study-evals/receipts` (synthetic fixtures). Source: `memory/general/canonical-axon-tree-is-new-axon.md`, `myaxon-store-is-linux-ext4-not-mnt-c.md`, `workspace/log/entries/2026-06-17.md`.

---

## 6. Decisions needing owner sign-off (debate-first forks)

1. **GitHub vs GitLab in the push step.** Research says the owner's real loop is GitLab (`glab mr create/merge --squash`), but the actual neuron `code-dev-pr-ready.md` prints `git push` + `code-dev pr-github` (GitHub), and no neuron contains `glab`. **Recommendation:** the transcript must mirror what the neuron ACTUALLY prints (GitHub flow) to stay honest/non-fabricated, with a one-line gotcha noting the owner's day-to-day MR loop is GitLab and pointing to the autonomous-loop memory. Alternative: fix `code-dev-pr-ready.md` to GitLab first (out of scope for a docs wave — would be a separate code PR under this umbrella).
2. **Three examples vs two.** Recommend three (2 tool-run + 1 transcript) for the anti-mimicry hedge; two would still pass the test.
3. **Overlap with `code-dev-lifecycle-tour` neuron** (interactive tour for new users). Recommend keeping them distinct: the neuron is an interactive in-session tour; `getting-started.md` is the static read-first manual. Cross-link, don't merge.

**Relevant paths:** `/home/arturcastiel/projects/new-axon/axon/workspace/wiki/getting-started.md` (new), `/home/arturcastiel/projects/new-axon/axon/workspace/wiki/INDEX.md` (edit), `/home/arturcastiel/projects/new-axon/axon/tests/test_wiki.py` (guard), `/home/arturcastiel/projects/new-axon/axon/workspace/programs/code-dev-new.md`, `code-dev-next.md`, `code-dev-pr-ready.md`, `code-dev-lifecycle-tour.md` (transcript sources), `/home/arturcastiel/projects/new-axon/axon/my-axon/dev-projects/axon-new-doc/` (finish-line tool-run target).