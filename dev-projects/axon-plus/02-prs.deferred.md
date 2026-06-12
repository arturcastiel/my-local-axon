# Deferred / Conditional PRs — Axon Plus
Updated: 2026-06-11 · These build ONLY when their trigger condition is met (D's ship bar).

## PR-022 — D: technical-audit study mode  [M]
Trigger: ≥3 igap/usage evidence points showing audit-shaped study need, OR explicit owner ask.

## PR-023 — D: translation improvements  [S]
Trigger: documented translation failure cases (collect via F's scan battery or owner reports).

## PR-A2 — A: hash-attested warm boot  [M] (harness-agnostic)
Trigger: owner approved direction 2026-06-12; build after W2 or when A-wave reopens.
Boot emits kernel+menu hash; match → re-anchor from session digest (~800 tok), full
read only on drift. Est. −12k on warm sessions.

## PR-A3 — A: menu-as-template  [S] (harness-agnostic)
Trigger: same. Pre-rendered menu skeleton as freshness-reconciled artifact + snapshot
slot-fill; program read only on menu-logic change. Est. −3.5k every session.

## OWNER APPROVED 2026-06-12 ("append ok") — all harness-agnostic, build when A-wave reopens
## PR-A4 — A: compile the long tail  [S]
Next ~20 prose-heavy programs through the pr-7 pipeline (~20%/read each).

## PR-A5 — A: registry-first answer discipline  [S]
"What does X do" answered from the 40-token registry row; convention doc +
dispatch-phrases entry.

## PR-A6 — A: byte-stable boot prefix  [S]
Reorder boot reads to an identical cross-session block; zero cost, provider-dependent payoff.

## PR-A7 — A: per-phase context packs  [M]
One generated pack per code-dev phase (scoped checklist + state) instead of
program+meta+profile+plan reads. Pairs with PR-013's phase checklists — consider folding.

## PR-A8 — A: session-digest handoff  [M]
session-save writes the ~800-token digest A2 consumes; doubles as compaction-survival.

## PR-A9 — A: sectional reads for workspace reference docs  [S]
pr-9's TOC trick on AXON-DOCS-* (read one section per lookup, −80%).
