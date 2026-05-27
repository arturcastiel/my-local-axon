# CD·C3·P2 — caching workflows (token-economy lens)

> Workflows that exploit the perf observations in `cd-c3-p1-tokens.md` to cut code-dev token spend. Each item names a concrete cache layer or sequence.

## CW1 — Session-scoped read cache for project files
**Today:** every `code-dev-*` program re-READs `_meta.md`, `04-log.md` tail, `_dont-do.md`, `_decisions.md`, `reviewer-state.md` even if they didn't change in-session.

**Cache scheme:**
- key: `(W:code-dev-project, relative-path)`
- check: `(prev-mtime ≡ current-mtime)`
- store: in `W:code-dev-cache-<sha8(path)>`
- prune on `code-dev load <new-slug>`

**Est. savings:** 30–40% off `resume` / `status` / `next` / `preflight` reads on warm sessions.

## CW2 — Lazy `pr-review` body — load on phase entry only
**Today:** `code-dev-pr-review.cmp.md` (23 KB / ~5,760 tokens) loads in full at invocation, even if user only runs P9 (document).

**Workflow:**
- Compile P1–P9 as separate sub-programs (`pr-review-p1.cmp.md` … `pr-review-p9.cmp.md`).
- Top-level `pr-review.cmp.md` becomes a small router (~1 KB) that EXECs only the requested phase.
- Default invocation runs P1→P9 sequentially with checkpoints, loading each in turn.

**Est. savings:** 60–80% off a single-phase invocation (`--phase 9`).

## CW3 — Shadow result cache
**Today:** every `code-dev-*` that needs symbols for file X calls `TOOL(shadow, show)` which reads the `.findings.md`. Re-read each program.

**Cache scheme:**
- key: `(shadow-dir, rel-path, content-hash)`
- in-process LRU (per-session)

**Est. savings:** 20% off `plan`, `impact`, `pr-review` P2.

## CW4 — Git-state cache (mtime-keyed)
**Today:** `git branch --show-current`, `git status --porcelain`, `git rev-parse HEAD` are called 5–10×/session each.

**Cache scheme:**
- key: `(codebase, op)`
- invalidate: any change to `mtime(.git/HEAD)` or `mtime(.git/index)`
- store in `W:code-dev-git-cache`

**Est. savings:** 20–30 subprocess hops/session; trivial token, large latency.

## CW5 — Reviewer-state JSON sidecar
**Today:** preflight Gate 6 + reviewer-track + pr-respond each parse `reviewer-state.md`. The full markdown table is read every time.

**Cache scheme:**
- Maintain `reviewer-state.json` alongside `reviewer-state.md`.
- `pr-review` / `pr-respond` write both; readers prefer JSON; staleness detected by `(mtime(.md) > mtime(.json))`.
- Direct lookups: `reviewer-state[pr=PR-N, status=open]` → one row, ~100 B.

**Est. savings:** 50–70% off reviewer-state parsing in preflight + reviewer-track.

## CW6 — Resume briefing cache
**Today:** `code-dev-resume` reads 10 files unconditionally. Inside a single session (no compaction), the briefing is unchanged.

**Cache scheme:**
- store: `W:code-dev-resume-briefing`
- key: `(mtime(_meta), mtime(04-log))`
- on hit: emit cached briefing + recompute only the deltas (last marker line, branch state)

**Est. savings:** 50% off second-and-later `resume` calls in a session.

## CW7 — Preflight short-circuit on quick mode
**Today:** `--quick` runs gates 0–4 only — implemented but the *render* still prints the full table headings. Output token savings small.

**Workflow:**
- Add `--mode=summary` that emits `pass/fail/N-warnings` in one line.
- Used by `pr-ready` wrapper — only needs to know "OK to proceed?".

**Est. savings:** ~80% on `pr-ready` output tokens.

## CW8 — Compile-pass gate: refuse negative compression
**Today:** `code-dev-pr-review.cmp.md` actually *grew* during compilation. Compile pipeline should refuse the artifact.

**Workflow (kernel-side, but unblocks code-dev):**
- `compile-write` adds: if `cmp.bytes > src.bytes` → write `compiled/quarantine/<name>.cmp.md` instead.
- Surface in `code-dev metrics` ("compilation losses").

**Est. savings:** prevent regression; flag existing offender.

## CW9 — Read-batch in `pr-review` P1
**Today:** Phase-1 reads PR tracking + 04-log + upstream state + file list as 4 separate reads.

**Workflow:**
- Single CONCAT-FILES-style batch read into one buffer, then EXTRACT sections.
- Lower I/O overhead; cleaner in compiled form (one fence instead of four).

**Est. savings:** small (~5% off P1), but tidies the program.

## CW10 — Embedding/bm25 sub-index in shadow
**Today:** `plan` and `impact` rank files by heuristics + filename. Many irrelevant files end up in the analysis set.

**Workflow:**
- On `shadow refresh`, also compute bm25 (or embedding) over each finding's "summary" section.
- `plan` queries with the study goal text → top-N most relevant files.
- `impact` queries with the PR spec changes → top-N callers/callees candidates.

**Est. savings:** 30–50% off `plan` reads (fewer files brought into context).

## CW11 — Streaming log tail
**Today:** `04-log.md` is read in full to find the last SESSION marker; on a long project this is many KB.

**Workflow:**
- Read TAIL N lines (e.g. 200) by default; only read full file if marker not found.
- Update `_meta.last-marker-byte-offset` so the reader can `seek` next time.

**Est. savings:** 20–40% off `resume` and `since` reads on long-running projects.

## CW12 — `code-dev next` minimum context
**Today:** `next` loads enough context to render the 10-moment classifier (similar to status).

**Workflow:**
- Pre-compute the next-action hint when any write program runs and store in `_meta.next-action`.
- `code-dev next` becomes: read `_meta.next-action` + emit it (≤ 200 B read total).

**Est. savings:** 90% off `next` calls.

## CW13 — Inline tiny sub-programs at compile time
**Today:** `preflight → EXEC(scope-check)`, `EXEC(self-review)`, `EXEC(suggest-tests)` triggers 3 program loads.

**Workflow:**
- At compile time, if a callee's compiled body ≤ 1.5 KB and is called ≥ 1× by the caller, inline it.
- Compiler annotates `# inlined: code-dev-scope-check` for traceability.

**Est. savings:** ~3 program-load hops on every preflight invocation.

## CW14 — `code-dev finalize` batched final pass
**Today:** Post-merge runs 4 commands. Each loads its own program.

**Workflow:** one `finalize.cmp.md` that fuses merge + cascade + changelog + audit, sharing the project state read once.

**Est. savings:** ~40% off the final-pass step (vs running each separately).

## CW15 — Cron-driven warm cache
**Workflow:** nightly cron runs `shadow refresh` + warm `_meta.next-action` per active project. Morning session opens with caches valid; first `resume` is a cache hit.

## Aggregate (cycle-3 cache + split estimates)

| Layer            | Token cut (rough) |
|------------------|--------------------|
| Read cache (CW1) | -25% across reads  |
| pr-review split (CW2) | -60% on partial runs |
| Resume briefing cache (CW6) | -50% on warm resume |
| reviewer JSON (CW5) | -60% on Gate 6/7 |
| Shadow LRU (CW3) | -20% on plan/impact |
| Preflight inline (CW13) | -3 hops, ~10% off preflight |

Roughly **-30% session token cost** if CW1+CW2+CW5+CW6 ship.

→ ranked + sequenced in `cd-c3-p3-improvements.md`.
