# CD·C3·P1 — token hotspots (measured)

> Real byte measurements taken on `2026-05-16`. Compares each code-dev compiled `.cmp.md` to its source; flags negative-compression and high-cost programs.

## Compression table (measured)

| Compiled file                  | src bytes | cmp bytes | compression | verdict |
|--------------------------------|----------:|----------:|------------:|---------|
| `code-dev-pr-review.cmp.md`    | 22,856    | **23,056**| **-1%**     | ✗ **zero-compression** — bigger than source |
| `code-dev-shadow.cmp.md`       | 14,561    | 11,623    | 20%         | low |
| `code-dev-audit.cmp.md`        | 13,176    | 9,987     | 24%         | low |
| `code-dev-pr.cmp.md`           | 13,064    | 9,119     | 30%         | low-medium |
| `code-dev-init.cmp.md`         | 5,710     | 3,811     | 33%         | medium |
| `code-dev-plan.cmp.md`         | 10,711    | 6,912     | 35%         | medium |
| `code-dev-study.cmp.md`        | 19,342    | 12,088    | 38%         | medium |
| `code-dev-log.cmp.md`          | 13,307    | 7,253     | 45%         | medium-good |
| `code-dev-explain.cmp.md`      | 9,789     | 4,107     | 58%         | good |
| `code-dev.cmp.md` (router)     | 20,639    | 6,020     | **71%**     | best |

**Aggregate:**
- Total source (10 compiled): **142,955 B**
- Total compiled (10):        **93,976 B**
- Overall compression:        **34%**
- One compiled file (`code-dev-pr-review`) is a NET LOSS.

## Source-only weight (uncompiled programs)
| Program                  | src bytes | Notes |
|--------------------------|----------:|-------|
| `code-dev-resume.md`     | 11,153    | 10-layer briefing — runs frequently |
| `code-dev-branch.md`     | 7,404     | v4-only |
| `code-dev-preflight.md`  | 7,014     | 11 gates — runs frequently |
| `code-dev-new.md`        | 5,783     | one-shot |
| `code-dev-combine.md`    | 5,022     | rare |

`resume` + `preflight` together = ~18,000 B uncompiled. Both are session-frequent.

## Headline findings

1. **`code-dev-pr-review.cmp.md` has NEGATIVE compression.** Compile artifacts (priority preamble, identity locks, expanded EXEC chains) outweigh prose savings. This file should be either:
   - re-compiled with a stricter compiler pass, or
   - split into 3 sub-programs (`pr-review-context`, `pr-review-harmonize`, `pr-review-execute`) per cycle-2 finding D-C2/D-PR3,
   - or excluded from compilation entirely (router stays compiled, body stays source).

2. **`code-dev-resume.md` is uncompiled, 11 KB.** It reads 10 separate files on every invocation. Caching the briefing keyed on `(mtime(_meta), mtime(04-log))` (D-F2) would skip 8 of the 10 reads on a no-change session.

3. **`code-dev-preflight.md` is uncompiled, 7 KB.** It triggers 3 sub-EXECs (scope-check, self-review, suggest-tests), each their own reads. A one-pass compiled `preflight.cmp.md` with sub-program inlining would cut overhead.

4. **Router (`code-dev.cmp.md`) compresses 71%**, the best in the family — confirming routers are the right thing to compile.

## Repeated reads per session (estimated)

Across a typical PR-build session (study → plan → pr → log → preflight → pr-respond), the same paths are read multiple times:

| Path                                  | Reads/session (est.) |
|---------------------------------------|---------------------:|
| `<project>/_meta.md`                  | 8–12                 |
| `<project>/phases/<phase>/_meta.md`   | 6–10                 |
| `<project>/04-log.md` (tail)          | 4–8                  |
| `<project>/phases/<phase>/_dont-do.md`| 4–6                  |
| `<project>/phases/<phase>/_decisions.md`| 3–5                |
| `<project>/phases/<phase>/reviewer-state.md`| 3–5            |
| `<project>/03-prs/PR-N.md`            | 4–7                  |
| Each shadow finding file              | 2–4 (shadow hit-only)|

**Mitigation:** every read should pass through `W:code-dev-cache-<path>` keyed on `(path, mtime)`. Read-once-per-session model.

## Shadow performance economy (rough)

| Event             | Source-read cost      | Shadow-hit cost     | Savings |
|-------------------|-----------------------|---------------------|---------|
| Per source file   | 1–8 KB (read) + analysis | ~0.3–0.5 KB (findings) | ~85–95% |
| Plan (20 files)   | 100+ KB total         | ~10 KB              | ~90%    |
| pr-review (P2)    | 30–60 KB              | ~6–10 KB            | ~85%    |

The shadow system is the dominant code-dev token-saver. Negative-compression compiled files erase a chunk of those savings each session.

## Shell-call overhead

Every `code-dev` session typically invokes:
- `git branch --show-current` × 5–10
- `git status --porcelain` × 3–5
- `git diff --stat` × 2–4
- `git log -n 5` × 2–3
- `git rev-parse HEAD` × 4–8
- `git rev-parse --show-toplevel` × 3–5

These don't cost LLM tokens directly, but each subprocess hop adds latency (~50–200 ms each), and their *outputs* go into LLM context. Session-scoped cache keyed on `mtime(.git/HEAD)` and `mtime(.git/index)` would cut 20–30 redundant shell calls per session.

## Reviewer-state parsing cost

Today every preflight read parses `reviewer-state.md` with multiple regex extracts (`| open |`, `| PR-N |.* | open |`, etc.). For a phase with 20 reviewer rows × 5 rounds = 100 lines, this is cheap in CPU but adds context — full table is loaded for a single boolean. JSON + a `code-dev reviewer-status --pr N` CLI returns 1 line.

## Per-program estimated token cost

Rough (4 chars per token, source counts above):
| Program            | ~tokens (compiled or source) |
|--------------------|----------------------------:|
| code-dev-pr-review | **5,760** (compiled — bigger than src) |
| code-dev-study     | 3,020                        |
| code-dev-shadow    | 2,900                        |
| code-dev-audit     | 2,500                        |
| code-dev-pr        | 2,280                        |
| code-dev-log       | 1,810                        |
| code-dev-plan      | 1,730                        |
| code-dev           | 1,505 (compiled router)      |
| code-dev-resume    | 2,790 (uncompiled)           |
| code-dev-preflight | 1,750 (uncompiled)           |

Top-5 program load alone (pr-review, study, shadow, audit, pr) = **~16,460 tokens**. Loading the wrong file at the wrong time is the dominant code-dev cost.

→ workflows that exploit these savings in `cd-c3-p2-workflows.md`; ranked backlog in `cd-c3-p3-improvements.md`.
