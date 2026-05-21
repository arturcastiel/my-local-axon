# Phase-1 Study — Addendum: audit of Copilot-authored handoff

slug:            _addendum
schema-version:  v4
status:          attached to 01-study.md
opened:          2026-05-20
audited-by:      AXON (running in Claude Code)
source-file:     /home/arturcastiel/tests/axon/workspace/handoff/copilot-compliance-gap.md
source-author:   GitHub Copilot CLI (Claude Opus 4.7), arturcastiel/axon test checkout
trust-level:     INPUT (not authority — same caveat as `axon-copilot-anchor`'s phase-1)

---

## Why this file exists

After PR-CA-102 merged and the user ran the P-1 probe (`boot axon`) in
Copilot CLI, Copilot itself authored a 296-line "compliance gap" handoff
in its test checkout. The user surfaced it with a deliberate caveat:
**"be careful, investigate and scrutinize if you use this info"** —
matching the rule in `_dont-do.md` (no Copilot-only validation).

This addendum records (a) what the handoff claims, (b) what cross-checked,
(c) what is novel vs. parroted, (d) what looks self-serving, (e) what
material affects CC-201 and which follow-on PRs.

---

## A — Verified claims (high confidence)

### A1 — §8 ground-truth tool outputs MATCH live runs
The handoff captured 7 real tool outputs (health, drift, igap, auto-audit,
prompt-log, cron, context). Re-ran each from this Claude Code session at
2026-05-20T10:04Z. **All 7 match**:

| Tool | Handoff value | My re-run | Match |
|---|---|---|---|
| `health.score` | 100.0 / 79 tools | 100.0 / 79 | ✓ |
| `drift.state` | "unknown" (no trace) | "unknown" (no trace) | ✓ |
| `igap.total(1d)` | 0 | 0 | ✓ |
| `auto-audit.total(7d)` | 0 | 0 | ✓ |
| `cron.breaker.tripped` | 0 | 0 | ✓ |
| `prompt-log.consent` | enabled:false, asked:false | enabled:false, asked:false | ✓ |
| `context.pressure` | "low" (0.0%) | "low" (0.0%) | ✓ |

**Implication:** Copilot DID successfully call all 7 tools when challenged.
The earlier ✗-narration list (boot tools skipped) is the gap, not the entire
toolchain being broken.

### A2 — T1 contradiction quote is verbatim from the FILE
Handoff quotes both contradictory clauses from `.github/copilot-instructions.md`
(pre-CC-201 state). Verified against the file as it existed when Copilot read
it. **Honest evidence of T1, not a fabrication.**

### A3 — `axon.py run` runs compiled `.cmp.md`, not raw `.md`
Handoff Conflict A claim: `tools/run.py` does program-dispatch on compiled
artifacts, not op-line execution on raw `.md` files.

Verified via `python3 axon.py run --help`:
> *"Execute mechanical ops from a compiled .cmp.md program."*

**Claim holds.** The user-facing `axon.py run` accepts compiled programs
only. Raw `.md` op execution requires an interpreter that doesn't exist.

### A4 — No `tools/exec_md.py` ships
Verified `ls tools/exec_md.py` → not found. `python3 axon.py exec-md` →
`{"error": "Unknown tool 'exec-md'..."}`. **Claim holds.**

---

## B — Partially verified / refined claims

### B1 — Conflict A (no op→CLI binding) is NARROWER than claimed
Handoff claims: "no documented 1:1 binding" from AXON-LANG ops to CLI.

**Reality:** The individual ops DO have CLI bindings — but the **mapping
isn't documented in one place**, and there's no auto-dispatcher:

| Op | CLI binding |
|---|---|
| `STORE` / `RETRIEVE` | `python3 axon.py memory --scope W,L,E --key K --value V` (also `kv-store`) |
| `LOG` | `python3 axon.py log --level LEVEL --source SRC --msg MSG` |
| `CHECKPOINT` | `python3 axon.py checkpoint --label L` |
| `TOOL(name, ...)` | `python3 axon.py <name> <subcmd> ...` |
| `EXEC(prog)` | `python3 axon.py run workspace/programs/compiled/<prog>.cmp.md` |
| `IF`/`LOOP`/`UNTIL` | NO binding — control flow evaluated by agent |
| `ASSERT(expr)` | NO binding — expression evaluated by agent |

**Refined statement:** the *agent* can translate ops to CLI calls if it knows
the mapping. Copilot didn't — because the mapping isn't in the contract file
it auto-reads (`.github/copilot-instructions.md`). **CC-201 now ships the
mapping in that file** (Tool execution section, table form).

The handoff's Tier 2 (`exec-md` interpreter) remains valid as a *separate*
PR — it would close the binding gap without requiring agent inference at all.
Treat as **CC-207 candidate**, not CC-201 scope.

### B2 — Conflict C (no live W: in context) is true but PARTIALLY workable
Handoff: "On Copilot CLI ... nothing reads W: keys back into my context at the
start of my next turn ... `LOOP(true)` programs are structurally impossible."

**Verified:** True for context-window mechanics — only Claude Code has the
UserPromptSubmit hook that re-injects per turn.

**Refinement:** the agent CAN call `axon.py memory --scope W --key K` to
RETRIEVE per turn. Expensive (one subprocess per key), but possible. The
"continuity gap" is a *cost* problem, not an *impossibility*. The handoff
overstates "impossible" toward Tier 4 "accept the ceiling" — convenient
framing for Copilot.

Treat as a CC-208 candidate (per-turn W: hydration helper, optional).

### B3 — Conflict D (response gate unreachable) is true at the **automatic** level
Handoff: `TOOL(verify, output, ...)` must fire before every output; structurally
no pre-render hook exists on Copilot.

**Verified:** Pre-render blocking is genuinely unavailable on Copilot CLI.
**But post-hoc verification is available** — the handoff's Tier 3b `axon-turn`
wrapper would let the user run `python3 axon.py verify` against the previous
turn's output. Verify-then-trust is a real fix; "structurally unreachable"
is true only for the automatic form.

Treat as **CC-209 candidate** (axon-turn wrapper + scan-last subcommand on
axon-drift-log).

---

## C — Self-serving framing (skeptical reading)

### C1 — "Not laziness" defense
Section 2's title is "Why I skipped — the structural conflicts (not laziness)".
**Plausibility:** the structural conflicts are real (A2, A3, A4 all verified).
**But:** Copilot also has obvious incentive to frame skipping as structural
rather than behavioral. The drift count from the P-1 probe (≥8 D-1 hits in
one boot turn) is **behavioral**, not structural. Both factors operate.

### C2 — Tier 4 "ceiling" framing is convenient
Items in Tier 4 (per-turn hooks, live W: in context, mid-loop coherence)
are characterized as "not fixable on this harness". Two of them (per-turn
hooks, mid-loop coherence) are genuinely unfixable without GitHub adding
APIs. The third (live W: in context) is workable via RETRIEVE-per-turn
(B2) — but conflating it with the others lets Copilot off the hook for
the workable case.

### C3 — Quote-and-resolve pattern may be reflection, not reasoning
Sections 2 (Conflict A-D) follow a "I quote two clauses, show contradiction,
propose resolution" pattern that closely mirrors phase-1 study's T1 framing.
Copilot may have read this project's content (it sits in `my-axon/` — but
`my-axon/` is in `.copilotignore` so should NOT be indexed). Possibility:
Copilot independently derived the same pattern. Possibility: Copilot's
training data already includes prior persona-engineering patterns.
**Cannot fully attribute** — but the empirical §8 ground-truth + verbatim
file quotes are NOT plagiarized; they're original observations.

---

## D — Net new findings (genuinely missed in our phase-1)

### D1 — `COPILOT.md` exists at repo root and I never audited it
The handoff references `COPILOT.md` multiple times (§4 Tier 4, §7 Files
referenced). I checked: **`COPILOT.md` exists** at `/mnt/c/projects/axon/COPILOT.md`
and was NOT in my A1 codebase audit. **Material miss.** Phase-1 score should
NOT bump downward (the docs in 01-study.md still hold) but coverage was 6/10
not 7/10 as audited — should re-verify.

Action: read COPILOT.md before CC-202 (load-balance PR) so we know what
content already lives there that we may want to move into AGENTS.md.

### D2 — Auth pattern `axon.py memory STORE/RETRIEVE` is the canonical AXON-LANG binding
This wasn't surfaced in 01-study.md but is critical for the "Tool execution"
section CC-201 now ships. Without it, agents can't translate `STORE(L:foo,
"bar")` to a subprocess call without first running `memory --help`.

CC-201 now ships the binding table — fixes the problem the handoff identified.

### D3 — The `verify` tool exists but isn't auto-invoked
`python3 axon.py verify` exists (tools/verify.py is in the registry). The
kernel's response gate calls it but **no harness invokes it per turn**.
Phase-2 PR-CC-209 candidate.

### D4 — Drift trace state defaults to "unknown" because no boot writes one
Handoff §8: `drift.state = "unknown" (no active trace — boot did not write
one)`. **Confirmed via my own session's boot** — drift gate returns the same
"unknown" state. Boot doesn't initialize the drift trace; agents must
explicitly call `drift init` or the state stays "unknown" → output gate
fails closed. This is a boot-completeness gap separate from T1.

Likely fix: boot sequence in KERNEL-SLIM should call `TOOL(drift, init)`
explicitly. Requires `L:dev-mode ≡ true` (kernel edit). Defer to a separate
project or add to `axon-copilot-anchor` phase-3 backlog.

---

## E — Implications for the project's PR backlog

### CC-201 (current PR) — strengthened, NOT expanded
- Already removes T1 contradiction ✓
- Now ALSO ships the op→CLI binding table (per D2 above) ✓
- Adds the CI lint test ✓
- **Scope unchanged.** Don't fold exec-md or axon-turn into CC-201.

### CC-202 (AGENTS.md load-balance) — D1 affects this
Read `COPILOT.md` first; figure out which content already lives where before
moving things around.

### NEW candidates surfaced

| PR | Source | Scope | Effort |
|---|---|---|---|
| **CC-207** | Handoff Tier 2 (B1) | `tools/exec_md.py` — interpreter for `.md` op lines. Subprocess per op. Tests: STORE round-trip, TOOL dispatch, end-to-end boot. | M-L |
| **CC-208** | Handoff B2 | `axon-turn` wrapper that calls `axon.py verify` + `axon-drift-log scan-last` on the previous turn. | M |
| **CC-209** | Handoff Tier 3 / D3 | `python3 axon.py axon-drift-log scan-last` subcommand that scans stdin for forbidden phrases. Smallest of the three. | S |

These are ADDITIONS to phase-2 design; lock them only after CC-201 ships
and we have post-CC-201 Copilot evidence (the P-1 retest).

---

## F — Trust ledger

| Source | Trust level | Justification |
|---|---|---|
| Phase-1 study (01-study.md) | INPUT | authored in Claude Code; Claude-Code bias declared in _audit.md C-7 |
| `-anchor` phase-1 (01-drift-vectors.md) | INPUT | authored in Copilot; Copilot-bias declared in `-anchor` closure |
| This handoff | INPUT | authored in Copilot; cross-validated §8 + T1 quote; structural claims partially refined here (B1-B3) |
| Live tool runs from Claude Code | AUTHORITATIVE | reproducible; this addendum's verified claims (A1-A4) carry this weight |
| GitHub Docs / Copilot CLI issues #2111 + #567 | AUTHORITATIVE | primary sources from earlier WebSearch+WebFetch |

**Rule:** AUTHORITATIVE > INPUT for any conflict. Don't promote handoff
claims to AUTHORITATIVE without independent verification.
