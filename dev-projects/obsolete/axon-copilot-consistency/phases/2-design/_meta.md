# Phase 2 — Design — META

slug:            2-design
schema-version:  v4
status:          active
opened:          2026-05-20
predecessor:     phases/1-study/_closure.md

---

## Goal

Crystallize the 6-PR queue locked at phase-1 closure (8.4/10 confidence) into
shippable specs. No code yet — just per-PR scope, files touched, test ids,
acceptance gates, and dependency order.

## Build invariants

- **R9 clean:** no `axon/` writes without `L:dev-mode ≡ true`. All PRs target
  `.github/`, `.vscode/`, `tools/`, `workspace/`, `AGENTS.md` (repo root),
  `my-axon/dev-projects/`.
- **Truncation-safe:** every file Copilot reads at startup or per-turn MUST
  fit under 160 lines (Copilot CLI agent-mode budget per issue #2111) AND its
  critical first ~50 lines / ~4000 chars must stand alone (code-review slot
  + truncation-bottom safety).
- **No contradictions:** before any PR merges, run `grep` over the changed
  files for the historical D-1..D-7 contradiction patterns (`describe and
  wait`, `cannot run AXON tools`, etc.) — remove duplicates.
- **Reproduce-in-both rule** (phase-1 lesson #5): every PR's acceptance
  criteria must include a manual reproduction step in *both* Claude Code AND
  Copilot CLI before merge. Reviewer signs off only after seeing both
  transcripts.
- **Idempotent setup:** any setup script (PR-CC-204, PR-CC-205) must be
  idempotent (running twice == once).

## PR queue (locked at 6, drafted at phase-1 closure)

| PR | Title | Strategy | Files | Effort |
|---|---|---|---|---|
| **PR-CC-201** | Remove T1 self-contradiction + collapse copilot-instructions.md under 160 lines | T1 fix | `.github/copilot-instructions.md` | S |
| **PR-CC-202** | Load-balance: move load-bearing rules into AGENTS.md (now <150 lines) | T2/T3 mitigation | `AGENTS.md`, `.github/copilot-instructions.md` (shim) | S-M |
| **PR-CC-203** | `axon-mcp` server — MCP exposure of boot/log/health/reanchor/menu | H6 (refined) | `tools/axon_mcp_server.py`, `tools/axon_mcp_manifest.json`, `tests/test_axon_mcp.py`, `workspace/programs/axon-mcp-setup.md` | M |
| **PR-CC-204** | Migrate deprecated `codeGeneration` + `testGeneration` slot settings → `.github/instructions/*.instructions.md` with `applyTo:` frontmatter | VS Code 1.102 deprecation | `.vscode/settings.json`, `.github/instructions/code.instructions.md`, `.github/instructions/tests.instructions.md` | S |
| **PR-CC-205** | Setup-script advisory: detect Copilot, recommend autopilot opt-in + `--allow-tool axon_*` patterns + MCP install | H8 + F-3 | `scripts/setup-copilot-axon.sh`, `workspace/programs/copilot-setup.md` | S-M |
| **PR-CC-206** | Truncation-safe top-of-file AXON banner — fits 4000-char code-review AND 160-line agent-mode windows | H5 | `.github/copilot-instructions.md` (banner block at top), `AGENTS.md` (banner block at top) | S |

Total ≈ 4 small + 2 small-medium + 1 medium.

## DAG

```
                ┌────────────────┐
                │  PR-CC-201     │  fix T1 + collapse to <160 lines
                │  copilot-instr │
                └───────┬────────┘
                        │  hard dep on the file's structure
                        │
              ┌─────────┴──────────┐
              ▼                    ▼
      ┌────────────────┐    ┌─────────────────┐
      │  PR-CC-206     │    │  PR-CC-202      │
      │  banner block  │    │  AGENTS.md      │
      │  (top 50 lines)│    │  load-balance   │
      └───────┬────────┘    └────────┬────────┘
              │                      │
              └───────────┬──────────┘
                          ▼
              ┌───────────────────────┐
              │  PR-CC-205            │
              │  setup advisory       │  (references AGENTS.md + MCP)
              └───────────────────────┘

      Independent PRs (any order):

      ┌────────────────┐         ┌────────────────┐
      │  PR-CC-203     │         │  PR-CC-204     │
      │  axon-mcp      │         │  slot migration│
      │  (MCP server)  │         │  (.vscode)     │
      └────────────────┘         └────────────────┘
```

**Critical path:** PR-CC-201 → {PR-CC-206, PR-CC-202} → PR-CC-205.
**Independent free PRs:** PR-CC-203 + PR-CC-204 can ship anytime.

### Dependency table

| PR | Depends on | Blocks | Rationale |
|---|---|---|---|
| PR-CC-201 | — | 202, 206 (hard) | Both 202 and 206 reorganize the file 201 has just normalized |
| PR-CC-202 | 201 (hard) | 205 (soft) | 205's advisory text references AGENTS.md as the primary load-bearing file |
| PR-CC-203 | — | 205 (soft) | 205 advises the user to install the MCP server 203 ships |
| PR-CC-204 | — | — | Pure VS Code deprecation migration; orthogonal |
| PR-CC-205 | 202 (soft), 203 (soft) | — | References both for content; can ship as a stub first |
| PR-CC-206 | 201 (hard) | — | Banner block is the first 50 lines of the file 201 collapsed |

### Recommended landing order

1. **PR-CC-201** — unblocks 202 + 206. Must land first.
2. **PR-CC-203** (parallel) — MCP server independent; could even land before 201.
3. **PR-CC-204** (parallel) — slot migration independent.
4. **PR-CC-206** — top-of-file banner; depends on 201.
5. **PR-CC-202** — AGENTS.md load-balance; depends on 201, complements 206.
6. **PR-CC-205** — setup advisory; depends on 202 + 203 for content references.

## Goals (measurable)

Inherited from `../_meta.md`, restated as acceptance gates with target
metrics. Goals are evaluated at phase-4 validation, not phase-2.

| # | Goal | Target | Measured by |
|---|---|---|---|
| G-1 | Command routing accuracy (Copilot vs Claude Code) | parity (±5%) | `dispatch-stats` weekly; manual probe set (10 commands) per session |
| G-2 | Tool-call rate (boot/health/log) — execute vs. describe | ≥ 95% execute (vs. Claude Code's ~100% baseline) | manual probe corpus, scored from transcripts |
| G-3 | Persona-drift rate (consumes `-anchor` G-1/G-2/G-3 definitions) | inherit from `-anchor` | `axon_drift_log` D-1..D-7 events |
| G-4 | Self-contradiction count in instruction files | 0 | grep before merge + CI lint rule (new, see F-1) |
| G-5 | Instruction file size — survives Copilot CLI truncation | ≤ 150 lines / ≤ 6000 chars | `wc` in CI |

## Exit criteria

- All 6 PRs shipped to `main` (axon repo).
- Each PR's acceptance includes Claude Code + Copilot CLI reproduction
  transcripts (per "Reproduce-in-both rule" above).
- `phases/2-design/_closure.md` written summarizing per-PR landing notes.
- `_meta.md` bumped to phase 3-build → 4-validation as PRs progress.

## Per-PR specs

### PR-CC-201 — Remove T1 self-contradiction + size-down
- **Goal:** eliminate the non-deterministic tool-call behavior caused by
  contradictory clauses in `.github/copilot-instructions.md`.
- **Change set:**
  - Remove lines 148-154 (the older "Out of scope for Copilot" → "describe
    what would run and wait" clause). The newer PR-CA-102 "Execution
    primitive" clause stays as the single source of truth.
  - Audit the rest of the file for any latent contradictions (e.g. "You
    cannot enforce hooks per-turn" vs. the "Per-turn reanchor" section
    above — keep the section heading but rewrite as "Per-turn reanchor is
    your responsibility on this harness; here is how").
  - Total file length must drop from 174 → ≤ 150 lines.
- **Tests:** new CI lint rule `tests/test_copilot_instructions_sanity.py`
  with these assertions:
  - line count ≤ 150
  - byte count ≤ 6000
  - no occurrence of the literal phrase "describe what would run and wait"
  - no occurrence of "you cannot run AXON tools yourself"
  - presence of the "Per-turn reanchor" section heading
- **Acceptance:** Copilot CLI session reproduction — run `boot axon` and
  observe the agent literally calls `python3 axon.py boot` (not "I'll act as
  if I ran it"). Paste transcript into the PR.

### PR-CC-202 — Load-balance to AGENTS.md
- **Goal:** put the load-bearing rules (identity contract, kernel boot
  directive, tool execution rule, drift recovery) into AGENTS.md so they
  survive Copilot CLI truncation. `.github/copilot-instructions.md` becomes
  a shorter, IDE-focused file that points at AGENTS.md as the primary.
- **Change set:**
  - Move identity contract + kernel boot directive + execution primitive
    block from `.github/copilot-instructions.md` → AGENTS.md.
  - Leave drift recovery + path conventions + slot pointers in
    `.github/copilot-instructions.md` (VS Code Chat will still auto-load it).
  - Add a single sentence at the top of `.github/copilot-instructions.md`:
    "Primary contract: AGENTS.md (repo root). This file is supplementary."
  - AGENTS.md total length must stay ≤ 150 lines.
- **Tests:** extend `test_copilot_instructions_sanity.py` to assert AGENTS.md
  line count ≤ 150 AND that AGENTS.md contains the identity contract
  + kernel boot directive + execution primitive markers.
- **Acceptance:** Copilot CLI session — `boot axon` works from AGENTS.md
  alone (rename `.github/copilot-instructions.md` aside temporarily to
  verify). Paste both transcripts.

### PR-CC-203 — `axon-mcp` server
- **Goal:** expose AXON's core read-only operations as MCP tools so
  Copilot calls them by name, removing the describe-vs-execute ambiguity.
- **MVP tool list (5 tools, all read-side):**
  - `axon_boot` → `python3 axon.py boot`
  - `axon_log_read` → tail today's log
  - `axon_health` → health check
  - `axon_menu` → render menu
  - `axon_reanchor` → run the reanchor program
- **Change set:**
  - `tools/axon_mcp_server.py` — minimal MCP server implementing the JSON-RPC
    schema for the 5 tools. Backed by `subprocess` calls into `python3
    axon.py`. No persistent state.
  - `tools/axon_mcp_manifest.json` — server descriptor + tool schemas.
  - `workspace/programs/axon-mcp-setup.md` — user-facing install steps
    (per-IDE: VS Code `.vscode/mcp.json` vs. Copilot CLI `~/.copilot/config`).
  - `tests/test_axon_mcp.py` — round-trip test: spin up server, send
    `tools/list` JSON-RPC, assert 5 tools returned; send `tools/call axon_boot`
    and assert non-empty result.
- **Out of scope (defer to phase-3 follow-up):** `axon_run`, `axon_compile`,
  `axon_write_*` — anything that mutates state.
- **Acceptance:** Copilot CLI with `--allow-tool axon_*` reproduces `boot
  axon` via the MCP tool call (not via shell).

### PR-CC-204 — VS Code slot migration
- **Goal:** stop relying on the deprecated `codeGeneration` and
  `testGeneration` settings entries.
- **Change set:**
  - Move content of `scripts/copilot/code.md` → `.github/instructions/code.instructions.md` with `applyTo: "**/*.py"` (or appropriate path glob).
  - Move content of `scripts/copilot/tests.md` → `.github/instructions/tests.instructions.md` with `applyTo: "tests/**/*.py"`.
  - Remove the two deprecated entries from `.vscode/settings.json` (keep
    `commitMessageGeneration` and `reviewSelection` — those slots are still
    supported via settings).
  - Leave `scripts/copilot/{commits,review}.md` in place (still referenced
    by the non-deprecated slots).
- **Tests:** assert `.github/instructions/*.instructions.md` files have
  `applyTo:` frontmatter. Assert `.vscode/settings.json` does NOT contain
  the two deprecated keys.
- **Acceptance:** open a `.py` file in VS Code with Copilot Chat, ask for
  a code suggestion, observe AXON path-resolution rule applied. Paste
  transcript.

### PR-CC-205 — Setup-script advisory
- **Goal:** when a user runs `setup-persona.sh` or equivalent and Copilot is
  detected, surface the steps to opt into autopilot + MCP + `--allow-tool`
  patterns.
- **Change set:**
  - `scripts/setup-copilot-axon.sh` — detects `gh copilot` or `~/.copilot/`
    presence; prints:
    1. "Recommended: run `gh copilot --autopilot --allow-tool axon_*` for AXON
       sessions" (cited from F-3).
    2. "MCP server install: see `workspace/programs/axon-mcp-setup.md`".
    3. "Add this repo's `.copilotignore` excludes: my-axon/, .venv/, generated/."
  - `workspace/programs/copilot-setup.md` — user-facing AXON program that
    runs the same checks at boot.
- **Tests:** unit-test the shell-detection portion in `tests/test_setup_copilot_axon.py`.
- **Acceptance:** run the script on a clean machine with `gh copilot`
  installed; observe the 3 advisory blocks.

### PR-CC-206 — Truncation-safe top-of-file banner
- **Goal:** ensure that even in the worst-case truncation scenario
  (4000-char code-review window OR ~160-line agent-mode cut), the surviving
  fragment contains the identity contract + tool-execution rule + per-turn
  reanchor pointer.
- **Change set:**
  - Define a canonical "AXON banner block" (≤ 40 lines, ≤ 2500 chars):
    1. Identity contract (3 lines)
    2. Tool-execution rule (3 lines, single-clause version from PR-CC-201)
    3. "Primary contract: AGENTS.md" pointer (1 line)
    4. "Per-turn reanchor: read AGENTS.md + this file at start of every turn" (2 lines)
  - Place this block at the **very top** of:
    - `AGENTS.md` (already primary; reinforces it)
    - `.github/copilot-instructions.md` (auto-prepended by VS Code; ensures
      survival in code-review's 4000-char window)
- **Tests:** assert both files start with the canonical banner block
  (regex match on first ~50 lines).
- **Acceptance:** code-review slot test — ask Copilot Chat to review a small
  change and verify the agent applies AXON-style review rules (per
  `scripts/copilot/review.md`), proving the banner survived even in the
  4000-char window.

## Cross-refs

- `phases/1-study/01-study.md` — sources + tensions + hypotheses
- `phases/1-study/_audit.md` — corrections C-1..C-7, score lift to 8.4
- `phases/1-study/_closure.md` — locked decisions
- Sibling `../axon-copilot-anchor/phases/2-design/_meta.md` — analogous
  pattern this project mirrors
