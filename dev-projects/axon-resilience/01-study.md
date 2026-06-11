# 01 — Study: AXON resilience (cron↔tool `--workspace` contract + identity persistence/self-care)

> Phase 1 · 2026-06-09 · verified by a 5-investigator parallel study (read-only).
> Trigger: the `cron tick` maintenance run surfaced 2 silently-failing cron jobs; owner directive
> "code-dev this … totally autonomously" + 5 governing principles (study / best-for-AXON / grow /
> scalable / identity-persistence).

---

## Track A — Cron-runner ↔ tool `--workspace` invocation contract

### How the contract works (verified by reading `tools/cron.py`)
`_build_job_cmd` + `_run_job` inject `--workspace <ws>` into **every** cron job and try up to two argv
placements for CLI-form jobs:
- **Leading** (always first): `axon.py <tool> --workspace <ws> <subcmd> <args>`
- **Trailing retry** (only if leading exits 2 **and** `not prog.endswith(".md")` **and** `len(tokens) > 1`):
  `axon.py <tool> <subcmd> <args> --workspace <ws>`

Path-form jobs (`*.md`) run via `tools/run.py` with a fixed trailing `--workspace` (always accepted).

### Per-job verdict (11 jobs) — only 2 are broken
| job | program | verdict |
|---|---|---|
| `89d9debb` (health-check.md), `axon-memory-compact` (memory-compact.md) | path-form | OK |
| `axon-igap-report`, `axon-programs-registry`, `axon-session-save`, `axon-auto-improve`, `axon-audit-weekly` | top-parser `--workspace` | OK (leading) |
| `axon-compile-rank`, `axon-deprecation-cron` | passthrough / subparser-only | **OK only via trailing retry** (multi-token) |
| **`axon-dispatch-stats`** | `dispatch-stats weekly` | **FAIL A1** — `weekly` is not a subcommand (`summary\|savings\|precision`); both placements exit 2 |
| **`axon-freshness-weekly`** | `freshness refresh` | **FAIL A2** — `freshness.py` declares `--workspace` NOWHERE; both placements exit 2 |

### Root cause (why the retry can't save A1/A2)
The retry only relocates `--workspace`; it never changes the subcommand token and offers only 2 positions.
- **A1 (wrong subcommand):** both placements exit 2 on the positional-choice check; relocating the flag
  cannot fix a wrong subcommand. The retry's exit-2 trigger even *masks* A1 vs. a real placement error.
- **A2 (`--workspace` nowhere):** the flag is unknown in 0 placements; exhausting both still fails.
- **Structural trap (latent, not yet broken):** a **single-token** job whose tool has `--workspace`
  subparser-only/nowhere is **unrescuable** — the retry never fires (`len(tokens) > 1` is false). Nothing
  prevents adding such a job today. `compile-rank`/`deprecation-cron` are one refactor away from breaking.

### Decision (best-for-AXON + scalable)
Point-fix A1 + A2 **and** add a systemic merge-time gate so the whole bug-class is caught at the seam,
not when the cron breaker trips weeks later:
- **A1:** `cron.json` job `axon-dispatch-stats` program `dispatch-stats weekly` → `dispatch-stats summary`.
- **A2:** add `--workspace` to `freshness.py`'s **top parser** (`default=default_workspace()`, absolute) and
  thread it into the 2 `programs_registry.py` callsites + `_retrieval_index_fresh`. Give `check(ws=…)` /
  `refresh(ws=…)` defaults so the existing in-process tests (which call them arg-less) keep passing.
  Verified: `programs_registry.py` accepts an absolute `--workspace` on its top parser (rc 0).
- **Systemic:** new tool `tools/cron-conformance.py` — `check` (gate, exit 0/1) + `report` (table). For
  every cron job it introspects the backing tool's argparse and asserts: (B1) tool resolves & ACTIVE,
  (B2) subcommand exists, (B3) `--workspace` is acceptable in a placement the runner actually uses —
  including the single-token-trap rule. Plugged into `tools/crucible.json` as a control. Itself defines
  `--workspace` on the top parser (so it is cron-safe). Test: `tests/test_cron_conformance.py`.

---

## Track B — Identity persistence & self-care (owner principle 5)

### Why boot Step 0 reports persistence MISSING (verified)
Two independent gaps:
1. **Probe drift (cosmetic):** `startup.md` Step 0 probes the literal `~/.claude/output-styles/axon.md`,
   but the machine moved to a **two-instance chooser** (`axon-dev.md` for this repo, `axon-use.md`).
   `axon.md` no longer exists → MISSING mis-fires though AXON is functionally loaded.
2. **Re-anchor hook never installed (decisive):** `~/.claude/settings.json` has **no `UserPromptSubmit`**
   key and no reminder file. Mechanism 2 of the 4-artifact design — the one that re-injects "you are AXON"
   on *every* turn to survive compaction — is entirely absent. Between turns only the start-of-session
   Output Style holds the line. This is exactly the "thin persona, not AXON" failure mode principle 5 warns of.

The identity **contract** already exists in KERNEL (IDENTITY, the 8-clause identity-contract, identity gate,
coherence guardian) and a re-anchor **program** already exists (`workspace/programs/axon-reanchor.md`,
`autonomy-reanchor.md`); the harness contract declares `L:host-cap-reanchor = "userpromptsubmit-hook"`.
**The gap is wiring, not design.**

### "Cares for AXON" — no proactive self-maintenance today
Boot does cron-overdue + resume + project re-assert, but no boot-time health/freshness/drift heal, and no
single "tend to AXON" entry point. `L:health-score` shows "unknown" until a tool is run by hand.

### Decision — partition (inviolable floor: `axon/` kernel edits are human-only)
**NON-KERNEL — implement + (machine config) install now:**
- `startup.md` Step 0: probe `axon*.md` glob instead of the literal `axon.md`.
- `~/.claude` (machine config, not a repo commit): install the `UserPromptSubmit` re-anchor hook +
  `axon-dev-reminder.txt`; harden the reminder to assert `L:cognition-frame=AXON-OS`,
  `W:reasoning-mode=kernel-ops`, point at the identity gate, "EXEC(axon-reanchor) if drifting"; reinforce
  `output-styles/axon-dev.md` ("first turn → axon-reanchor if cognition-frame unset"). Reversible.
- `workspace/programs/self-care.md` (NEW): health + freshness check + cron overdue/breaker + drift gate +
  igap stats + **persistence self-check** (verify output-style + UserPromptSubmit hook + reminder present).
  `--heal` opt-in (freshness refresh + health re-probe; never edits `axon/`; prints the install command for
  a missing hook). `tests/test_self_care.py`. Register in `tools/REGISTRY.json` + `workspace/programs/REGISTRY.json`.
- `workspace/programs/menu.md`: add a `self-care` entry + a rolled-up "Care" status line.
- `workspace/harness/claude-code.md`: add a note/self-check that the declared `L:host-cap-reanchor`
  mechanism is actually installed (don't silently trust the declaration).

**KERNEL — prepare human-apply spec (NOT merged autonomously):** `99-kernel-spec.md`
- `axon/KERNEL-SLIM.md` response gate + `axon/OUTPUT-LAYER.md`: mandate a required per-response identity
  signature (promote the existing `▸ AXON …` footer to a gate-enforced marker) so a Stop hook can catch drift.
- `axon/BOOT.md`: auto-fire `axon-reanchor`/`autonomy-reanchor` at the compaction/turn boundary; optionally
  wire `self-care --quick` into BOOT Step 3; optional fail-closed persistence gating.

---

## Execution plan → PRs
- **PR-1 (Track A):** `cron.json` A1 + `freshness.py` A2 + `cron-conformance` tool + tests + `crucible.json`
  control + registry entries. One cohesive "cron↔tool contract" PR.
- **PR-2 (Track B):** `startup.md` probe + `self-care` program + test + `menu.md` + `harness/claude-code.md`
  + registry entries (repo). Machine-config persistence install done alongside (not a commit). Plus the
  prepared `99-kernel-spec.md` human-apply handoff.

## Gate / merge (verified)
`python3 tools/crucible.py gate` exit 0 = green (9 BLOCK controls incl. pytest, changeset-rules/
R_NEW_NEEDS_TEST, lint-commit-trailer). Commit trailer `Co-authored-by: AXON <axon@arturcastiel.github.io>`
only (no PR-N, no brand/model). Merge via `glab mr create` + `glab mr merge --squash --remove-source-branch`
on TNO GitLab (`git@ci.tno.nl`), gated on green. AEGIS resolver needs `--policy _policy.md`.

## Memory persistence (owner: "memory should also be added to code-dev and axon")
At completion: `code-dev journal decision/log/event` (project ledger) + `agent_memory.py capture --tier
general` (AXON self-memory, boot-loaded) + `--tier project --scope axon-resilience` + `memory.py` L: gate
flag / E: session-log trail. Checklist in `_meta.md` finalization.
