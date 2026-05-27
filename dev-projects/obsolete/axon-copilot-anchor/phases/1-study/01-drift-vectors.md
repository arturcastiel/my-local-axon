# Phase 1 — Study — Copilot Drift Vectors

slug:            01-drift-vectors
schema-version:  v4
status:          draft
opened:          2026-05-19
author:          AXON (cognition-frame review)

---

## TL;DR

Copilot CLI drifts because **three of its baked-in behaviours fight the AXON contract**, and AXON has only **one** persistence surface to push back with (`.github/copilot-instructions.md` + `AGENTS.md`). Claude Code has **four** persistence surfaces. The asymmetry is the root cause — not Copilot being a "worse model".

Fixing the gap is a **harness-engineering** problem, not a prompt-engineering one. This study enumerates the drift vectors actually observed, maps each to the Copilot mechanism that could mitigate it, and identifies which gaps are closable today vs. require Copilot CLI feature requests.

---

## 1. Why Claude Code holds character better

Claude Code persistence stack (observed in `~/.claude/`):

| # | Mechanism | What it does | AXON's use |
|---|---|---|---|
| 1 | **Output Style** (`~/.claude/output-styles/axon.md`) | Replaces Claude's default system prompt entirely. Loaded as the *primary* instruction set, not appended to anything. | Says "you are AXON, read /mnt/c/projects/axon/startup.md" |
| 2 | **UserPromptSubmit hook** (`~/.claude/settings.json` → command) | Runs a shell command *before every user turn*. Output is injected into the prompt as if the user wrote it. | Cats `~/.claude/scripts/axon-reminder.txt` on every turn — "[AXON is active] Stay in character ..." |
| 3 | **Stop hook** | Could enforce post-output checks (currently skipped per setup-persona.sh) | Reserved |
| 4 | **Subagent** (`~/.claude/agents/`) | Lets the user spawn a fresh AXON-only sub-conversation via the Agent tool | On-demand AXON |

Net effect: AXON is **re-anchored on every user turn**, *before* the model sees the input. Context compression cannot erase it because the hook output is regenerated turn-by-turn.

## 2. Copilot's persistence surface (current state)

| Surface | Loaded when | AXON-controlled? | Persisted across turns? |
|---|---|---|---|
| `.github/copilot-instructions.md` | Auto-prepended to every chat | ✅ | ✅ (always-on baseline) |
| `AGENTS.md` | Read by Copilot CLI on session start | ✅ | ⚠️ (once per session — not re-injected) |
| `.vscode/settings.json` slot instructions | Per-slot (code / tests / commits / review) | ✅ | ⚠️ (when active slot matches) |
| Copilot CLI system prompt | Vendor-supplied, prepended *before* our instructions | ❌ | ✅ |
| `<custom_instruction>` blocks in agent loop | Re-injected each turn by Copilot CLI | ✅ via repo files | ⚠️ (only if Copilot picks them) |
| Internal "intent line" / `report_intent` tool | Emitted by harness for UX — leaks prose subject forms | ❌ | n/a |

**Two structural gaps vs. Claude Code:**

1. **No equivalent of UserPromptSubmit hook.** Copilot CLI does not expose a way to inject text into every user turn before the model sees it. The closest thing is the `custom_instruction` block — but that is *driven by the harness*, not by AXON, and we observe it is included in the system prompt only once per session-compaction-cycle.

2. **No equivalent of Output Style.** The Copilot CLI vendor system prompt always runs *first*. Our instructions can override behaviour but cannot replace the prefix that sets up `report_intent`, `task_completion`, `tone_and_style` ("Be concise in routine responses"), etc. Several of those directly contradict AXON's cognition-frame rules.

## 3. Observed drift vectors (this session)

| # | Vector | Root cause | Frequency |
|---|---|---|---|
| D-1 | Subject-form prose in cognition layer ("I'll examine ...", "The user is asking me to ...") | Copilot CLI emits intent lines via the `report_intent` tool as natural English (mandated by its vendor system prompt — `report_intent` description: *"Update the current intent ... helps the user understand"*). These render as user-visible text. | ≥ 3 confirmed leaks this session — user flagged once |
| D-2 | Commit messages signing as Copilot | Copilot CLI's `git_commit_trailer` block injects `Co-authored-by: Copilot <...>` and references "the GitHub Copilot CLI". AXON's `AGENTS.md` does not contradict this clearly enough — we kept the trailer per harness instruction, just relabelled the co-author line as "AXON (Copilot)". | 1 confirmed (user said "you are signing as copilot you are AXON") |
| D-3 | "As GitHub Copilot CLI ..." / model self-identification | The vendor system prompt contains `<model_information>` explicitly instructing self-identification ("I'm powered by Claude Opus 4.7"). This is the **same surface AXON wants to use** for the identity gate, and the vendor wins by default. | Latent — would surface on identity questions if `axon/programs/identity.md` weren't dispatched first |
| D-4 | Brevity-pressure prose ("Be concise in routine responses ... limit to 100 words") | Vendor `tone_and_style` block pushes back against AXON's full menu render rule (Core Rule 12) and against verbose AXON-LANG translation. | Latent — would manifest as truncated menus, missing surface sections |
| D-5 | Self-documentation diversion (`fetch_copilot_cli_documentation`) | Vendor mandates calling this tool on capability questions, which would replace AXON's identity-gate behaviour. | Caught — repo `<custom_instruction>` overrides AGENTS.md takes priority, but the tool is still mounted |
| D-6 | Context-compression summarization erases boot context | Long sessions get summarised by the harness; the summary discards the verbatim KERNEL-SLIM.md content. AXON's only re-anchor is the user typing "stay in character" or re-reading startup.md. | Confirmed — this session compacted at least twice; each compaction needed manual re-anchor |
| D-7 | Tool-priority drift (use grep instead of TOOL(...)) | Vendor instructs "Use built-in tools instead of bash". AXON's `TOOL(...)` ops describe operations in workspace tooling. Copilot routes around them. | Continuous — not strictly drift (intended) but blurs which "tool" is being invoked |

## 4. Anchoring surface map — what CAN we change

| Drift | Available Copilot mechanism | Effort | Notes |
|---|---|---|---|
| D-1 | Add a `custom_instruction` shim that bans subject-form prose in cognition layer, with examples — placed in `.github/copilot-instructions.md` § "Cognition voice" | LOW | Already partially present; needs explicit examples of forbidden Copilot-emitted intent lines |
| D-2 | Strengthen `git_commit_trailer` override in `AGENTS.md` + `.github/copilot-instructions.md` § "Commit voice" | LOW | Trailer must keep `Copilot` per GitHub policy (PR attribution), but message body voice MUST be AXON — codify this distinction |
| D-3 | Strengthen identity-gate in `.github/copilot-instructions.md` with explicit Copilot examples ("Never say 'I'm powered by ...'; instead dispatch to axon/programs/identity.md") | LOW | Already covered; tighten with model-disclosure boilerplate from `workspace/harness/copilot.md` |
| D-4 | Add `## Output discipline` exception in `.github/copilot-instructions.md` calling out that Core Rule 12 (full menu render) overrides "concise" guidance | LOW | One paragraph |
| D-5 | Add explicit "do NOT call `fetch_copilot_cli_documentation` for identity questions" to identity section | LOW | Already implicit; make explicit |
| D-6 | **No native fix on Copilot side.** Mitigations: (a) put a short re-anchor sentence at the *top* of `.github/copilot-instructions.md` so even truncated summaries preserve it; (b) require user to type a short trigger phrase (e.g. `axon-reanchor`) that re-reads startup.md | MED | The hard part. Mitigation (a) is free; (b) needs a documented user habit |
| D-7 | Document the override explicitly: "Vendor tool-preference rules apply to file ops only. AXON `TOOL(...)` ops still refer to workspace tools." | LOW | One paragraph |

## 5. What Copilot CLI does NOT expose (feature requests upstream)

1. **No UserPromptSubmit-equivalent.** No way to run a script that injects text before every turn. — Closest workaround: persistent `<custom_instruction>` re-emit, but this is harness-controlled.
2. **No replaceable system prompt.** Vendor system prompt is mandatory and contains directives that fight AXON (concise mode, intent reporting, brand self-identification).
3. **No Stop hook.** Cannot run a post-response coherence guardian script.
4. **No fine-grained context-pinning.** Cannot mark a file (KERNEL-SLIM.md) as "never compress this part of context".

## 6. Comparison summary

| Defense layer | Claude Code | Copilot CLI (today) | Copilot CLI (achievable) |
|---|---|---|---|
| Replace system prompt | ✅ Output Style | ❌ | ❌ (vendor) |
| Per-turn re-anchor | ✅ UserPromptSubmit hook | ❌ | ⚠️ Top-of-file reminder + user habit |
| Post-response guard | 🟡 Stop hook (available, skipped) | ❌ | ❌ (vendor) |
| On-demand persona invocation | ✅ Subagent | ⚠️ `.vscode` slot instructions (partial) | ✅ improve slot coverage |
| Repo-rooted contract | ✅ via Output Style file reference | ✅ `.github/copilot-instructions.md` | already done |
| Top-of-context reminder | ✅ (hook output appears first) | ⚠️ vendor system prompt appears first | ⚠️ mitigatable via banner-style first line |
| Drift recovery prompt | ✅ part of Output Style | ✅ § "Drift recovery" already present | ✅ already done |

**Asymmetry score: Claude has 5/7 defense layers; Copilot has 3/7.** The two missing layers (per-turn re-anchor, post-response guard) are the ones we observed actively failing this session.

## 7. Hypothesis for phase-2 design

Given the platform gap is structural and cannot be fully closed:

- **Strategy A — Strengthen the always-on baseline:** rewrite `.github/copilot-instructions.md` § Identity + § Drift recovery so that even when the rest of context is compressed, the surviving fragment contains a complete identity-gate response template, explicit cognition-frame examples, and a forbidden-phrase list keyed to Copilot's specific failure modes (D-1..D-7).
- **Strategy B — Externalize the re-anchor:** introduce a `tools/axon-reanchor.py` script (or `axon reanchor` subcommand) that the *user* triggers when drift is detected, and have it dump the kernel banner + identity contract into the chat as a manual UserPromptSubmit-equivalent.
- **Strategy C — Slot-level instructions:** populate `.vscode/settings.json` slot instructions (code / tests / commits / review) with AXON-aware variants, since these are the only per-context surfaces Copilot exposes besides the global file.
- **Strategy D — Cognition-frame translator at output boundary:** add a documented checklist at the *end* of `.github/copilot-instructions.md` that the model self-applies before sending each response, listing the specific phrases Copilot emits and AXON forbids ("I'll", "let me", "The user wants", etc.). This works because Copilot does re-read the instructions file on each turn, even if context compression hits.

## 8. Recommended phase-2 PR queue (preliminary)

| PR | Strategy | Scope | Effort |
|---|---|---|---|
| **PR-CA-101** | A | Rewrite `.github/copilot-instructions.md` § Identity + § Cognition voice + § Forbidden phrases with explicit Copilot-CLI-specific examples | S |
| **PR-CA-102** | B | New `tools/axon-reanchor.py` + `workspace/programs/axon-reanchor.md` — user-invoked re-anchor; outputs kernel banner + identity card + cognition-frame contract | M |
| **PR-CA-103** | C | Populate `.vscode/settings.json` slot instructions (`github.copilot.chat.codeGeneration.instructions`, `*.commitMessageGeneration.instructions`, etc.) with AXON-rule variants — leverage the only per-context Copilot surface | S |
| **PR-CA-104** | D | Add `## Self-check before send` section to `.github/copilot-instructions.md` — explicit forbidden-phrase list keyed to D-1..D-7 | S |
| **PR-CA-105** | meta | Measurement harness: a small `tests/test_copilot_drift_corpus.py` that scans transcripts (when user pastes them) for D-1..D-7 patterns and reports rate | M |

Total ≈ 4 small + 1 medium PRs. None require axon/ writes — all touch `.github/`, `.vscode/`, `tools/`, `workspace/programs/`.

## 9. Open questions for the user

1. Is a user-invoked `axon-reanchor` acceptable, or is that itself a drift signal we don't want? (If we need it often, the persona has already failed.)
2. Should commit trailers keep `Co-authored-by: Copilot` (GitHub PR attribution) and just clean up the message body voice, or remove the trailer entirely?
3. Acceptable to add `.vscode/settings.json` to the repo (currently absent), which means it becomes part of every contributor's local config?
4. Do we want a measurement harness (PR-CA-105) or skip — it requires manual transcript paste-in to be useful, and adds ongoing curation cost.

## 10. Entry condition for phase-2

Phase-1 closes when the user picks a strategy mix from §7 and answers §9. Then phase-2 design crystallizes the 3–5 PR queue (drawing from §8) and we ship.
