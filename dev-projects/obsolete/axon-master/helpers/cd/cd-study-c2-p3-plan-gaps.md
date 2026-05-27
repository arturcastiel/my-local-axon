# CD·STUDY·C2·P3 — plan-side gaps and plan-mode requirements

> The 10 plan modes that workflows above demand, and what's missing from today's `plan` / `plan-master`.

## Plan modes (proposed)

| Mode             | One-liner                                                      | Used by               |
|------------------|----------------------------------------------------------------|------------------------|
| `exploratory`    | All plausible PRs, ranked loosely                              | WF-S6                  |
| `execution`      | Ship-ordered PRs with dependencies (default)                   | WF-S1, S7              |
| `risk-first`     | Highest-severity first (security, breaking)                    | WF-S2, S3              |
| `budgeted`       | Cap output to N PRs (or N hours / N tokens)                    | WF-S9                  |
| `constrained`    | Honor rules ("no schema change", "no new deps")                | WF-S5                  |
| `multi-dev`      | Parallelize across K developers                                | team workflows         |
| `replay`         | Reissue prior plan annotated with current validity              | WF-S2, audit           |
| `cost`           | Rank by token / time cost ascending                            | budget-constrained     |
| `alignment`      | Rank by goal alignment (reads `_meta.goals`)                   | leadership review      |
| `dry`            | Plan WITHOUT writing 02-prs.md (preview only)                  | exploration            |

## Plan-side gaps

### G-P1. No mode flag
Today: `plan` emits one canonical shape.
**Close:** `--mode=execution|risk-first|...`.

### G-P2. No --from flag
Today: plan reads `01-study.md` only.
**Close:** `--from study/` (multi-file study folder); `--from inline` for ad-hoc.

### G-P3. No --budget
Today: emits everything.
**Close:** `--budget N` truncates to top-N.

### G-P4. No --rule injection
Today: plan can't honor explicit constraints.
**Close:** `--rule "no schema changes"` (repeatable).

### G-P5. No --goals reading
Today: `_meta.goals` not consulted.
**Close:** plan reads goals; `--mode=alignment` ranks by match.

### G-P6. No dependency graph emission
Today: plan emits prose; no machine-readable order.
**Close:** emit ASCII DAG + `_plan_graph.dot` (optional).

### G-P7. No replay / annotation
Today: each plan run blanks 02-prs.md.
**Close:** `--replay` reads old 02-prs.md and annotates each entry: "✓ done, → in-flight (pr-3), ↻ outdated, ✗ no longer applicable".

### G-P8. No multi-developer split
Today: plan assumes single dev.
**Close:** `--multi-dev K` splits into K independent tracks with minimal cross-deps.

### G-P9. No cost model
Today: no time/token estimate per PR.
**Close:** plan emits `est-hours`, `est-tokens` per item (heuristic).

### G-P10. No dry-run
Today: `plan` writes 02-prs.md always.
**Close:** `--dry` echoes to stdout only.

### G-P11. No epic-vs-PR distinction beyond name
Today: `plan-master` is a separate program.
**Close:** fold into `plan --epic` (Round-4 rename plan).

### G-P12. No coupling to journal
Today: prior decisions (ADRs) are not consulted when planning.
**Close:** plan reads `journal/decisions/*.md`; flags conflicts.

### G-P13. No coupling to dont-do rules
Today: plan can suggest things forbidden by `safety rule`.
**Close:** plan reads `safety/rules.md`; filters proposals.

### G-P14. No coverage of "what to study NEXT"
Today: plan doesn't suggest follow-up studies.
**Close:** plan emits a "STUDIES SUGGESTED" footer based on PRs proposed (e.g. PR touches auth → suggest security study).

## Plan-mode example: risk-first

Input:
- `study/security.md` (3 findings, severity high)
- `study/dependencies.md` (1 finding, severity critical)
- `study/tests.md` (10 untested files, severity low)
- `study/dead-code.md` (8 cleanup wins, severity trivial)

Output (`02-prs.md` under `--mode=risk-first`):
```
PR-1 [CRITICAL] Pin vulnerable dep <name> to <version>
PR-2 [HIGH]     Sanitize user input in <auth/login.py>
PR-3 [HIGH]     Add CSRF check to <api/upload>
PR-4 [HIGH]     Constant-time compare in <auth/token.py>
PR-5 [LOW]      Add tests for <module>  (×3 batched)
PR-6 [TRIVIAL]  Cleanup pass (dead code, batched)

STUDIES SUGGESTED NEXT:
  - knowledge study --mode=tests --target=src/auth (after PR-2..4)
  - knowledge study --mode=observability  (no run yet)
```

## Plan-mode example: budgeted

Input: same.
Output under `--mode=budgeted --budget=3`:
```
PR-1, PR-2, PR-3  (top-3 by risk-first ranking)

DEFERRED (next budget):
  PR-4, PR-5, PR-6
```

## Plan-mode example: replay

Input: existing 02-prs.md from a month ago + current state.
Output:
```
PR-1 ✓ MERGED (commit abc123, 2026-04-20)
PR-2 → IN-FLIGHT (pr-2 in code-dev, last touched 2026-05-14)
PR-3 ↻ OUTDATED (target file refactored; rework needed)
PR-4 ✗ DROPPED (resolved by upstream library upgrade)
PR-5 NEW (added by replay; risk from current security study)
```

## Plan-mode example: multi-dev

Input: same + `--multi-dev 3`.
Output: 3 tracks A/B/C with PRs distributed by file-set isolation:
```
Track A:  PR-1 (dep pin)         → low cross-talk
Track B:  PR-2, PR-3, PR-4 (auth) → shared module, sequential
Track C:  PR-5, PR-6 (tests/dead)  → independent
```

→ integration with `pr ready` and other gates: `cd-study-c2-p4-integration.md`.
