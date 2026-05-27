# Masterplan — axon-finish (all remaining activities, consolidated)

> The single source of "what's left." Built from the cross-project survey + the
> existence-check. **Finding: the ~142-PR backlog is mostly phantom** — stale records,
> not missing code. The real remainder is small and gated. Tiers are ordered by what
> *gates* each item, not by project.

## Baseline (what's already true)
tno/main green **4607** · **126 tools** · 207 programs · **0 FAIL** · freshness + coherence
clean · compass **structural 97 / usage 0**. Shipped this arc: the reframe (conformance
layer), the response floor, harness adapters + apply-scripts (applied live), menu +
onboarding, memory-sync (applied live), freshness orchestrator, PR #102 (R_PROJECT_ANCHOR),
the compass, and the phase-7 proprioception trifecta (control-strip · anticipation · trace).

---

## Tier A — autonomous, bounded (closeable now, test→merge)
- **firing-dag-missing** — find every code-dev path that skips DAG auto-emit; fix. (audit + emit-fix)
- **axon-wiring-gaps** — wire `W:code-dev-codebase`; audit read-but-never-written memory keys. (audit + fix)
- **record-reconciliation** — mark the stale-status specs across projects (axon-synapse "ready-for-review", axon-polish "active", axon-ascent done) as merged, so records match reality. (bookkeeping)
- **code-gap triage** — the 19 TODO/XXX/xfail markers in tno/main: close the worth-closing, document the rest.
- Exit: the few real autonomous gaps closed; every project record honest.

## Tier B — usage-gated (needs real operation — cannot be built in a checkout)
- **feed the loops** — populate the dispatch index + usage/prompt logs by real use. (the organism's food)
- **ranker-v2 / anticipation calibration** — tune thresholds from predicted-vs-actual data once the loops have data.
- **the autonomous cycle** — measure → close-gaps → grow on cron, gated auto-actions. (axon-ascent 7-circulation engine)
- Exit: usage_score rises off zero; anticipation self-calibrates; the loop sustains itself.

## Tier C — human-gated (yours / kernel / review)
- **axon-master** — 54-PR kernel-scale plan, "waiting on HUMAN to start."
- **axon-memory #96** (kernel load-wire) · **axon-docs PR-S01** (commit) — your merge/commit.
- **artifact-guard** — kernel artifact-scan gate (axon/ edit).
- **4 consistency/persona studies** (claude-code, copilot-anchor, copilot-consistency, deviation) — strategy + kernel rules.

## Tier D — product / the million-dollar path
- **cross-host coherence demo** — catch a real conformance violation across two hosts + re-project a drift-free set. *The killer proof artifact.*
- **a public number** — SWE-bench (infra) or a measured token/fidelity result for AXON-LANG. *Proof of the thesis.*
- **packaging** — `axon install` / first-boot consent installer wrapping the apply-scripts (easy, never silent).
- **positioning** — lock the lead line ("conformance layer / git+CI for your agent's constitution"); the multi-altitude pitch (axon-pitch.md).

## Tier E — external / domain / reframe-retired (out of the AXON core)
- **reservoir-eng** (petroleum domain) · **cpg-to-unstructure** (external repo) · **lab2-01…20** (elifoot + lab tooling).
- **axon-ascent P5–P6** (SWE-bench infra, ecosystem) — de-emphasized by the reframe (host commoditizes them).

---

## The path
**Tier A now (autonomous)** → **Tier B as usage accrues (you operate it)** → **Tier D toward the product**.
Tier C waits on you; Tier E is out. The honest shape: the *system* is essentially finished;
"finishing AXON" now means **exercising it (B)** and **proving + packaging it (D)** — not a build-pile.
