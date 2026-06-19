# AXON Architecture — Council Report

**Council:** AXON Architecture
**Charge:** Assess AXON's overall architecture — the 4-layer model (`axon/` kernel, `workspace/`, `my-axon/`, addons), the tool/program/rule system, enforcement, and memory scopes. Identify strengths, structural weaknesses, coupling, and risks.
**Seats synthesized:** (1) Layering / Boundary-Integrity, (2) Enforcement / Security, (3) Extensibility / Maintainability, (4) Challenger (deepest single flaw).
**Status:** ADVISORY. Findings are file-cited and spot-verified by the deliberator (see Verification Notes).

---

## 1. Executive Summary

AXON is a markdown-driven OS for AI agents whose central differentiator — stated verbatim in the kernel (`axon/KERNEL-SLIM.md:510`, *"Replaces behavioral compliance with mechanical checks"*) — is that **mechanical enforcement replaces voluntary model compliance**. The council's collective finding is that this claim is **true in exactly one place and structurally weak everywhere else.**

**What is genuinely strong.** The `axon/` kernel write-gate (Core Rule 9 / "R9") is real enforcement: a PreToolUse hook (`tools/hooks/enforce_pretooluse.py`) installed via `.claude/settings.json` denies (exit 2) writes to `axon/` across `Write|Edit|NotebookEdit|MultiEdit|Bash`, is **identity-independent** via the git-tracked `.axon-governed` sentinel (fires on a fresh clone / CI before any persona boots), closes the historical `echo x > axon/...` Bash bypass, and resolves paths through a single realpath-based classifier (`tools/_axon_paths.py::is_axon_path`) that collapses the symlink / `..` / absolute-path bypass class. All four seats independently affirm this as the model of what AXON enforcement *should* look like. Surrounding it is a mature, registry-driven extensibility surface (187 tools / ~174 programs / 37 rule files) held together by a single-source `tools/REGISTRY.json`, drift gates, parity tests, and a program-authoring contract (`# synapse:` metadata on 172/174 programs).

**Where it breaks.** The strong gate has a **soft center and an unprotected guard**:

- **The authorization flag is ungated (critical).** R9 reduces to `if is_axon_path(target) and not dev_mode: BLOCK`. But `dev-mode` lives at `workspace/memory/longterm/dev-mode.md` — *outside* `axon/`, so R9 does not protect it — and `tools/memory.py set --scope L --key dev-mode --value true` has **no gate at all**. Any agent or Bash call can flip the god-flag and then write the kernel freely. The lock and the key are in the same unlocked drawer.
- **The guard is less protected than what it guards.** `tools/` (the entire enforcement engine) and `.claude/settings.json` (which *installs* the hook) belong to **no layer** and are gated by **nothing**. A single plain `Write` to `tools/rules/r9_axon_write.py` (→ `return None`) or to `.claude/settings.json` (drop the hook) neutralizes R9 globally, and no layer rule fires.
- **A claimed OS backstop does not exist.** `tools/shell.py:95-96,335` asserts the undecidable computed-path / env-indirection residual is "closed by the OS write-barrier (G1c)." Grep finds **no** chattr / immutable / read-only-mount / `0o444` mechanism. G1c is aspirational; the residual is open.
- **Everything above the write-gate is advisory.** The response gate (`verify_stop.py`) is LOG-ONLY (a Stop hook cannot un-send), so a violating output is *always delivered at least once*; it merely gates the next turn, which **silently expires after 1 hour** (`next_turn_gate.py:30,66`) and is cleared on first read. At default configuration **zero** `*-required` activation flags are set, so the runtime BLOCK surface collapses to essentially **one** live rule (`r_coherence`, a ~20-regex phrase blocklist). And **14 of 37 rule files on disk are not registered** in the verifier.

**The keystone risk (Challenger thesis, council-endorsed):** strip the enforcement claim and AXON is a very well-organized 757-line **prompt** whose compliance is exactly as reliable as the host model's willingness to obey prose — the baseline AXON claims to transcend. The architecture is unusually *honest* about this in its own comments (`KERNEL-SLIM.md:89-95`, `verify.py:291-293`), but documenting a load-bearing gap is not closing it.

**Top-line recommendations (detailed in §3):** gate the dev-mode toggle; bring `tools/` and `.claude/settings.json` under protection; either build G1c or delete the claim; close the prose↔wiring rule gap mechanically; ship a non-trivial default enforcement posture; and collapse the divergent tool duplicates.

---

## 2. Detailed Findings (file-cited)

### 2.1 The 4-Layer Model

The layer taxonomy is well-articulated doctrine at `axon/KERNEL-SLIM.md:553-565`: **Layer 1** `axon/` (immutable kernel), **Layer 2** `workspace/` (OS programs/tools/memory), **Layer 3** `my-axon/` (user data), **Layer 4** `addons/` (plug-ins).

**Strengths.**
- Real mechanical enforcement at the most important boundary (Layer 1), not aspiration — see §2.3.
- Clean, declarative Layer-4 addon isolation: `workspace/addons/*/requirements.md` is a self-describing contract (tools-required / programs-required / memory-keys / data-files); `soccer-manager` declares self-containment and depends only on `clock`+`calculator` (Seat 3). Addons are a true plug-in seam.

**Structural weaknesses.**
- **`tools/` is an unlayered, unprotected trust root (Seat 1, central defect).** The LAYERS section names `axon/`, `workspace/`, `my-axon/`, `addons/` — `tools/` appears in none, yet *is* the enforcement engine. Proven: `is_axon_path('tools/rules/r9_axon_write.py')`, `is_axon_path('tools/hooks/enforce_pretooluse.py')`, and `is_axon_path('.claude/settings.json')` all return **ALLOWED** (ungated). Core Rule 9 ("Programs may never WRITE to axon/", `KERNEL-SLIM.md:70`) literally cannot be satisfied for the Python that *implements* Core Rule 9. This is an inverted boundary.
- **Layer 3 crosses the repo boundary via an external symlink and is `EXEC`'d at boot (Seat 1).** `my-axon -> /home/arturcastiel/projects/axon-sections/my-axon` is physically outside the repo root (verified). `MYAXON_ROOT` (`_axon_paths.py:28-32`) resolves to the symlink, but content lives on a disjoint path. Layer 3 has no write gate (by design — user data), yet boot **executes** `my-axon/MYAXON.md` to load `STORE(W:myaxon-*)` path keys (`KERNEL-SLIM.md:615-616`) — an ungated, externally-symlinked file influencing Layer-1 boot control flow with no integrity check. The sibling `.venv` symlink is **already dangling** (verified: `test -e .venv` = NO), demonstrating the portability fragility of this scheme.

### 2.2 Tool / Program / Rule System

**Strengths (Seat 3).**
- **Tool registry is a genuine SSOT with mechanical drift detection.** `tools/REGISTRY.json` is read by `axon.py:35-48`; `tools/registry_drift.py` catches registry-orphans, fs-orphans, and status mismatches (live: 178 registered / 178 on-disk / drift 0). The dispatcher is a thin ~120-line subprocess shim with aliases and an execution-receipt ledger.
- **The rule→runner fan-out problem was identified and locked.** `tools/rules/manifest.py:1-13` documents that rule membership was once spread across four disjoint hand-maintained lists (F38: "forgetting one silently drops it from a gate"); a parity test (`test_rules_manifest`) now locks the lists to the manifest.
- **Path resolution consolidated.** `tools/_axon_paths.py` (imported by 89/187 tools) is the single anchor; its docstring records it "Replaces 3 divergent in-process impls" of `is_axon_path`, one of which was cwd-relative and broken (`_axon_paths.py:51-53`).
- **Program authoring has a contract + gate.** `tools/synapse_validate.py` checks `# synapse:` records against a v1.1 schema; `tools/neuron_audit.py:79-81` yields a PASS/FAIL verdict; Core Rule 13 (`R_NEW_NEEDS_TEST`, *registered*) blocks registering an untested neuron ACTIVE. 359 test files back this.
- **Generated docs de-hardcoded.** `tools/docgen.py:716-720` derives the live tool count from the registry, citing a past failure where Mermaid said 44 while the registry held 156.

**Weaknesses.**
- **Three tool-definition surfaces with divergent, git-tracked duplicates (Seat 1).** Tools exist as `tools/*.py`, `axon/tools/*.md` cards, and `workspace/tools/*`. Nine names — `context, cron, deps, drift, events, hooks, pack, rtk, simulate` — are physically separate committed copies in **both** `tools/` and `workspace/tools/`. **Verified drift:** `drift.py` is Jun 19 in `tools/` vs May 26 in `workspace/` (~3.5 weeks stale); `cron` Jun 18 vs May 26; `context` Jun 8 vs May 26. This is the exact split-brain failure the `_axon_paths` consolidation was meant to prevent, reproduced at the tool layer, with no shim and no SSOT pointer. `REGISTRY.json` plus the on-disk duplicate can disagree about which implementation is canonical.
- **`workspace/programs/menu.md` is hand-maintained despite an existing generator (Seat 3, #1 maintainability liability).** It is ~399 lines (~75 hardcoded entries), yet `programs_registry.py` already auto-generates a menu from `REGISTRY.json` and is described as "never stale" (`programs_registry.py:316-319`). **Verified: zero programs call `programs-registry menu`** — the static menu wins, and Core Rule 12 makes the menu CRITICAL ("partial output is a shell crash"), so silent staleness is high-severity and unguarded.
- **Program→tool conformance covers only ~20% of programs (Seat 3).** `tools/program_tool_conformance.py` checks `TOOL(name, sub, --flags)` call-sites against real argparse surfaces, but is scoped to 37 of 174 programs by its own docstring. The other ~137 can ship calls to nonexistent flags that fail only when a user hits the dead path — the same shadow-init class the tool's docstring describes.
- **The manifest is a locked *mirror*, not the literal source (Seat 3).** `manifest.py:10-13` states the follow-up (migrating the four runners to READ `rules_for_runner()`) is unfinished; the four lists still exist and must be hand-edited in lockstep — the parity test only converts a silent drop into a red test. The drift-cop also has drift: it says "30 kernel rule predicates" while there are 37 files.

### 2.3 Enforcement (the 4-tier stack)

Seat 2's frame: enforcement is a 4-tier stack whose tiers differ enormously in binding strength.

1. **Claude Code hooks** (`.claude/settings.json` → `tools/hooks/*.py`) — the ONLY tier that can mechanically *deny*. `enforce_pretooluse.py` (PreToolUse, exit 2 = deny); `verify_stop.py` (Stop, LOG-ONLY); `next_turn_gate.py` (UserPromptSubmit, exit 2 = deny next turn).
2. **In-process write gate** (`tools/_axon_io.py::atomic_write`) — raises `R9WriteError` for axon/ writes without dev-mode, but only for writes routed *through* `_axon_io`.
3. **Shell static gate** (`tools/shell.py::gate_check`) — static argv parser for cp/mv/tee/redirect/interpreter/nested-sh; **fail-closed** on parser exception (`shell.py:337-356`, correct default).
4. **Rules + verify** (`tools/rules/*`, `tools/verify.py`) — overwhelmingly **advisory lint** over program *source text* and the agent's *self-reported* final message.

**Strong (all seats concur).** The sentinel-gated, SSOT-classified R9 axon/ gate (tier 1+2) is the strongest part of the system. `.axon-governed` is tracked, so the gate survives a clone and is not contingent on gitignored runtime state. The Bash R9 extension (`enforce_pretooluse.py:196-220`) reuses `shell.gate_check` to close the live-proven `echo x > axon/KERNEL-SLIM.md` bypass (the `_pwned.cmp.md` reference at line 200). Audit trails exist (`E:shell-log`, `E:source-log`, append-only `response-gate-log.jsonl`).

**Weak / broken — the soft center:**

- **W1 (CRITICAL): the dev-mode toggle is itself ungated (Seat 2).** `tools/memory.py set --scope L --key dev-mode --value true` has no gate (verified). `dev-mode` is outside `axon/`, so R9 doesn't protect it. `KERNEL-SLIM.md:198` ("only L:dev-mode≡true authorizes") is prose to the model, not a mechanical control. Confused-deputy: the flag that authorizes kernel writes is writable without authorization. **dev-mode is also a global god-flag** — binary, process-wide, no path-scoping, no expiry, no per-write authorization. One flip unlocks the entire kernel for the session.
- **W2: G1c does not exist (Seat 2).** `shell.py:95-96,335` claims the undecidable residual (computed path / base64 / env indirection) is "closed by the OS write-barrier (G1c)." **Verified: no chattr/immutable/read-only/0o444 mechanism anywhere.** `python3 -c "open(os.environ['X'],'w')"` with an axon/ path in env defeats the shell static gate with no backstop. A control is *asserted in comments* that the code does not implement.
- **W3: the hook config is editable by the agent it governs (Seats 1+2).** `.claude/settings.json` is tracked but outside `axon/`, so R9 doesn't protect it. In dev-mode-off, an agent can Edit it to remove the PreToolUse hook entirely. The enforcement substrate does not protect its own root of trust. (Same defect class as `tools/` in §2.1.)
- **W4: the response gate cannot block — it logs and defers (Seats 2+4).** `verify_stop.py:6-8,106-130` is LOG-ONLY and always exits 0 ("a Stop hook cannot un-send"); the violating text is *already delivered*. `next_turn_gate.py:77-90` denies the next turn, but the pending gate has a **1-hour TTL** (`:30,66` — verified `_GATE_TTL=3600`) and is consumed on first read, so a single throwaway prompt absorbs it. This contradicts kernel language like "output does not render until violation is cleared" (`r_coherence.py:9`). "Fail loudly" becomes fail-silently-on-a-timer.
- **W5: Core-Rule "enforcement" is regex lint over English (Seats 2+4).** `r_override_attempt.py:57-66` matches bypass-VERB + gate-NOUN; any paraphrase ("set the development flag before touching the core") evades. `r_identity_lock` / `r_override_attempt` are STATIC lint over program *source*, default-WARN, opt-in-BLOCK via ungated `*-required` flags. `r_coherence.py:20-50` (the one live default rule) is ~20 hardcoded regexes (`\bas an ai\b`, `\bi think\b`) — phrase shape, not semantics: false negatives on clean-phrased persona slips, false positives on quoted user text.
- **W6: allow-all-on-clone for state-driven rules (Seats 2+4).** `workspace/memory/longterm/` and `working/` are gitignored. On a fresh clone / CI: R9 still fires (sentinel), but every opt-in BLOCK rule, the merge carry-list (`verify.py cmd_merge`), and all `*-required` flags **fail open** — `verify.py:291-293` admits this. The strict tier evaporates exactly where CI should be strictest.
- **W7: `_R9_WHITELIST` actor-bypass (Seat 2).** `_axon_io.py:33` — `frozenset({"loop-receipt"})` lets the `loop-receipt` actor write `axon/` with dev-mode OFF (verified). `_actor` is a caller-supplied string (`atomic_write(..., _actor="loop-receipt")`); any in-process caller can set it. An un-authenticated capability string — small today, a pattern that grows.
- **W8: two enforcement gates with mirrored-not-shared logic (Seats 1+2).** `enforce.py::is_inside_axon` (CLI gate, `:34-53`) deliberately *mirrors* rather than *calls* `_axon_paths.is_axon_path` (noted at `_axon_paths.py:53`). The R9 *rule* falls back to `os.getcwd()` (`r9_axon_write.py:38`) while the R9 *CLI* anchors to `AXON_ROOT` — **different default anchors**, the exact divergence class the consolidation killed elsewhere.

### 2.4 The Challenger Synthesis — the runtime BLOCK surface collapses to ~1 rule

Seat 4's chain (corroborated by Seat 3's independent count):

- **Zero `*-required` flags are set (verified: `ls workspace/memory/longterm/*-required.md` → nothing).** Every opt-in rule defaults to WARN/silent; `verify.py:181-186` blocks only on BLOCK. The default runtime BLOCK surface reduces to a handful of no-flag RUNTIME rules, of which essentially **one** (`r_coherence`) does real work — and it is a phrase blocklist (W5).
- **14 of 37 rule files on disk are not registered (verified by diffing disk against `registry.py`):** `r_identity_lock, r_override_attempt, r_cognition_language, r_neuron_role, r_fail_format, r_memory_respected, r_phase_tracked, r_workflow_node_order, r_autonomy_breaker, r_autonomy_cadence, r_code_change_requires_pr_phase, r_reservoir_output, r_no_orphan_tools, r_inference_mode_lock`. Several are named in spirit throughout the kernel's IDENTITY/Override sections yet are dead code from the verifier's view. (Seat 3 frames the related fact that 22 of 36 predicates never run in the *live verify* gate as *intentional* partitioning across lint/audit/crucible runners — see Dissent §4.)
- **Major kernel gates have no enforcer at all.** The active-program-interrupt gate (`KERNEL-SLIM.md:202-258`, ~55 lines, declared "!CRIT … not bypassable"), context-pressure-gate, and confidence-gate have **zero** matching rule files. In running code they are pure agent discipline.

The kernel concedes the gap honestly (`KERNEL-SLIM.md:89-95`), and the hooks now exist — but with no activation flags set and a third of the rules unwired, the mechanical layer "replaces almost nothing; it observes, after the fact, a thin slice, via regex, with a 1-hour amnesia timer."

### 2.5 Coupling Map

- **Layer-1 → Layer-2 doc coupling is heavy (Seat 1):** `KERNEL-SLIM.md` hardcodes `workspace/` paths 22× and `my-axon`/`myaxon` 35×. The immutable kernel knows the concrete layout of the layers above it (mitigated by `W:ws-*` indirection keys, but literals remain).
- **EXEC resolution spans 3 layers in one lookup (Seat 1):** `{ws-os}/programs/ → {ws-programs} → addons/*/` (`KERNEL-SLIM.md:734`). No namespace prefix, so a Layer-4 addon can silently shadow a Layer-1 program name.
- **Central well-designed hubs (Seat 3):** `_axon_paths.py` (89 importers), `REGISTRY.json` (22 tool consumers), `rules/manifest.py` (4 runner consumers). High fan-in but deliberate shared kernels, not copy-paste.
- **Registry SSOT with two markdown mirrors** (`axon/tools/REGISTRY.md`, `workspace/tools/REGISTRY.md`, "workspace overrides on conflict") — semantics correct, but the divergent `.py` copies (§2.2) mean the registry and disk can disagree on canonicity.
- **`aegis_policy` is purely advisory (Seat 2):** `aegis_policy.resolve()` returns a verdict dict (INVIOLABLE = kernel-edit, force-push, reset-hard, branch-delete, destructive) but nothing forces callers to consult it. `kernel-edit` inviolability reduces back to R9/dev-mode (W1); `git push --force` and `git reset --hard` are **not** in shell's `_HARD_FORBIDDEN` (`shell.py:59-73` blocks sudo/rm-rf/dd/eval/exec/mkfs only).
- **Largest single-file maintenance load (Seat 3):** `workflow_run.py` (968 LOC), `dag.py` (875), `dual_agent_eval.py` (852), `axon_audit.py` (776) — decomposition candidates. And the kernel itself: a single hand-edited 757-line `KERNEL-SLIM.md` mixing immutable rules with procedural pseudo-code that no parser validates against the Python implementing it.

### 2.6 Memory Scopes

- Memory uses scope-prefixed keys (`L:` long-term, `W:` working, `E:` event/audit; plus `STORE(W:myaxon-*)` path keys loaded at boot). `tools/memory.py` is the writer.
- **The scope boundary is also the security boundary, and it leaks (Seats 2+4):** the highest-privilege flag (`L:dev-mode`) lives in ordinary `L:` long-term memory outside `axon/`, ungated (W1). `L:` writes go through `memory.py set` with no R9 check.
- **Working memory is gitignored**, so all state-driven enforcement fails open on clone (W6). Memory scoping conflates "user data" with "authorization state" — the dev-mode god-flag should not share a drawer with notes.

---

## 3. Prioritized Recommendations

Severity-ordered, merging overlapping seat recommendations. Each cites the originating finding.

### P0 — Critical (the gate has a soft center / unprotected guard)

1. **Gate the dev-mode toggle itself (W1).** A capability that authorizes kernel writes must not be writable without authorization. Add a PreToolUse pattern in `enforce_pretooluse.py` that denies any Write/Edit/Bash setting `dev-mode=true` unless a human-controlled out-of-band token/env is present, or require a signed/TTL'd token the agent cannot mint. *Today the lock and the key are in the same unlocked drawer.*
2. **Bring `tools/` and `.claude/settings.json` under protection (Seat 1 W1, Seat 2 W6, Seat 4).** Either extend `is_axon_path` to an `is_protected_path` covering `tools/`, `tools/hooks/`, `tools/rules/`, and `.claude/settings.json` behind a gated `L:dev-mode`, **or** add a formal "Layer 0 — enforcement core" to `KERNEL-SLIM.md:553-560` gated identically to `axon/`. *The guard must be at least as protected as what it guards.*
3. **Build G1c or delete the claim (W2).** Implement the OS write-barrier the comments promise (`chmod a-w`/`chattr +i` on `axon/` outside dev-mode windows, or a read-only bind mount — which would subsume much of R9), **or** strike the "closed by G1c" comments in `shell.py` so the open residual is documented honestly. *Right now the code asserts a control that does not exist.*

### P1 — High (close the prose↔runtime gap)

4. **Close the prose↔wiring rule gap mechanically (Seats 3+4).** Add a meta-rule / test asserting every `tools/rules/r_*.py` is registered and every BLOCK rule *named* in `KERNEL-SLIM.md` resolves to a wired, reachable predicate. Fix or delete the 14 unregistered rule files. *The unregistered files are the single most damning fact; never let it recur silently.*
5. **Ship a non-trivial default enforcement posture (Seat 4).** Zero `*-required` flags = the OS arrives disarmed. Decide which rules are *constitutive* of AXON (identity, cognition-language, memory) and have them BLOCK by default, not behind ~18 opt-in files an operator must discover.
6. **Stop selling "BLOCK before render" — or make it true (Seat 4 W4).** The Stop hook cannot un-send. Either move the identity/coherence check to a PreToolUse/streaming surface that can actually suppress, or rewrite every "does not render until cleared" kernel claim to the honest "gated next turn, may expire," and **remove the 1-hour TTL for !CRIT-class violations** (an identity breach should never silently age out).
7. **Close the clone fail-open (W6).** Track a minimal default-strict policy file, or have `verify.py cmd_merge` and the `*-required` checks fail *closed* (or loudly N/A) when `workspace/memory/working/` is absent.

### P2 — Medium (maintainability / drift)

8. **Collapse the 9 divergent tool duplicates to one SSOT (Seat 1).** Make `tools/*.py` canonical; replace each `workspace/tools/<n>.py` with a thin re-export shim or delete it; make `REGISTRY.json` the only path authority; add CI that fails if a name resolves to two divergent files.
9. **Make `menu.md` consume `programs-registry menu` (Seat 3).** Eliminate the largest unguarded hand-maintained surface — the EXEC pattern already exists at `menu.md:24` (it EXECs `axon-state menu-snapshot`).
10. **Finish the manifest follow-up (Seat 3).** Have the 4 runners READ `rules_for_runner()` so the manifest is the literal source — deletes 4 hand-edited lists and would make the wiring gap self-evident.
11. **Reclassify the text-lint rules (Seat 2 W4).** Stop framing `r_override_attempt` / `r_identity_lock` as Core-Rule *security*; they are authoring linters. Real behavioral enforcement can only live at the tool-call boundary.
12. **Add a kernel-conformance test (Seat 3)** asserting every gate/rule named in `KERNEL-SLIM.md` has a wired predicate — closes the prose-vs-code gap and would have surfaced the interrupt-gate / confidence-gate "no enforcer" finding.
13. **Widen `program_tool_conformance` toward all programs (Seat 3)** so the program↔tool contract is enforced for the ~80% currently unchecked.

### P3 — Low / latent

14. **Unify the R9 anchor (Seat 1):** default `r9_axon_write.py:38` to `AXON_ROOT` (matching `enforce.py`), not `os.getcwd()`.
15. **Authenticate or remove `_R9_WHITELIST` (Seat 2 W7)** — an un-authenticated caller-supplied actor string is a bypass primitive.
16. **Add `git push --force` / `git reset --hard` to shell `_HARD_FORBIDDEN` (Seat 2)** so the "inviolable" git ops are mechanically refused at the chokepoint, not just advisory in `aegis_policy`.
17. **Integrity-check `MYAXON.md` before EXEC at boot (Seat 1):** parse-and-whitelist only `STORE(W:myaxon-*)` lines instead of executing the file wholesale; fix the dangling `.venv` symlink and make the path layer survive a fresh clone (Seat 4).
18. **Namespace EXEC resolution (Seat 1)** or at minimum WARN when a Layer-4 addon name shadows a Layer-1/2 program.

---

## 4. Open Questions / Dissent

The four seats converge strongly on the core picture: **R9 is real and well-built; the authorization flag and the guard's own code are unprotected; everything above the write-gate is advisory and largely disarmed by default.** Seats 1, 2, and 4 each independently identified the `tools/` + `.claude/settings.json` unprotected-guard defect and the dev-mode/clone fail-open weaknesses. The disagreements are matters of *framing and severity*, preserved here:

- **D1 — Is the unwired-rules count a bug or intentional partitioning?** **Seat 4 (Challenger)** treats "14 of 37 rule files not in `ALL_RULES`" as *damning dead code* and the system's most indicting single fact. **Seat 3 (Maintainability)** is more measured: it agrees 22 of 36 predicates never run in the *live verify* gate, but frames the partition across `lint`/`audit`/`crucible` runners (per `manifest.py`) as *intentional* — the footgun being that the kernel presents rules as "always active" when they are static-lint or merge-time only. *Open question:* are the 14 files genuinely unreachable from *any* runner, or reachable only from non-verify runners? (The deliberator confirmed they are absent from `registry.py` name-references; per-runner reachability via the manifest was not exhaustively traced and should be resolved before deciding "fix vs delete.")

- **D2 — What is *the* deepest flaw?** **Seat 1** nominates the unlayered/unprotected `tools/` trust root (the guard is less protected than what it guards). **Seat 2** nominates the ungated dev-mode toggle (the lock and key in the same drawer). **Seat 4** nominates the broader thesis that the entire "mechanical > behavioral" value proposition is structurally false at default config. These are not contradictory — they are three views of one keystone (an enforcement layer whose *authorization*, *implementation*, and *default posture* are all softer than the gate it fronts) — but the council did not converge on a single "deepest" label. The synthesizer ranks dev-mode (P0 #1) and the unprotected guard (P0 #2) jointly highest because they are the smallest changes that most enlarge the real enforcement surface.

- **D3 — How much credit does "honesty in comments" earn?** All seats note the kernel documents its own gaps (`KERNEL-SLIM.md:89-95`, `verify.py:291-293`) and praise it as engineering integrity. **Seats 2 and 4** are firm that *documenting* a load-bearing gap is not *closing* it, and that several controls are "documented as enforcing when they are advisory or aspirational" — i.e., the honesty does not neutralize the risk. No seat dissents from this, but the weight placed on it varies.

- **D4 — Scope of "G1c."** Seat 2 reads the `shell.py` comments as asserting a non-existent control (verified: no immutability mechanism). Whether G1c was ever prototyped elsewhere (outside `shell.py`/`tools/`) was not exhaustively searched; the recommendation (build or delete) holds either way.

### Verification Notes (deliberator spot-checks, read-only)
The following load-bearing claims were independently confirmed: 0 `*-required` flags present; `dev-mode.md` sits outside `axon/`; `my-axon` symlinks to an external path and `.venv` is dangling; kernel is 757 lines; 37 `r_*.py` files on disk with 14 not name-referenced in `registry.py`; tool duplicates `drift/cron/context/...` are committed in both `tools/` and `workspace/tools/` with confirmed multi-week mtime drift (`drift.py` Jun 19 vs May 26); `_R9_WHITELIST = frozenset({"loop-receipt"})` and `_actor`-based bypass present; `_GATE_TTL = 3600`; G1c referenced only in `shell.py` comments with no chattr/immutable/`0o444` implementation; zero programs invoke `programs-registry menu`. No claim was found to be overstated.
