# AXON — Architecture Bones & The Reframe

> Status: **living strategy document** (v2, 2026-05-25, research-integrated).
> Deep-think on the five load-bearing questions from the "are the bones sound?"
> review, now backed by four web-research probes (enforcement, compression,
> agent-OS landscape, positioning). The headline outcome is a **reframe of AXON
> away from "everything-OS"** toward a sharp, defensible, sellable category.
> Two independent probes converged on the same conclusion — that convergence is
> the basis for confidence here.

---

## 0. Executive summary — the reframe (the million-dollar shape)

**Stop selling AXON as an "OS for AI agents." Sell it as the *conformance layer for
AI agents.***

> **AXON — git + CI for your agent's constitution.**
> Keep a large, multi-host, multi-model agent-instruction system **provably
> coherent, drift-checked, and portable** — across Claude Code, Cursor, and Codex,
> and across model swaps.

- **The category (coined, problem-named — the Temporal play):** *agent conformance*
  / *instruction integrity*. Name the pain, not the machine.
- **The job-to-be-done:** "I have a sprawling, drifting set of agent instructions
  (CLAUDE.md, AGENTS.md, .cursor/rules, skills, prompts) across hosts and models,
  and no way to keep it coherent, governed, or portable. Keep it provably correct."
- **The moat:** *cross-host neutrality the labs are structurally disincentivized to
  build* (Anthropic will not help you stay portable to GPT), **plus** a genuinely
  hard *validation/conformance engine*, **proven by the fact that AXON governs
  itself** (dogfooding is the demo).
- **What to drop:** the "everything-OS" framing; "the agent reasons in a symbolic
  language"; and any pitch built on the program *registry / hooks / skills /
  subagents* — the host platforms now ship those natively (commoditized).

Why this is defensible and the everything-OS is not: the moat **cannot** be the
runtime — the host (Claude Code/Cursor) owns that, and is absorbing middleware
features into its kernel monthly. The moat is **discipline + a conformance engine +
cross-host neutrality**. Thinner than a platform, but real *if focused* — and
unserved today.

---

## 1. Positioning — describe, explain, sell (research-backed)

### 1.1 Why not "OS for AI agents"
- **The phrase is taken and the position is occupied.** Letta/MemGPT explicitly
  brands itself "LLM-as-an-Operating-System" — and it's a *runtime that owns the
  loop*, the opposite of AXON (which rides a host). Leading with "OS" walks into a
  competitor's frame and invites "isn't that just Letta / the agent runtime?"
  ([Letta](https://www.letta.com/blog/agent-memory)).
- **"LLM OS" has been an unclaimed slogan for 2.5 years** (Karpathy, Oct 2023) with
  only toy/academic implementations — because the hard part (durable cross-model
  coherence) isn't a packaging problem. Claiming the slogan inherits its vagueness
  ([Karpathy](https://x.com/karpathy/status/1707437820045062561?lang=en);
  [AIOS](https://arxiv.org/pdf/2312.03815)).
- **It overclaims and leaks.** AXON sits *on top of* the host; "OS" implies it
  replaces it / runs processes. Metaphors that promise to hide complexity get
  punished when reality leaks ([a16z leaky abstraction](https://a16z.com/call-the-plumber-weve-got-a-leaky-abstraction/);
  [Spolsky](https://www.joelonsoftware.com/2002/11/11/the-law-of-leaky-abstractions/)).
  Kubernetes *earned* "OS for the cloud" because its control plane really reconciles
  state across machines — "OS" is earned by mechanism, and AXON's mechanism is
  *conformance*, not scheduling.

### 1.2 The category move: name the problem (the Temporal pattern)
Successful dev-infra rarely creates a category from scratch — it **anchors to a
familiar frame and differentiates inside it**, or **names a real felt pain into a
category**. Temporal is the closest analog: it took hand-rolled retries/state
machines and coined **"durable execution"** — a new term for a real problem, not a
metaphor ([Temporal](https://temporal.io/blog/what-is-durable-execution);
[Dunford positioning](https://www.kathirvel.com/guide-april-dunford-positioning-framework/)).
AXON's equivalent coinage: **"agent conformance" / "instruction integrity."**

Frame-of-reference options (Dunford: positioning = choosing the "what is this
*like*?"):
- **"Git + CI for your agent's constitution"** — instantly legible to engineers;
  conveys versioning, drift-detection, tests, a single source of truth.
- **"Control plane for agent capabilities"** — precise, engineer-credible, and
  honest about sitting above the host without replacing it ([control-plane framing](https://www.redhat.com/en/technically-speaking/Kubernetes-control-plane)).
- Keep "operating layer / OS" only as a *one-breath* intuition pump, never the
  headline.

### 1.3 Multi-altitude messaging
- **One-liner:** *"Keep your AI agents coherent and portable — on any host, any
  model."* (outcome + anchor; not architecture).
- **Executive / management** (risk, governance, ROI — JTBD = "ship agent work I can
  trust and audit"): *"Your agent instructions sprawl across tools and vendors,
  drift silently, and lock you in. AXON makes your whole agent layer versioned,
  tested, provably coherent, and portable — fewer agent-caused incidents, a real
  audit trail, no vendor lock-in."* (HashiCorp sold exactly this — developer
  adoption → enterprise governance + lock-in avoidance.)
- **Engineering** (architecture, guarantees, DX — and *show*, don't tell): *"Every
  agent capability is a typed, registered, gated program in a self-checking graph —
  a type system + CI for agent behavior. Drift gates, conformance checks,
  harness-agnostic adapters. Determinism where the host allows it; a graceful
  behavioral floor where it doesn't."*
- **Investor** (market, moat, why-now): *Market* — agent infrastructure. *Why now* —
  the 2025–26 explosion of coding agents + ungovernable instruction sprawl across
  CLAUDE.md / AGENTS.md / .cursor/rules / GEMINI.md, while models churn quarterly.
  *Moat* — cross-host neutrality the labs won't build + a hard conformance engine +
  a self-governing proof. ([Sequoia "why now"](https://www.the-founders-corner.com/p/how-sequoia-turns-decks-into-deals).)

### 1.4 The unmet need (why this is real, not invented)
- Frameworks are model-agnostic only trivially (swap an endpoint); **state is siloed
  per framework** and **none ship persistent agent *identity* across models** — a
  genuine gap ([Composio comparison](https://composio.dev/content/claude-agents-sdk-vs-openai-agents-sdk-vs-google-adk);
  [framework memory silos](https://dev.to/foxgem/ai-agent-memory-a-comparative-analysis-of-langgraph-crewai-and-autogen-31dp)).
- **AGENTS.md** (now under the Linux Foundation, 60k+ repos, read by Codex/Cursor/
  Copilot/Gemini/Windsurf/Zed/Warp) gives a *shared file* — **but Claude Code still
  won't read it** (May 2026). So a multi-host shop genuinely runs *incoherent,
  drifting* instruction sets. **Nobody sells a tool that continuously validates a
  large agent-instruction system for coherence and re-projects it,
  conformance-checked, across hosts and models.** Letta gives memory, not integrity;
  AGENTS.md gives a file, not a validator ([AGENTS.md vs CLAUDE.md](https://thepromptshelf.dev/blog/agents-md-vs-claude-md/)).

### 1.5 The commoditization warning (what to NOT build a business on)
Claude Code now natively ships skills, subagents, hooks, plugins, and an official
marketplace/registry; the middleware layer is being absorbed into the kernel fast.
**The program registry / hooks / skills packaging is on a commoditization
treadmill** — do not anchor the business there ([Claude plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces);
[execution-layer thesis](https://www.taskade.com/blog/execution-layer-thesis)).
Anchor on what the platforms are *structurally disincentivized* to build:
**cross-vendor portability + a hard, independent conformance engine.**

### 1.6 Go-to-market proof
Show, don't tell — OSS-led, à la HashiCorp/dbt (Terraform's 100M+ downloads *was*
the pitch). The killer demo: **a live run where AXON catches a real conformance
violation across two hosts and re-projects a coherent, drift-free instruction set.**
The self-audit *is* the demo; "AXON is built and governed by AXON" is the proof.

---

## 2. Bone — Substrate dependency (enforce the graph)

**Problem.** The "OS" runs as instructions a host model *chooses* to follow; much of
the kernel exists to force the host to keep being AXON — fragile, token-expensive,
discretionary.

**The hard truth from research — three enforcement rungs, only two are real
([probe: enforcement](https://code.claude.com/docs/en/agent-sdk/hooks)):**
1. **Output format** — mechanically enforceable *only with decoder access* (logit
   masking: Outlines/llguidance/XGrammar). **Behind Claude Code's CLI we have none.**
   We get only what the vendor exposes: OpenAI `strict:true` and Anthropic's
   constrained tool-use (Nov 2025) → **typed tool-call arguments**. Useful for making
   the capability-graph calls schema-valid; says nothing about *which* capability or
   *why* ([OpenAI structured outputs](https://openai.com/index/introducing-structured-outputs-in-the-api/); [JSONSchemaBench](https://arxiv.org/pdf/2501.10868)).
2. **Side-effects (tools/state)** — **enforceable via hooks, and this is the
   strongest lever.** A Claude Code `PreToolUse` hook runs *our* deterministic code
   and can **`deny` a call — and deny holds even under
   `--dangerously-skip-permissions`; hooks can tighten, never loosen.** Limit: hooks
   fire on tool/lifecycle events only — they cannot constrain free text or reasoning
   ([hooks](https://code.claude.com/docs/en/agent-sdk/hooks); [bypass-block](https://pasqualepillitteri.it/en/news/1832/claude-code-dangerously-skip-permissions-pretooluse-hooks-2026)).
3. **Semantic / persona / program-fidelity** — **not preventable, only
   detect-and-correct after the fact.** Guardrails (NeMo, Guardrails AI, Llama Guard)
   are probabilistic I/O filters, routinely bypassed — useful as defense-in-depth,
   **not** as the enforcement substrate ([bypass evidence](https://arxiv.org/html/2504.11168v1)).

**The mechanism (ranked, research-backed):**
1. **Hooks as the kernel boundary.** Force *every* AXON capability through a tool so
   `PreToolUse` becomes a real **syscall gate** — non-bypassable, host-side. This is
   the single highest-leverage move to de-risk substrate dependency.
2. **Vendor structured outputs** for typed tool-call args (hard guarantee on format).
3. **Deterministic validate→repair** on graph/state invariants (schema, AST,
   "did the required synapse fire?"). Run 1–2 rounds (≈75% of reachable gain), then
   **hard-fail** ([V&V loops](https://timjwilliams.medium.com/llm-verification-loops-best-practices-and-patterns-07541c854fd8)).
4. **LLM-judge + filters** for fuzzy persona/tone — defense-in-depth only.

**Architecture directive:** *AXON's invariants must live in tools and hooks, not in
prose the model may ignore.* What cannot be enforced (off-persona text, mid-stream
reasoning) is **detected and re-driven**, never assumed prevented.

**The measurable compass:** *% of claimed invariants that are mechanically enforced
(Tier-1 hooks / Tier-2 structured-output) vs. instruction-only.* Drive it up. This
is honest, computable in a checkout, and directly replaces the saturated
"usefulness 73.1" proxy.

---

## 3. Bone — Symbolic layer: compression + interpreter (with the pragmatic gate)

**Decision rule (your gate): make the symbolic layer "real" *only* where it (a) is
deterministically executable, *or* (b) is measurably cheaper without hurting
instruction-following. Otherwise simplify or drop it.** The research makes this
decidable:

**1. Drop "the agent reasons in AXON-LANG."** It is unverifiable *and* the evidence
says forcing reasoning into a terse grammar **hurts**: CRANE proves constraining an
LLM to a finite/terse output grammar collapses its expressivity to **TC⁰ — it
provably can't multi-step reason inside the grammar**; "Let Me Speak Freely" shows
strict-format prompting degrades reasoning. The fix is the *opposite* of the current
mandate: **reason in free form, emit symbolic ops only inside constrained regions**
([CRANE](https://arxiv.org/html/2502.09061v1); [Let Me Speak Freely](https://aclanthology.org/2024.emnlp-industry.91.pdf)).

**2. The compression claim is honest — but MUST be measured, and may be false as
built.** Compression is real and established (LLMLingua-2: 2–5× at ~1–2 pt cost) —
*but those methods compress redundant natural language; a hand-built op-set is
abbreviation/DSL, and exotic glyphs (⊕⊗∅) can tokenize into **multiple** tokens
each, possibly costing **more**.* And compression's first casualty is
**rule-following** (constraint compliance drops while semantics look fine — the
dangerous "looks understood, silently violates" failure). **Action: measure actual
tokens with the real tokenizer (tiktoken) on real instruction files, verbose vs.
symbolic, and measure fidelity with `axon_eval`.** If the glyphs don't save tokens,
switch to plain ASCII ops; if fidelity drops, the compression has a cost to weigh
openly ([LLMLingua-2](https://arxiv.org/pdf/2403.12968); [compression compliance](https://arxiv.org/pdf/2512.17920); [gist tokens](https://arxiv.org/abs/2304.08467)).

**3. The one rigorous, cheaper "real": the interpreter.** The defensible sense of
"compute in it" is **emit-and-execute** — the model emits AXON-LANG ops and a
**deterministic engine outside the model executes them** (`EXEC` dispatches,
`STORE`/`RETRIEVE` hit real state, `TOOL` calls a real tool). This is *already*
partly real (TOOL, kv-store). Pushing *more* ops into engine-execution is the move
that **(a) makes the claim true for those ops and (b) removes substrate dependency
(Bone 1 synergy) — and it is cheaper when it replaces model-interpreted prose with a
real call.** Fine-tuning a model on the DSL is rejected: heavy, and it *breaks
harness-agnosticism* (ties AXON to one model).

**Verdict against your gate:** *Yes, make it real — but only as the interpreter
(deterministic execution), and only after measuring that the notation actually saves
tokens. Do not pursue "reasoning in symbols" (it's unverifiable and harmful), and
strip exotic glyphs if they don't pay for themselves.*

**Addendum — "reason in a *denser language* to save tokens?" (sharp question; the
answer confirms the rule).** Token-density is a property of the **tokenizer, not the
language**: on English-trained tokenizers (GPT/Claude/Llama) the visually "dense" CJK
scripts cost *more* tokens — a measured "language tax" of ~2.5× and up to ~15× for
some languages ([Petrov et al.](https://arxiv.org/abs/2305.15425)). And forcing the
*reasoning* language degrades accuracy — models reason in an English-centric latent
pivot, and constraining the form hurts ([Do Multilingual LLMs Think in English?](https://arxiv.org/html/2502.15603v1);
[Let Me Speak Freely](https://arxiv.org/abs/2408.02442)). So dense-language reasoning
is a **mirage** on Western models (only a native tokenizer like Qwen/DeepSeek flips it
— *measure first*). **The validated token lever is terser reasoning *structure*, not a
denser language: Chain-of-Draft cuts to ~7.6% of tokens, sometimes with *higher*
accuracy** (one Claude case 189→14 tokens) ([Chain of Draft](https://arxiv.org/pdf/2502.18600));
the endpoint is latent reasoning ([Coconut](https://arxiv.org/abs/2412.06769)). Both
the symbolic-DSL and the dense-language questions **converge on the same rule:
reason free (English pivot), compress at the emission/storage boundary.** If AXON
wants a real token win in its *prompting*, adopt Chain-of-Draft-style terse-step
budgets — not exotic notation.

---

## 4. Bone — Accretion vs. taxonomy → derive from the contract

**Problem.** 207 programs; organization lags growth (the menu collapsed into one
bucket until hand-mapped this session). Hand-maps don't scale.

**Fix — taxonomy as a deterministic function of a mandatory contract.** AXON already
has the **synapse** (domain/family/role). Make it the source of organization:
1. **Mandatory synapse at registration** — a gate fails on any program without a
   valid `domain/family/role` (the `registry_drift` pattern; ties to Bone 1
   enforcement).
2. **`category = f(domain, family)`** over the small, stable contract vocabulary —
   not over 207 volatile names.
3. **Generate menu/taxonomy/routing from the contract** — auto-organizing; growth
   cannot outpace organization because organization is a *derived property of a
   required contract*.

**Gap to close:** synapse coverage is 20/20 in the *test corpus* but not across all
207 *programs*. Extend contracts to every program, make them mandatory, derive the
taxonomy, retire this session's hand-maps (right bridge; the contract is the
destination). *This same structured contract is the substance behind the
"conformance" product in §1.*

---

## 5. Bone — Identity across three homes → single source + gated projection

**Problem.** Identity/knowledge lives in the core repo, private my-axon, and the
host memory slot — three homes that can drift; (c) couples to the host.

**Fix — AXON's own proven pattern: single source of truth + derived, drift-gated
projections** (do not invent a new mechanism; apply the one that governs code):
1. **Canonical home declared:** core (`axon/` + `workspace/axon-memory/`) is the
   source of truth; the others are **projections**.
2. **Projections are generated + drift-gated:** the host memory slot via
   `axon-memory-sync` (built this session); a **drift gate** verifies each projection
   matches the source (like `registry_drift`) → divergence = fail = auto-correct.
3. **Harness-agnostic:** projection *targets* are per-adapter; the *source* stays
   neutral.

**Why this is also a product, not just hygiene (probe 3):** *persistent agent
identity across models is nobody's product*, and multi-host shops have genuinely
incoherent instruction sets across CLAUDE.md/AGENTS.md/.cursor/rules. AXON's
"single source + conformance-checked projection across hosts/models" **is exactly the
unmet, defensible wedge** from §1.4. Bone 5 and the business thesis are the same
mechanism.

---

## 6. Synthesis — through-line, north star, compass

**Through-line.** Every bone is strengthened by one move: **replace instruction-hope
with deterministic, gated, derived mechanisms** — and where the host forbids
determinism, *detect-and-correct*, never assume.

| Bone | The move | Research anchor |
|---|---|---|
| 1 · Substrate | Invariants in hooks/tools (PreToolUse = syscall gate); detect-don't-prevent the rest | enforcement probe |
| 2 · Symbolic | Interpreter-execute it; measure compression; never *reason* in it | CRANE, LLMLingua |
| 3 · Taxonomy | Derive from a mandatory synapse contract | internal design |
| 4 · Identity | One source + gated projections (the code pattern) | landscape probe |
| 5 · Positioning | Sell *conformance + portability*, not "OS"; prove by dogfooding | landscape + positioning probes |

**North star.** Not "everything-OS." The sharp, defensible shape:
**the conformance & coherence layer for AI-agent instructions — provably consistent,
drift-detecting, portable across hosts and models.** This is the one bone the host
platforms will not replicate well, *because it is adversarial to their lock-in.*

**The compass (replaces the 73.1 proxy):**
- % of invariants mechanically enforced (Tier-1/2 vs Tier-3) — Bone 1.
- Synapse-contract coverage across *all* programs — Bone 3/4.
- AXON-LANG token-ratio (measured) + `axon_eval` fidelity — Bone 2.
- Projection drift = 0 across the three homes / across hosts — Bone 4/5.

**The million-dollar shape, stated once:** *AXON is git + CI for your agent's
constitution — the conformance layer that keeps a sprawling, multi-host, multi-model
agent-instruction system provably coherent and portable, defended by cross-vendor
neutrality the labs won't build and a validation engine proven by AXON governing
itself.*

---

## 7. Open questions / next experiments (the loop)

- [ ] **Measure AXON-LANG**: tiktoken token-ratio (symbolic vs prose) on real files +
      `axon_eval` fidelity. *Decide glyphs-vs-ASCII on the data.*
- [ ] **Enforcement-tier inventory**: tag every claimed invariant Tier-1/2/3; compute
      the ratio; pick the cheapest Tier-3→Tier-1 move (a `PreToolUse` enforcer).
- [ ] **Synapse coverage** across all 207 programs; make the contract mandatory.
- [ ] **Interpreter map**: list AXON-LANG ops by engine-executed vs model-interpreted;
      pick the next op to move to execution.
- [ ] **Cross-host coherence demo**: the §1.6 killer demo (catch a violation across
      two hosts, re-project a drift-free set) — the proof artifact.
- [ ] **Positioning**: lock the lead line ("conformance layer" / "git for your
      agent's constitution"); pressure-test "agent conformance" as the coined category.

---

## Sources
**Enforcement:** [Claude Code hooks](https://code.claude.com/docs/en/agent-sdk/hooks) ·
[deny under bypass](https://pasqualepillitteri.it/en/news/1832/claude-code-dangerously-skip-permissions-pretooluse-hooks-2026) ·
[OpenAI structured outputs](https://openai.com/index/introducing-structured-outputs-in-the-api/) ·
[llguidance](https://github.com/guidance-ai/llguidance) ·
[JSONSchemaBench](https://arxiv.org/pdf/2501.10868) ·
[guardrail bypass](https://arxiv.org/html/2504.11168v1) ·
[V&V loops](https://timjwilliams.medium.com/llm-verification-loops-best-practices-and-patterns-07541c854fd8)
**Compression / DSL:** [LLMLingua-2](https://arxiv.org/pdf/2403.12968) ·
[gist tokens](https://arxiv.org/abs/2304.08467) ·
[Let Me Speak Freely](https://aclanthology.org/2024.emnlp-industry.91.pdf) ·
[compression vs compliance](https://arxiv.org/pdf/2512.17920) ·
[short-path prompting](https://arxiv.org/pdf/2504.09586) ·
[CRANE](https://arxiv.org/html/2502.09061v1)
**Landscape:** [Karpathy LLM-OS](https://x.com/karpathy/status/1707437820045062561?lang=en) ·
[AIOS](https://arxiv.org/pdf/2312.03815) · [Letta](https://www.letta.com/blog/agent-memory) ·
[framework memory silos](https://dev.to/foxgem/ai-agent-memory-a-comparative-analysis-of-langgraph-crewai-and-autogen-31dp) ·
[SDK lock-in/identity](https://composio.dev/content/claude-agents-sdk-vs-openai-agents-sdk-vs-google-adk) ·
[Claude plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) ·
[AGENTS.md vs CLAUDE.md](https://thepromptshelf.dev/blog/agents-md-vs-claude-md/) ·
[execution-layer thesis](https://www.taskade.com/blog/execution-layer-thesis)
**Positioning:** [Dunford framework](https://www.kathirvel.com/guide-april-dunford-positioning-framework/) ·
[Temporal durable execution](https://temporal.io/blog/what-is-durable-execution) ·
[K8s control plane](https://www.redhat.com/en/technically-speaking/Kubernetes-control-plane) ·
[leaky abstraction (a16z)](https://a16z.com/call-the-plumber-weve-got-a-leaky-abstraction/) ·
[Sequoia why-now](https://www.the-founders-corner.com/p/how-sequoia-turns-decks-into-deals) ·
[HashiCorp OSS strategy](https://medium.com/@takafumi.endo/how-hashicorp-became-one-of-the-most-valuable-oss-companies-e27e3a6e7ba0)
