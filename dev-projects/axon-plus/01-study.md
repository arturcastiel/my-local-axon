# Study — Axon Plus
Updated: 2026-06-11 · Method: owner goal-interrogation (8 goals, hardened one-by-one) · AXON: 10/10 · User: 10/10

## Goal
Make AXON cheaper, more discoverable, more self-improving, more robust across model
tiers, and cleaner — eight hardened goals, A→H, each with explicit acceptance shape.
Codebase: AXON itself. (Context: follows graphify-obsidian, same session, 10/10 PRs.)

## Goals (hardened — full interrogation record in goal-ledger.md + chat log 2026-06-11)

### A — tokens ★TOP
Instrument FIRST: baseline scenario suite in tokens (boot→menu · full code-dev PR cycle ·
study session · chat turn). Targets derived from data, proposed for sign-off. Every
optimization ships an equivalence test — protected core AS CI: gates full-strength ·
audit complete (lossless compression allowed) · behavior-equivalent · identity
uncompressed · menu/UX content stays rich (optimize production cost, never content).
Known levers from prior observation: compile pipeline at 0/191 · menu = ~10 probes +
386-line read · verbose tool envelopes · program re-reads (no program shadows) ·
kernel re-anchor cost. Scenario pin (census 2026-06-11): no prompt-log corpus exists
on disk (despite prompt-log enabled=true — verify, possible F finding), so the
chat-turn scenario is SCRIPTED + fixed, not a replay of real logs.

### B — discoverability+
Proactive contract: phase-transition tips + persistent ranked footer (≤3, PR-112
machinery) + situation-triggered hints (≤1/response, deduped, each with why +
how-to-run). No digest. Reactive layer (dispatch-phrases, sibling cross-links) scales
from the pr-6 pilot to the full code-dev/workflow/modes surface.

### C — loop-prompting
Convergence contract (target predicate + progress metric + iteration budget) + an easy
loop designer over existing substrate (UNTIL/EVAL/RETRY, goal tool, loop-receipts,
multiple-code-dev). Plateau → ADAPTIVE REPLANNING (strategy may change autonomously);
only budget exhaustion halts → convergence report. Budget human-set, hard, never
self-raised. Receipts per iteration. Wired into code-dev + workflows.

### D — modes-expansion
Ship bar: evidenced need (igap/usage/owner) · declared token budget · extends existing
surface. Anchor CONFIRMED: GOAL-DEFINE — interrogation-style goal hardening as a
reusable mode (intake → organize → one-fork-per-turn interrogation with live evidence
probes → hardened goals with acceptance). This session is the prototype.
SCOPED GOALS/CONSTRAINTS ARCHITECTURE (owner delegated, decided 2026-06-11):
  - Three scopes: GLOBAL registry (structured constraints ledger — successor to
    dont-do/won't-do fragments; gate-readable; changing it is itself gated) ·
    PROJECT (study output) · PHASE (study/plan/implement/review each carry their
    own small checklist).
  - AUTO-ROUTING: users never pick the scope — goal-define assigns each hardened
    item to global/project/phase. Users state wants; the mode files them.
  - TEETH tiered: mechanical lint/gate where checkable ("no new deps",
    "deterministic output"), advisory checklist otherwise.
  - WHY (owner's framing): easier for users — one intake, no taxonomy to learn;
    simpler for models — each phase entry renders a ~10-line scoped checklist
    instead of inferring constraints from prose. Feeds G (weak models follow
    explicit checklists) and A (less to read per phase).
Competing on evidence: study-definition modes, technical-audit mode, better
translation. Exploration of the full mode-space remains in scope.

### E — workflow-tools
Pains: authoring friction (yml + synapses) · synapse suggester proposes wrong synapses ·
poor run visibility · underpolish. Vision: conversational workflow designer —
interrogate → generate yml + synapse programs → auto-register/match → validate +
simulate; workflows carry C's convergence contract. R13 applied: auto-created neurons
ship generated contract tests or land DRAFT. Live narrated state block per step.

### F — quality-loop (G2+G6 merged)
CENSUS EVIDENCE (2026-06-11): standing queues are THIN — igap 3 entries all-time,
dead-code 19, FAILURE-MODES 4 rows, residue-lint report returned 0 (vs 27 expected
from todo — discrepancy itself is finding #1; verify). Owner's usefulness doubt was
RIGHT: the loop cannot just drain queues — it must GENERATE findings each cycle by
active scanning (axon-audit, coverage-gate, test-map across the 38 projects,
program-tool-conformance, lint family), then drain — and ADVERSARIALLY VERIFY each finding before queueing it (W0 evidence:
the census itself produced 1 false positive out of 2 findings — a probe parse error).
SHAREABILITY
ROUTING (owner): shared-surface fixes (tools/, workspace/) first-class; local-only
findings logged, not auto-built; igap locals get a "would this help everyone?"
promotion test. Autonomy RAMP: 3 cycles report-only (prepared diffs) → then S-fixes
autonomous on weekly cron (test-covered, crucible-green, undoable); M+ always owner-
ranked candidates. C's pilot: target "open findings = 0", receipts per iteration.

### G — model-robustness
Observed: older GPT-tier/Haiku-tier skip menu render (R12), deem code "too large",
MIMIC execution without running tools (R6 fabrication), self-optimize tokens → bypass.
Layer 1 mechanical floor: execution receipts (tool-emitted nonces, verifier cross-check
→ mimicry detectable) · mechanical menu-render check · Stop-hook verify.py installed-
by-default. Layer 2 tier overlay: weak model declared → strict overlay (redundant
imperatives, DO-NOT-SUMMARIZE, ack tokens). Layer 3 conformance scorecard per
model/harness (dual-agent benchmark machinery reused). A/G tension managed: A cuts
what models READ; G forbids cutting what models EXECUTE/RENDER.

### H — documentation
Evidence: "adjoint" leftovers in 6 files (axon/programs/mode-chat.md, plan-new.md,
new-chat.md, help/new-chat.md, mode-plan.md, workspace/OBJECTIVE-FUNCTION-INTERFACE.md);
38 dev-projects with uneven documentation. Census (owner/purpose/freshness per doc) →
classify keep/update/archive (deletions owner-confirmed) → stale-content sweep →
project documentation floor (every project: filled _meta + study/plan) → doc map/index
wired into freshness so rot is mechanically caught.

## Priorities (dependency-ordered)
1. A tokens (baseline first — informs B/D/G) 2. G layer-1 mechanical floor (independent,
protects everything else) 3. B discoverability 4. C loop designer 5. F quality-loop
(C's pilot) 6. E workflow designer (uses C+B) 7. D modes (uses C, evidence-gated)
8. H docs (cheap early wins possible anytime).

## Constraints
Kernel edits human-only (inviolable) · reduce-surface (D's ship bar; extend don't add) ·
R13 tests for every neuron · crucible green per merge · won't-do line intact (no
embeddings/dense RAG) · deterministic spine on gates · A's protected core is CI ·
F autonomy ramped · C budgets human-set.

## Tech Stack
Python stdlib tool layer + markdown neurons + REGISTRY + gates (crucible/verify/
freshness) · hooks (UserPromptSubmit/Stop) for mechanical enforcement · dual-agent
benchmark machinery (G scorecard) · existing: usage/dispatch-stats/gain/tokenizer (A),
PR-112 orchestrator footer (B), loop-receipts/goal/EVAL (C), workflow yml + schema (E).

## Open Questions
- A targets — set after baseline (by design).
- Scale: 8 goals ≈ multi-wave, possibly multi-project; plan phase decides split
  (candidate: G layer-1 + H census as fast first wave while A baseline runs).

## Sources
- Owner goal-interrogation, this session (raw intake → 8 hardened goals; ledger:
  goal-ledger.md).
- Same-session deep context: graphify-obsidian project (10 PRs over this codebase),
  boot/menu cost observation, compile-0/191 observation, enforcement-reality note
  (KERNEL-SLIM), grep evidence for "adjoint" leftovers.
