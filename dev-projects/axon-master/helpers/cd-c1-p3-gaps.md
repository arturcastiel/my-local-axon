# CD·C1·P3 — code-dev gaps & improvements (broad survey)

> First pass at "what's missing from code-dev". Each entry: title · symptom · proposed fix · impact (1–5) · effort (1–5) · score (I/E). Scoring same rubric as `c1-p3-improvements.md`.

## A. CRITICAL — missing core commands

| ID    | Item | Impact | Effort | Score |
|-------|------|-------:|-------:|------:|
| G-CD-A1 | **`code-dev migrate-v4`** — no automatic v1→v4 migrator; legacy projects stuck | 5 | 3 | 1.7 |
| G-CD-A2 | **`code-dev pr-list`** — no aggregated PR queue view (only per-phase `02-prs.md`) | 4 | 1 | 4.0 |
| G-CD-A3 | **`code-dev pr-stack`** — no support for stacked PRs (siblings only) | 4 | 4 | 1.0 |
| G-CD-A4 | **`code-dev release`** — no release workflow (tag, changelog roll-up, version bump) | 4 | 3 | 1.3 |
| G-CD-A5 | **`code-dev pr-archive`** — merged PRs accumulate in `03-prs/`; no archive cmd | 2 | 1 | 2.0 |

## B. HIGH — integration gaps (kernel substrate)

| ID    | Item | Impact | Effort | Score |
|-------|------|-------:|-------:|------:|
| G-CD-B1 | **events-bus wiring** — `_events.log` is a flat file; not `EMIT(pr-merged)` → ON handlers | 5 | 2 | 2.5 |
| G-CD-B2 | **igap not fed by code-dev** — many infer-or-search moments lost; gap backlog blind to code-dev work | 4 | 2 | 2.0 |
| G-CD-B3 | **usage not recorded** — `tools/usage.py` never sees code-dev runs; compile-suggest blind | 3 | 1 | 3.0 |
| G-CD-B4 | **dispatch unaware of code-dev verbs** — free-text "review my PR" doesn't route here | 4 | 3 | 1.3 |
| G-CD-B5 | **cron has no code-dev jobs** — no nightly `shadow refresh`, no weekly `metrics` | 3 | 1 | 3.0 |
| G-CD-B6 | **auto-improve doesn't measure code-dev** — `code-dev-pr-review` is the biggest compiled file but never benchmarked | 4 | 2 | 2.0 |

## C. HIGH — quality / drift gaps

| ID    | Item | Impact | Effort | Score |
|-------|------|-------:|-------:|------:|
| G-CD-C1 | **No `conflict-predict`** — merge conflicts across PR stack aren't surfaced before push | 4 | 4 | 1.0 |
| G-CD-C2 | **No `blame-since`** — git-blame integrated with project log for authorship/drift tracking | 3 | 3 | 1.0 |
| G-CD-C3 | **No `refactor-safety`** — "what's safe to refactor" given impact analysis | 3 | 4 | 0.75 |
| G-CD-C4 | **No coverage-delta tracking** — `test-map` lists files but never measures delta | 4 | 4 | 1.0 |
| G-CD-C5 | **No auto-test-suggest from diff** — suggest-tests reads acceptance, not the diff itself | 3 | 3 | 1.0 |
| G-CD-C6 | **scope-check is line-level only** — semantic scope-creep (e.g. new public API) not flagged | 4 | 3 | 1.3 |

## D. MEDIUM — UX / observability

| ID    | Item | Impact | Effort | Score |
|-------|------|-------:|-------:|------:|
| G-CD-D1 | **metrics has no token tracking** per program | 3 | 2 | 1.5 |
| G-CD-D2 | **metrics has no shadow hit/miss rate** | 3 | 2 | 1.5 |
| G-CD-D3 | **metrics has no reviewer turnaround** trend | 2 | 2 | 1.0 |
| G-CD-D4 | **No dependency-graph render** — `_pr-links.md` is a table, no Mermaid output | 2 | 1 | 2.0 |
| G-CD-D5 | **Inconsistent help** — some programs have rich `## HELP`, others none | 2 | 2 | 1.0 |
| G-CD-D6 | **handoff is heavy** — packs project+phase+reviewer+shadow stats every time | 2 | 2 | 1.0 |

## E. MEDIUM — multi-agent / orchestration

| ID    | Item | Impact | Effort | Score |
|-------|------|-------:|-------:|------:|
| G-CD-E1 | **No reviewer-bot loop** — pr-review → pr-respond → re-check is manual every round | 4 | 4 | 1.0 |
| G-CD-E2 | **No `parallel` mode** — sibling PRs can't be worked simultaneously safely | 3 | 4 | 0.75 |
| G-CD-E3 | **No `reviewer-assign`** — no routing to specific reviewer agent | 2 | 2 | 1.0 |
| G-CD-E4 | **No `sync-from-remote`** — pulling upstream branches is HUMAN-only and uncoached | 2 | 2 | 1.0 |

## F. MEDIUM — cross-system handoffs

| ID    | Item | Impact | Effort | Score |
|-------|------|-------:|-------:|------:|
| G-CD-F1 | **library-dev → code-dev** — research findings can't become PR drafts | 4 | 3 | 1.3 |
| G-CD-F2 | **plan (workspace plan) ↔ code-dev** — separate phase abstractions, no bridge | 3 | 3 | 1.0 |
| G-CD-F3 | **code-dev → axon-audit** — code-dev metrics not part of `axon-audit` usefulness score | 2 | 1 | 2.0 |

## G. LOW — schema / file-layout polish

| ID    | Item | Impact | Effort | Score |
|-------|------|-------:|-------:|------:|
| G-CD-G1 | reviewer-state stored as markdown — JSON would index faster | 3 | 3 | 1.0 |
| G-CD-G2 | shadow findings stored as markdown — YAML/JSON cache would beat re-parse | 3 | 4 | 0.75 |
| G-CD-G3 | `_actions.log` is opaque text — would benefit from a small reader CLI | 2 | 1 | 2.0 |
| G-CD-G4 | `_events.log` lacks a typed-schema header (kinds are convention only) | 2 | 1 | 2.0 |

## TOP 12 (sorted by score)

| Rank | ID | Item | Score |
|------|----|----- |------:|
| 1  | G-CD-A2 | `code-dev pr-list` (queue view)              | 4.0 |
| 2  | G-CD-B3 | record usage from code-dev runs              | 3.0 |
| 3  | G-CD-B5 | cron jobs: nightly shadow refresh + metrics  | 3.0 |
| 4  | G-CD-B1 | wire `_events.log` into kernel event bus     | 2.5 |
| 5  | G-CD-B2 | feed igap from code-dev infer moments         | 2.0 |
| 6  | G-CD-B6 | benchmark code-dev compiled programs          | 2.0 |
| 7  | G-CD-A5 | `code-dev pr-archive`                          | 2.0 |
| 8  | G-CD-D4 | Mermaid render of `_pr-links.md`               | 2.0 |
| 9  | G-CD-F3 | code-dev metrics into axon-audit               | 2.0 |
| 10 | G-CD-G3 | reader CLI for `_actions.log`                  | 2.0 |
| 11 | G-CD-G4 | typed schema for `_events.log`                 | 2.0 |
| 12 | G-CD-A1 | `code-dev migrate-v4` migrator                | 1.7 |

## What this list is NOT
- Not language plugins (the system is intentionally language-agnostic).
- Not git operations the agent shouldn't do (push / rebase / merge stays HUMAN).
- Not test execution (CORE RULE: build/test is human's job).

→ deeper, schema-aware analysis in `cd-c2-p3-gaps.md`.
