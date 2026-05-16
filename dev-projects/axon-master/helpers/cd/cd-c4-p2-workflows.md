# CD·C4·P2 — target end-state workflow

> Aspirational future workflow assuming the cycle-3 top-15 + key cycle-2 items have shipped. Same lifecycle, fewer commands, more automation, lower token cost.

## End-state lifecycle (compact)

```
project birth ────────────────────────────────────────────────────────
  code-dev new <slug>                                  (unchanged)

phase 1 — study ───────────────────────────────────────────────────────
  code-dev study           (shadow + bm25 ranking; embedding optional)
  ↓ confidence loop

phase 2 — plan ────────────────────────────────────────────────────────
  code-dev plan            (bm25-ranked candidate files)
  code-dev plan-master     (masterplan DAG render — Mermaid)
  code-dev phase new       (or auto-derived from plan)

phase 3 — PR spec (single PR or stack) ────────────────────────────────
  code-dev pr 1
  code-dev pr 2 --depends-on 1                  ← stack-aware
  code-dev pr-stack restack                     ← emit restack script
  code-dev explain N       (optional)

  ── HUMAN implements ──

phase 4 — review + log ────────────────────────────────────────────────
  code-dev log             (drift detection)
  code-dev review N        (scope + self + suggest-tests + coverage-delta + test-from-diff)
  code-dev pr-review N     (split P1–P9 sub-programs — load only what's needed)
  code-dev pr-respond N    (auto in reviewer-bot loop)

phase 4.5 — preflight ─────────────────────────────────────────────────
  code-dev preflight --mode=summary       ← 1-line out
    (Gate 3 [scope] prohibitions now mechanical)
    (Gate 8 includes coverage-delta gate)
    (Gate 11 conflict-predict for stacked PRs)

phase 5 — finalize ────────────────────────────────────────────────────
  HUMAN: git push
  code-dev finalize PR-N             ← merge + cascade + changelog + audit, one verb
  code-dev release start v1.2.0      (when ready)
  code-dev release tag

cross-cutting ─────────────────────────────────────────────────────────
  code-dev next            ← reads _meta.next-action (one file, fast)
  code-dev resume          ← cached briefing if mtimes unchanged
  code-dev pr-list         ← cross-phase aggregator
  code-dev metrics         ← runs · duration · tokens · shadow rate · reviewer rounds
  code-dev actions [N]     ← inspect _actions.log
  code-dev migrate-v4      ← legacy v1 → v4 (dry-run default)
```

## Event flow (end state, post-D-A1)

```
code-dev pr-respond  ── EMIT(reviewer-objection-resolved) ──┐
code-dev preflight    ── ON(reviewer-objection-resolved) → re-eval Gate 6/7
code-dev merge       ── EMIT(pr-merged) ──┐
                                           ├─ ON → code-dev cascade
                                           └─ ON → code-dev changelog
code-dev freeze      ── EMIT(phase-frozen) ─→ cron reminder
code-dev migrate-v4  ── EMIT(schema-upgraded)
shadow refresh       ── EMIT(shadow-fresh)
```

## Cron (end state, T-F1/F2)

```
# Daily 03:00 — warm caches
0 3 * * *   shadow refresh per active project; warm _meta.next-action

# Weekly Sunday 04:00
0 4 * * 0   code-dev metrics --rollup --emit-igap-if-drift

# Monthly 1st 05:00
0 5 1 * *   code-dev pr-archive --older-than 90d
```

## Caching layers (end state)
- **W:code-dev-cache-<sha8(path)>** — (path, mtime) keyed reads.
- **W:code-dev-resume-briefing** — full briefing, (mtime(_meta), mtime(04-log)) keyed.
- **reviewer-state.json** — JSON sidecar; .md stays as the human-readable rendering.
- **W:code-dev-git-cache** — (codebase, op) keyed; invalidated by mtime(.git/HEAD), mtime(.git/index).
- **bm25 sidecar** — `shadow/src/<rel>.embed.json` next to `.findings.md`.

## Token budget (target after improvements)

|                                | today          | end-state    | Δ |
|--------------------------------|---------------:|-------------:|--:|
| `code-dev-pr-review` per run   | ~5,760 tokens  | ~2,000 (single phase) | -65% |
| `code-dev-resume` warm run     | ~2,790 tokens  | ~1,400 (cache hit)    | -50% |
| `code-dev preflight --summary` | ~1,750 tokens  | ~300         | -83% |
| `code-dev next`                | ~600 tokens    | ~80          | -87% |
| Typical PR-build session       | ~25–30 KB tokens | ~17–20 KB  | -30% |

## Cross-system handoffs (end state)
- **library-dev → code-dev:** `library-dev report --as code-dev-pr-draft` → `code-dev pr-import`.
- **code-dev → axon-audit:** metrics feed usefulness score.
- **code-dev → events bus:** wired (D-A1).
- **code-dev → cron:** nightly maintenance (T-F1/F2).
- **code-dev → igap:** low-confidence moments recorded (D-A3).
- **code-dev → usage / dispatch:** runs recorded; compile-suggest sees real workload (D-A2).

## What stays exactly the same
- Schema v4 — additive only; no breaking changes.
- HUMAN-only git push / merge / tag.
- AXON safety rules (CORE RULES, write-gate, dev-mode).
- 57 program surface (we add ~10, do not remove any).
- Markdown as the lingua franca (JSON only as a *sidecar* where parsing was expensive).

## Migration path (one phase at a time)
1. **Substrate integration** (D-A1..A4) — invisible to user.
2. **Compile-pipeline gate** (T-A3) — protects future compiles.
3. **Quarantine + split pr-review** (T-A1 + T-A2) — biggest single token win.
4. **Caches** (T-B1..B3, T-B5..B6) — invisible to user.
5. **UX commands** (D-B1 pr-list, T-C1/C2 summary modes) — visible.
6. **Quality gates** (D-C4..C9) — strengthen preflight.
7. **PR-stack** (D-E1) — net-new capability.
8. **Reviewer-bot loop** (D-E2) — net-new capability.
9. **Release workflow** (G-CD-A4) — net-new capability.
10. **library-dev bridge** (D-B4) — net-new capability.

→ ranked top-15 in `cd-c4-p3-improvements.md`.
