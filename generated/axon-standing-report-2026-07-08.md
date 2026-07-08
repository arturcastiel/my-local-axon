# AXON Standing Report — hr-team full audit
Date: 2026-07-08 · Council: 6 seats (systems architect · quality engineer · product/UX ·
research strategist · risk/safety officer · Challenger), each auditing live repo evidence
independently · Step-0 re-verification applied to load-bearing claims (4/4 confirmed) ·
Dissent preserved verbatim below.

---

## 1. WHERE AXON STANDS

### The consensus picture (5 seats converge)
AXON is, mechanically, in the best shape of its life — and strategically at its most
exposed. The two-day bugfix campaign (49 PRs), the quarantine disposition, the meta
migration, and the flaky-gate root fix leave:

- **A finished gate wall.** 37 crucible controls (24 BLOCK / 13 WARN, keystone-clean:
  every WARN carries a reason or a promote condition). The reader/writer contract-drift
  class — the dominant defect family of both audits — is BLOCK-enforced end to end
  (argparse flags, output fields, memory keys, shell results, meta writes, liveness,
  EXEC args), with **every grandfathered baseline burned to empty**.
- **A truthful self-report layer.** Every dashboard the owner reads (menu, status, stats,
  gain, board, session-summary, resume) now reads data that exists; honesty beat
  cosmetics (the metric pipeline says "not wired" instead of rendering plausible zeros).
- **A byte-stable suite.** ~5104 tests, 0 failed; after the root fix the full suite no
  longer touches the repo at all (two proof runs, byte-clean tree). The retry band-aid
  is gone and pinned against return.
- **Real-but-thin external output.** graphify-obsidian and flowsim-vectorize shipped;
  cpg2python work ran through code-dev on the for-use instance; three reference
  libraries ingested. "Zero external value" is false — but the flow is a trickle
  against a torrent of self-work.

### The dissent (Challenger, verdict preserved verbatim in spirit and numbers)
> The hostile thesis survives ~70%. 154/176 tools (87.5%) serve the OS itself; ~47 of
> the last 50 commits touch self-machinery; all 4 projects ever FINISHED are axon-self;
> the falsification test was locked with power analysis 40 days ago and never run while
> 49 self-PRs shipped; self-monitoring wrote literal unrendered template strings into
> its own logs for six weeks. The two celebrated bugfix projects fixed defects in AXON,
> found by AXON's audits of AXON — a closed loop.

Conceded by the same seat: the epistemic hygiene is real ("most projects this
self-referential also lie to themselves; this one doesn't"), the platform's ratchets/
ledgers/gates made a 49-PR burn auditable and reversible, and external deliverables
exist.

### Verified-during-audit finds (fixed or filed)
- **FIXED (this session):** doc-index indexed gitignored `workspace/log/` — the
  committed DOC-INDEX went deterministically stale with every day of normal use (a
  false-RED-at-rest class the race fix didn't cover). Excluded + regression-pinned.
- **Stale-doc drift confirmed:** the benchmark guide still says "prompt-level only"
  while the rigorous `--axon-arm mcp` is merged (preflight verdict 2026-06-01) — the
  pitch document undersells the built artifact.
- **Safety gaps confirmed live:** the shell gate does not classify `find -delete` /
  `rsync --delete` as writes; the kernel floor is conditional on the agent-writable
  dev-mode flag in attended sessions; programs have no prompt-injection/provenance
  guard. (Filed as next steps N-S1..S3 below.)
- Closed as resolved: the flaky-gate todo (root-fixed 2026-07-08).

### Standing one-liner
**The machine is sound, honest, and guarded — and it has spent almost all of its life
proving that about itself. The single missing artifact is external evidence.**

---

## 2. RISK REGISTER (cross-seat, ranked)

1. **Unvalidated core claim** (research + challenger, independent convergence): the
   entire strategic thesis — TNO value, paper, axon-million — queues behind a locked,
   pre-registered, $1–13 experiment that has never been run. Every further self-PR is
   itself evidence for the hostile thesis.
2. **Prompt-injection via program files** (safety): executable .md programs are
   gate-legal writes with no content/provenance guard; a poisoned program executes in a
   later session with shell access. The OS's extensibility is its attack surface.
3. **The LLM-interpreted semantic layer is a verification blind spot** (architect +
   quality): `≡` case-sensitivity, EXEC-section semantics, interpreter leniency are
   untested; a host-model swap silently changes OS behavior; content pins freeze fixed
   text but cannot catch behavioral regressions.
4. **Author-only lock-in** (product): no non-author has ever booted AXON; the
   cold-start stranger test has been open for 2+ weeks; onboarding surface is
   speculative until it runs (or is formally dropped).
5. **Unobservable agent-side execution** (architect + product): with no usage recorder,
   the next drift/pruning round costs another manual audit campaign — the expensive
   process just completed twice.
6. **Deletion blind spots + standing grant** (safety): non-rm deletion verbs invisible
   to the gate; grant has no TTL/budget (active 16+ days); delegated destructive acts
   emit no receipts.

---

## 3. NEXT STEPS (council-ranked)

### Tier 1 — the decisive week (do before any further self-hardening)
1. **RUN THE BENCHMARK** (S — days; research seat + Challenger veto, independent
   convergence). Convert the pending TNO discussion into a 30-minute decision (the four
   questions are already in the guide); run the pre-registered pilot with the merged
   `--axon-arm mcp` (subscription path ≈ $0 marginal); commit the report to
   `benchmark/reports/` whatever the verdict. Include the 1-hour guide-doc fix (the
   stale "prompt-level only" caveat). *The Challenger's veto condition: no new
   lint/gate/audit merges until this exists.*
2. **Run the cold-start stranger test — or formally declare author-only** (S; product).
   Cheapest decisive experiment in the backlog; the research seat's co-author
   recommendation pairs with it (recruit the TNO/TU-Delft co-author AND use them as the
   stranger — one move, two risks killed).

### Tier 2 — close the verified safety gaps (small, this month)
3. **Deletion-verb gate coverage** (S; safety N1): classify `find -delete`,
   `rsync --delete`, `shred`, `xargs rm`, bulk `rm -rf` under workspace/ as
   write/destructive segments + a bulk-delete threshold.
4. **Grant TTL/budget + receipts for delegated destructive acts** (S; safety N3).
5. **Program-integrity tripwire** (M; safety N2): reviewed-hash manifest over
   workspace/programs/*.md, advisory→BLOCK staged — the minimum viable
   prompt-injection guard.

### Tier 3 — the platform's next real capability (pick after Tier 1's verdict)
6. **Interpreter conformance harness** (M; architect N1 + quality N3): a probe battery
   for the LANG-underspecified semantics + golden-transcript replay pins for the
   top-dispatched programs — behavior pins, not text pins; the portability contract
   before the next model change.
7. **Stop-hook as the honest recorder** (S–M; architect N2): extend verify_stop.py to
   write the spec'd turn-log rows (T-n/prog/IN/OUT) — fixes the turn-log degeneracy
   owner item AND un-stars gain/dispatch-stats without kernel per-turn cost.
8. **Write-collision ERROR class in memory-key lint** (M; quality N2): the writer/writer
   half of the contract family.
9. **Kernel truth sweep** (S; architect N3): wire-or-excise the process-subsystem kernel
   text; dedupe the dag-consistency twin controls; annotate every kernel gate with its
   real enforcement tier.

### Explicitly parked (owner-only)
- Kernel-protocol usage recording (ADR-001 alternative) — superseded if #7 lands.
- Turn-log writer kernel spec fix — folded into #7.
- bugfix01 residual: the 5 permanent-class liveness allowlist entries (documented).

---

## 4. SEAT LEDGER (confidence · headline)
- Systems architect · 8/10 · "Contract seams mechanically gated, ratchet finished;
  the language substrate itself is the largest uncovered class."
- Quality engineer · 8/10 · "Gate wall keystone-clean; found + attributed a live
  false-RED accretion class during the audit" (fixed same session).
- Product/UX · 8/10 · "Self-report trustworthy at last; the product has never been
  felt by anyone but its author."
- Research strategist · 8/10 · "Publishable-grade methodology, never run; SOSP window
  missed while paused; everything queues behind a $1–13 experiment."
- Risk/safety officer · 8/10 · "Autonomy stack real and verified live; deletion-verb
  blind spot, conditional kernel floor, and zero injection defense are the gaps."
- Challenger · 7/10 · "~70% of the hostile thesis survives; freeze self-hardening
  until the benchmark runs."

## 5. AUDIT TRAIL
Seats ran as independent read-only auditors 2026-07-08; Step-0 re-verification
confirmed: doc-index red-at-rest (fixed, pinned), unrendered template strings in 4
daily logs (challenger), merged MCP arm (research), 87.5% self-ratio from the live
registry (challenger). One product-seat recommendation was already stale at delivery
(the flaky gate — root-fixed earlier the same day; its todo closed). Session-limit
note: none — all six seats completed.
