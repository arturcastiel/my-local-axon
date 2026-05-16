# CD·C3·P3 — token-economy backlog (ranked)

> Cycle 3 ranked improvements. Source: `cd-c3-p1-tokens.md` measurements + `cd-c3-p2-workflows.md` cache designs. Same I/E rubric.

## A. CRITICAL — kill the negative-compression file

| ID    | Item | I | E | Score | Source |
|-------|------|--:|--:|------:|--------|
| T-A1  | **Quarantine `code-dev-pr-review.cmp.md`** (worse than source) | 5 | 1 | **5.0** | C3·P1 headline |
| T-A2  | Split `pr-review` into P1–P9 sub-programs; tiny router | 5 | 4 | 1.25 | CW2 |
| T-A3  | Compile-write gate: refuse cmp.bytes > src.bytes | 4 | 1 | 4.0 | CW8 |

## B. HIGH — caching the hot reads

| ID    | Item | I | E | Score | Source |
|-------|------|--:|--:|------:|--------|
| T-B1  | Session-scoped read cache (W:code-dev-cache-*) | 4 | 2 | 2.0 | CW1 |
| T-B2  | Resume briefing cache (mtime-keyed) | 4 | 2 | 2.0 | CW6 |
| T-B3  | Reviewer-state JSON sidecar | 4 | 2 | 2.0 | CW5 |
| T-B4  | Streaming `04-log.md` tail + byte-offset hint | 3 | 2 | 1.5 | CW11 |
| T-B5  | Shadow result LRU in-process | 3 | 1 | 3.0 | CW3 |
| T-B6  | Git-state cache (mtime(.git/HEAD)) | 3 | 2 | 1.5 | CW4 |

## C. HIGH — output compression

| ID    | Item | I | E | Score | Source |
|-------|------|--:|--:|------:|--------|
| T-C1  | `code-dev preflight --mode=summary` (1-line out) | 3 | 1 | 3.0 | CW7 |
| T-C2  | `code-dev next` reads only `_meta.next-action` | 3 | 1 | 3.0 | CW12 |
| T-C3  | Compile preflight sub-program (inline scope/self/suggest-tests) | 3 | 3 | 1.0 | CW13 |
| T-C4  | Compile `code-dev-resume.cmp.md` (currently uncompiled, 11 KB src) | 3 | 2 | 1.5 | C3·P1 |
| T-C5  | Compile `code-dev-preflight.cmp.md` (currently uncompiled, 7 KB src) | 3 | 2 | 1.5 | C3·P1 |

## D. MEDIUM — shadow upgrades

| ID    | Item | I | E | Score | Source |
|-------|------|--:|--:|------:|--------|
| T-D1  | bm25-based shadow ranking sidecar (.embed.json) | 4 | 3 | 1.3 | CW10 |
| T-D2  | Per-branch shadow scoping (branch sub-dir) | 3 | 4 | 0.75 | C2·P1 §3 |
| T-D3  | Auto `shadow refresh` on `git branch --show-current` change | 3 | 2 | 1.5 | CW4 + shadow |

## E. MEDIUM — batching / aggregation

| ID    | Item | I | E | Score | Source |
|-------|------|--:|--:|------:|--------|
| T-E1  | `code-dev finalize` (merge+cascade+changelog+audit, one pass) | 3 | 2 | 1.5 | CW14 |
| T-E2  | `pr-review` P1 batched read | 2 | 2 | 1.0 | CW9 |
| T-E3  | `code-dev pr-list` reads each phase `02-prs.md` once + caches | 3 | 1 | 3.0 | D-B1 + CW1 |

## F. MEDIUM — cron warm-up

| ID    | Item | I | E | Score | Source |
|-------|------|--:|--:|------:|--------|
| T-F1  | Nightly cron: `shadow refresh` per active project | 3 | 1 | 3.0 | CW15 |
| T-F2  | Nightly cron: warm `_meta.next-action` per project | 2 | 1 | 2.0 | CW15 / CW12 |
| T-F3  | Weekly metrics rollup → igap if drift signals | 3 | 2 | 1.5 | D-A3 + D-D1 |

## TOP 15 (sorted)

| Rank | ID | Item | Score |
|------|----|----- |------:|
| 1  | T-A1 | quarantine `code-dev-pr-review.cmp.md`         | 5.0 |
| 2  | T-A3 | compile gate: refuse cmp > src                  | 4.0 |
| 3  | T-B5 | shadow result LRU                                | 3.0 |
| 4  | T-C1 | preflight `--mode=summary`                       | 3.0 |
| 5  | T-C2 | `code-dev next` reads only next-action           | 3.0 |
| 6  | T-E3 | pr-list with caching                              | 3.0 |
| 7  | T-F1 | cron nightly shadow refresh                      | 3.0 |
| 8  | T-B1 | session read cache                               | 2.0 |
| 9  | T-B2 | resume briefing cache                            | 2.0 |
| 10 | T-B3 | reviewer-state JSON sidecar                      | 2.0 |
| 11 | T-F2 | cron warm next-action                            | 2.0 |
| 12 | T-B4 | streaming `04-log.md` tail                       | 1.5 |
| 13 | T-B6 | git-state cache                                   | 1.5 |
| 14 | T-C4 | compile `resume.cmp.md`                          | 1.5 |
| 15 | T-C5 | compile `preflight.cmp.md`                       | 1.5 |

## Estimated cumulative impact

If T-A1 + T-A3 + (T-B1 ∧ T-B2 ∧ T-B3) + T-C1 + T-C2 ship:
- Per-session reads: -25% to -35%
- Output volume in `preflight`/`next`: -70%
- Negative-compression file eliminated (one-time ~5,760-token churn gone)
- Resume on warm session: -50%

Total session token cost: **-30% in the best realistic estimate**, with no behavioral change visible to the user.

## Risks

- T-A1: removing the compiled file shifts to source-mode `pr-review`; will be slower until T-A2 ships. Mitigation: quarantine instead of delete; keep a small wrapper that picks `source` when quarantined.
- T-B1..T-B3: cache invalidation bugs cause stale reads. Mitigation: strict mtime keys; no TTL.
- T-D1 (bm25): adds a code-side dependency. Mitigation: pure-python `bm25s` already exists; no model dependency.

## Cycle-4 synthesis inputs
- Top-3 from T (T-A1, T-A3, T-B5) belong in any executive backlog.
- Combined with C1 / C2 tops: produce a 15-item code-dev executive list with C1/C2/C3 prefixes.

→ executive synthesis in `cd-c4-p3-improvements.md`.
