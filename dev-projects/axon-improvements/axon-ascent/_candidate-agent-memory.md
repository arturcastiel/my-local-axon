# Candidate PR — AXON-native agent/operational memory (harness-portable)

> Net-new, beyond the original axons-audit. Surfaced 2026-05-24 by the user:
> AXON-domain operational knowledge is currently stranded in the Claude Code
> HARNESS auto-memory (~/.claude/projects/.../memory/), which is harness-
> specific and ungoverned by AXON. AXON should carry it natively.

## Problem
The dev-operational conventions (this-repo handoff policy: AXON may run
tests/push/draft-PR/merge under a scoped grant; autonomous-run kernel-logging
discipline; keep-awake step; CI checkout-flake fact; persona no-branding)
live ONLY in Claude Code's per-project auto-memory. If AXON boots under a
different harness (Copilot/generic), that knowledge is invisible — breaking
AXON's multi-harness promise ("same behaviour on host B as host A").

## Layering decision (what goes where)
- UNIVERSAL AXON rules (persona, cognition-language, output) → already KERNEL.
- USER-SPECIFIC operational policy (tests/push/merge grant shape, keep-awake,
  CI-flake, logging discipline) → PERSONAL → my-axon (private, per-user,
  NOT the public repo — a cloner must not inherit "AXON may self-merge here").

## Proposed PR (two parts)
1. **Content (my-axon, private, no gate):** `my-axon/memory/operational/*.md` —
   migrate the user-specific operational conventions out of the harness memory
   into AXON's own private memory. One file per topic (handoff, autonomous-run,
   keep-awake, ci-notes), with frontmatter.
2. **Mechanism (axon.git, KERNEL/BOOT — dev-mode gated):** a boot step that
   loads `my-axon/memory/operational/*` into AXON's working memory so any
   harness sees it. Likely hook: extend the my-axon load in BOOT (it already
   EXECs MYAXON.md) to also surface an operational-memory index. Harness-aware
   (e.g. the "may run tests/push" capability can note which harness it applies to).
   The Claude Code harness memory then keeps a thin POINTER to AXON's memory as
   source-of-truth (avoid duplication).

## Design forks to confirm before building
- Source-of-truth: AXON my-axon memory primary, harness memory = pointer? (lean: yes)
- Load mechanism: boot step (kernel, dev-mode) vs a program `EXEC(load-conventions)`
  (workspace, no gate)? (lean: a workspace program first to avoid kernel churn;
  promote to boot step later if it proves out)
- Shareable subset: do any conventions belong in workspace/preferences (public)?
  (lean: no — these are user-specific; keep them private in my-axon)

## Effort / risk
S–M. Content part is trivial (move files). Mechanism part is the real work;
keeping it a workspace program (not a boot/kernel change) avoids dev-mode and
keeps blast radius low for v1.

## Expanded requirements (user, 2026-05-24) — scope grew; this is now a real feature
The user enriched the ask. Four pillars:

### 1. Two memory tiers
- **GENERAL (cross-project)** — AXON-wide operational context that applies to
  every project/session: handoff policy, autonomous-run logging discipline,
  persona rules, keep-awake step, CI-flake fact, etc. Lives in my-axon
  (private, cross-project) — e.g. `my-axon/memory/operational/` (general scope).
  Loaded at boot regardless of which project is active.
- **LOCAL (per-project)** — each code-dev project carries its OWN memory
  context (project-specific conventions, decisions, gotchas). Extends the
  existing per-project `_decisions.md` / `_dont-do.md` into a first-class
  project memory. Lives in the project dir (e.g.
  `my-axon/dev-projects/<slug>/_memory/`). Loaded on `code-dev load <slug>`.
  This is the AXON-native, harness-portable analogue of a per-project CLAUDE.md.

### 2. Enforcement mechanisms (NOT just storage) + tests
Memory must be BINDING, not advisory-by-hope. Two enforcement surfaces:
- **Load enforcement** — a mechanism that actually READS the general memory at
  boot and the local memory at project-load (assert-present; surface if missing).
- **Adherence enforcement** — rules/gates that check the agent honored the
  memory (e.g. project `_dont-do` respected; handoff policy followed; output
  standard met). Same lint-pack pattern as axon-polish rules (warn→enforce flag).
- **Tests** — both the load mechanism and the adherence rules get test coverage
  (rule-pack-style + load-roundtrip tests). Self-contained.

### 3. Harness portability — one source of truth, enforced per-harness
The memory lives ONCE in AXON (my-axon + project dirs). Enforcement adapts to
the host harness:
- **Claude Code** — UserPromptSubmit hook + the harness auto-memory can POINT
  to AXON's memory as source-of-truth (already have the hook).
- **Copilot CLI** — has NO per-turn hooks. Enforcement = the existing
  `.github/copilot-instructions.md` (always-prepended baseline) + slot
  instructions in `.vscode/settings.json` (per workspace/harness/copilot.md).
  → Need a SYNC step: a tool that renders AXON's general+local memory into the
  copilot-instructions baseline so Copilot reads+enforces the SAME memory every
  turn. One source (AXON memory) → generated copilot baseline. Keeps the two
  harnesses behaviourally aligned (the multi-harness invariant).

### 4. Copilot enforcement is the hardest part — flag for design
Because Copilot can't run a per-turn gate, "enforcement" there is really
"strong always-on instruction + a pre-commit/CI check that the instruction was
followed" (e.g. the rule-pack run in CI catches violations even if the model
drifted mid-turn). So the CI rule-pack doubles as the cross-harness enforcement
floor. Worth confirming this framing with the user when we build.

## Revised shape (post-expansion)
This is no longer a small PR — it's a multi-PR sub-project:
- PR-AM1: general operational memory (my-axon content) + boot/load mechanism
- PR-AM2: per-project local memory + code-dev-load wiring + tests
- PR-AM3: adherence rules (lint-pack) + tests
- PR-AM4: Copilot sync (AXON memory → copilot-instructions baseline) + verify
Likely warrants its own code-dev project (e.g. `axon-agent-memory`) rather than
living as an axon-ascent candidate. Decide at kickoff.

## Status
PROMOTED 2026-05-24 to its own code-dev project `axon-memory`
(my-axon/dev-projects/axon-memory/). Scope outgrew an axon-ascent phase. The
harmonized v1 spec + 6-PR roadmap (AM1-AM6) live in that project's masterplan.md
/ 02-prs.md. This candidate is retained as the origin record; active work tracked
in axon-memory. Cluster-N will absorb the memory-graph declaration layer.
