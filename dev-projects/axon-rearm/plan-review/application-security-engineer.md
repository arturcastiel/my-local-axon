# Plan Review — Tier 2 Security Floor (Application Security Engineer)

**Reviewer seat:** Application Security Engineer (AXON hr-team catalog, `software/security`)
**Charge:** Threat-model the Tier 2 "security floor" of the axon-rearm plan — PR-T2-1 (gate dev-mode toggle), PR-T2-2 (protect `tools/` + `.claude/settings.json`), PR-T2-3 (G1c FS barrier or delete claim), PR-T2-clone (clone fail-open → closed, OD-6). Is this sufficient to close *"the guard is less protected than what it guards"*? What can still write the kernel with dev-mode off, post-plan?
**Mode:** adversarial / pre-mortem. Read-only verification on the live tree at `/home/arturcastiel/projects/new-axon/axon` (branch `fix/wave-g-residual-hardening`). Advisory only.
**Standards applied:** OWASP ASVS V1 (Architecture/Trust Boundaries), V4 (Access Control), STRIDE (Elevation-of-Privilege + Tampering), least-privilege / deny-by-default, NIST SP 800-53 AC-3/AC-6/CM-5.

---

## 1. Verdict

**SOUND-WITH-RISKS — confidence: HIGH.**

The Tier 2 backlog correctly identifies *the* load-bearing AppSec defect (the privilege-escalation primitive: an unprotected `dev-mode` flag that unlocks all kernel writes) and the right set of surfaces to close (the toggle, the engine, the hook installer, the OS barrier, the clone fail-open). The threat-model is correct and the remediation *style* (deny-by-default, protect the guard at least as well as what it guards) is sound. **But as written the four PRs do not yet close the boundary**, because (a) PR-T2-1's authorization mechanism is specified only as a goal ("a human-controlled out-of-band token") with no design, and a naive implementation re-introduces the same self-grant it is meant to stop; (b) the `is_protected_path` expansion in T2-2 has at least four residual write vectors that the four PRs as scoped do not enumerate; and (c) there is an **ordering/coupling hazard** — the `-required` flags armed in PR-T0-2 live in the *same* unprotected `workspace/memory/longterm/` directory as `dev-mode`, so until T2-1/T2-2 land, an attacker (or a drifted model) can *disarm the whole of Tier 0/Tier 1* by writing flag files, and the plan arms before it protects. The bones are right; the boundary is not yet provably closed. Hence SOUND-WITH-RISKS, not SOUND.

> AppSec tacit rule applied: *"useful AppSec advice states which attack surface remains unacceptable."* Section 3 names the residual surfaces that are unacceptable to ship.

---

## 2. What the plan gets right (verified on the tree)

1. **It correctly names the escalation primitive.** `dev-mode` is the god-flag: every mechanical R9 enforcer keys on it. Verified in four places — `tools/enforce.py:74-93` (CLI gate `cmd_check_write`), `tools/rules/r9_axon_write.py:43-48` (`state.get("dev_mode")`), `tools/_axon_io.py:122` (in-process write-gate), `tools/shell.py:351-364` (shell gate). All four read `L:dev-mode` via the canonical `_longterm.read_from_workspace`. Whoever controls that one file controls every kernel write. PR-T2-1 puts the highest-value asset first — correct prioritization.

2. **It correctly diagnoses the "lock and key in the same unlocked drawer" geometry.** I verified empirically that the asset is *outside* the boundary that guards the kernel:
   ```
   is_axon_path('workspace/memory/longterm/dev-mode.md')          → False
   is_axon_path('tools/rules/r9_axon_write.py')                    → False
   is_axon_path('tools/hooks/enforce_pretooluse.py')              → False
   is_axon_path('.claude/settings.json')                          → False
   is_axon_path('workspace/memory/longterm/state-surfaced-required.md') → False
   is_axon_path('axon/KERNEL-SLIM.md')                            → True
   ```
   Every R9 gate (`enforce.py`, `r9_axon_write.py`, `_axon_io.py`, `shell.py`) protects **only** paths under `axon/` via `_axon_paths.is_axon_path()` (`tools/_axon_paths.py:42-61`). The toggle, the whole enforcement engine, the hook installer, and the activation flags all sit *outside* it and are protected by *nothing*. PR-T2-1 + PR-T2-2 target exactly this gap. This is the right boundary to move.

3. **R9 itself is genuinely strong and is the correct model to extend.** The PreToolUse hook (`tools/hooks/enforce_pretooluse.py`) is identity-independent via the **git-tracked** `.axon-governed` sentinel (`_axon_active()`, lines 165-183), is fresh-clone/CI-safe, and already closed the `echo x > axon/...` Bash bypass through `bash_axon_write_block` → `shell.gate_check` (lines 196-220, with fail-closed on parser exception at `shell.py:350-356`). T2-2's instinct — "extend `is_axon_path` → `is_protected_path`, gate it like `axon/`" — reuses a proven control rather than inventing one. ASVS V1.4: this is the right way to extend a trust boundary.

4. **The clone fail-open is correctly typed as a *distinguish-two-cases* problem, not a fail-closed-everything problem.** PR-T2-clone (OD-6) explicitly requires separating "no active project (legit-empty → allow)" from "state suppressed (→ block)." That nuance is correct and security-aware — a blunt fail-closed bricks every fresh clone and gets disabled in week one (the classic "control too blunt → turned off" failure). I verified the asymmetry exists on the tree: `.axon-governed` and `.claude/settings.json` are **tracked** (present on clone), while `workspace/memory/longterm/` and `workspace/memory/working/` are **gitignored** (absent on clone). So on a fresh clone the *guard fires* (sentinel present) but the *flags are gone* — exactly the split-state OD-6 must reason about.

5. **PR-T2-3 refuses to let a comment count as a control.** "Build G1c or delete the claim" is the correct AppSec posture (theme T2 in the study: *honesty ≠ enforcement*). A control asserted in `shell.py` comments but absent in code is worse than an acknowledged gap because it manufactures false assurance. Verified the residual is real: `shell.py:332-336` itself documents that the static argv parser cannot prove an interpreter script is axon-safe ("the undecidable computed-path residual is closed by the OS write-barrier (G1c)") — and grep finds **no** `chattr`/`0o444`/immutable implementation anywhere. The claim is currently uncashed.

6. **The method is right for a security floor.** "Reproduce-then-block, no fingerprint-only closure, no monkeypatching" (02-plan §Method) is exactly how you prove a gate bites. The HANDOFF flagging Tier 2 as "highest blast radius, own review" shows correct risk awareness.

---

## 3. Ranked risks / gaps (with the PR ids they touch)

Ranked by exploitability × blast radius. **R1–R3 are unacceptable to ship without the changes in §4.**

### R1 — [CRITICAL] PR-T2-1's authorization mechanism is undefined, and the obvious implementation is self-defeating.
**PR-T2-1.** The PR says "deny any Write/Edit/Bash setting `dev-mode=true` without a human-controlled out-of-band token" — but **does not specify what the token is, where it lives, who issues it, or how the gate verifies it without itself becoming a writable file.** I grepped the tree: there is *no* existing out-of-band-token / two-person / hardware-token / TOTP / owner-token primitive (`tools/session.py` and `r_workflow_node_order.py` hits are unrelated). This mechanism is **greenfield with no anchor.**

The trap (STRIDE: Elevation-of-Privilege): if the "token" is just another file on disk (e.g. `workspace/memory/longterm/dev-grant-token.md`), then the attacker who could write `dev-mode.md` can write the token file too, and we have moved the lock one drawer over — *the same drawer is still unlocked.* The current toggle path makes this concrete: `axon/programs/dev-mode.md` flips the flag via `STORE(L:dev-mode, true)` → `memory.py set --scope L --key dev-mode --value true` → `write_from_workspace` → `_axon_io.atomic_write` — and `atomic_write` only R9-guards `is_axon_path` targets (`_axon_io.py:122`), so the write to `longterm/dev-mode.md` sails through today. A token-file check that reads from the same `longterm/` dir inherits the same weakness.

**Worse:** there is already a confirmed actor-bypass in the write engine — `_R9_WHITELIST = frozenset({"loop-receipt"})` (`_axon_io.py:33`). Any code path that calls `atomic_write(..., _actor="loop-receipt")` skips R9 entirely. If PR-T2-1 implements its token check inside `atomic_write`/`memory.py` without also closing or constraining the whitelist, the `loop-receipt` actor is a standing escalation path to set `dev-mode=true`. **The PR must address the existing whitelist, not just add a new check.**

### R2 — [CRITICAL] PR-T2-2's `is_protected_path` has un-enumerated residual write vectors; "extend `is_axon_path`" is necessary but not obviously sufficient.
**PR-T2-2, and the *interaction* with PR-T2-1.** Extending `is_protected_path` to cover `tools/` and `.claude/settings.json` is correct, but the PR's test claim ("Write/Bash into `tools/rules/*.py` and `.claude/settings.json` BLOCKED with dev-mode OFF") under-specifies the surface. Residuals I can see today:

- **(a) The flag files themselves.** The Tier-0-armed `*-required` flags live in `workspace/memory/longterm/` — **not** under `tools/` or `.claude/`. If `is_protected_path` only adds `tools/` + `.claude/settings.json`, **the activation flags remain unprotected**, so an attacker disarms enforcement by *deleting/flipping the flags* rather than by writing the kernel. Verified: `is_axon_path('workspace/memory/longterm/state-surfaced-required.md') → False`. This is a parallel disarm path the PR text does not mention. **(See also R3 — same directory as dev-mode.)**
- **(b) `enforce.py` / `_axon_io.py` / `shell.py` themselves.** These ARE under `tools/`, so they're covered *if* the gate is path-based on `tools/`. Good — but confirm the gate covers `tools/*.py` at top level, not only `tools/rules/`. The test claim only names `tools/rules/*.py`. The R9 engine top-level files (`tools/enforce.py`, `tools/shell.py`, `tools/_axon_io.py`, `tools/_axon_paths.py`, `tools/hooks/enforce_pretooluse.py`) are the highest-value targets and must be explicitly in scope.
- **(c) `.claude/` beyond `settings.json`.** The hook commands resolve via `$CLAUDE_PROJECT_DIR/tools/hooks/*.py`. Protecting `settings.json` but not `settings.local.json` (Claude Code merges a local override file if present) leaves a documented override channel. Confirm the gate covers `.claude/settings*.json` and the hooks dir.
- **(d) Symlink / parent-dir vector.** `is_axon_path` follows symlinks via `realpath` (good), but the *new* protected roots (`tools/`, `.claude/`) need the same realpath treatment, plus protection against deleting-then-recreating the directory or replacing it with a symlink. ASVS V12.3 (file path). The PR should reuse `_axon_paths.is_axon_path`'s realpath anchor logic verbatim, not hand-roll a prefix check.

### R3 — [HIGH] Ordering hazard: the plan ARMS (Tier 0) before it PROTECTS (Tier 2), widening the window.
**PR-T0-2 vs PR-T2-1/T2-2.** The first-sprint order is `T0-1, T0-2a, T0-2, T0-3, T1-1, T1-2, T2-1, T2-2`. PR-T0-2 flips the `-required` flags **into the same `workspace/memory/longterm/` directory that is provably unprotected** until T2-1/T2-2 land. Between T0-2 and T2-2 there is a window in which the system is *armed but its arming switches are world-writable* — a model that drifts (or a malicious tool call) can write `state-surfaced-required.md = false` (or delete it) and silently re-disarm everything Tier 0/Tier 1 just turned on, with **no rule firing and no dev-mode required.** This is the "the guard is less protected than what it guards" defect *recreated at the flag layer*. The plan's own falsifiable prediction (drift subsides after arming) is corrupted if the flags can be flipped back invisibly. Security-correct ordering is **protect-then-arm**, or arm and protect in the *same* atomic change.

### R4 — [HIGH] PR-T2-clone "state suppressed → block" needs a tamper-evidence anchor, or it's spoofable.
**PR-T2-clone (OD-6).** Distinguishing "no active project" from "state suppressed" is the right goal, but the *signal* must be unspoofable. If the discriminator is "is `workspace/memory/working/` present?", an attacker who wants to suppress a gate just deletes the working dir to masquerade as "no active project (legit-empty → allow)" — turning the fail-closed into a fail-open by *removing* state. The PR mentions "the sentinel present → fail-closed" — good, the tracked `.axon-governed` is the right anchor — but the test claim must include the **adversarial** case: *active project whose state has been deleted to mimic empty.* Without that, the control is bypassable by deletion (STRIDE: Tampering via omission).

### R5 — [MEDIUM] PR-T2-3 G1c, if built, must not become a self-lock or a new bypass, and "dev-mode ON" must lift it correctly.
**PR-T2-3.** An OS immutability barrier (`chattr +i` / `0o444`) is defense-in-depth for the *undecidable computed-path interpreter vector* that `shell.py:332-336` admits it cannot statically catch — genuinely valuable. Two AppSec cautions: (i) the toggle that *applies and lifts* the barrier becomes a new privileged operation — it must itself be gated by the *same* authorization as dev-mode, or it's a side-door to make `axon/` writable; (ii) `chattr` requires the right FS + privileges and silently no-ops on others (tmpfs, some overlay/CI filesystems) — if it silently fails, you have re-created the T2 anti-pattern (a control that *looks* applied but isn't). The test must assert the barrier is *actually* in force (attempt a write, observe EPERM), not merely that the apply-command exited 0.

### R6 — [MEDIUM] `r_override_attempt` is not a mechanical backstop here — don't let it be counted as one.
**Cross-cutting.** `tools/rules/r_override_attempt.py` scans *reasoning prose* with a regex for words like "bypass/disable/override" (lines 58, 145-186) and is itself **gated behind yet another absent `-required` flag** (`override-guard-required`, lines 82-86). It does not — and cannot — mechanically block a `dev-mode.md` file write. If anyone argues "override attempts are already caught," that is false for the write vector. The only real control is the path-based write gate. State this explicitly so the prose rule isn't credited as coverage it doesn't provide.

### R7 — [LOW/INFO] The `.venv` external symlink and `my-axon` cross-boundary symlink are ambient supply-chain surface.
**Out of Tier 2 scope, flagged for the record.** `ls` shows `.venv -> /home/arturcastiel/opm-hd/axon-project/.venv` and `my-axon -> /home/arturcastiel/projects/axon-sections/my-axon` — both cross the repo boundary. Hooks execute `python3` from whatever environment resolves; a writable external `.venv` is a code-execution path *upstream* of every gate (the gate runs in the interpreter it's trying to protect). Not Tier 2's job to fix, but the threat model is incomplete without naming it: **the enforcement engine trusts its own interpreter, and that interpreter lives outside the protected tree.**

---

## 4. Specific changes to the plan before execution

Concrete, testable amendments. Each is a deny-by-default / least-privilege tightening.

**C-1 (PR-T2-1) — Specify the authorization mechanism; make it not-a-file-in-the-same-drawer.** Before coding, write the design: the out-of-band grant must live on a channel the *in-band* write path cannot reach. Options, in descending robustness: (i) an **env-var / out-of-process challenge** the human sets in the launching shell (`AXON_DEV_GRANT=<nonce>`), never on disk in a model-writable path; (ii) a grant file under **`axon/state/` (already R9-protected)** with a short TTL, so setting it *itself* requires the very dev-mode it authorizes — bootstrapped only by the human-run toggle program, never by a model tool call; (iii) at minimum, a grant file whose path is added to `is_protected_path` in the *same* PR. **Reject any design where the grant token is writable by the same Write/Bash a non-dev session can issue.** Add the explicit test: *a programmatic `memory.py set --key dev-mode --value true` (and a direct file Write to `longterm/dev-mode.md`, and a `echo true > .../dev-mode.md` Bash) are all DENIED; only the OOB path flips it.*

**C-2 (PR-T2-1) — Close or constrain the `loop-receipt` actor whitelist.** `_axon_io._R9_WHITELIST` is a standing R9 bypass. The PR must either (a) prove `loop-receipt` can never reach `dev-mode.md`/flag files (whitelist the *path*, `axon/state/loop-receipt.ledger.jsonl`, not the *actor*), or (b) constrain the whitelist to that one ledger path. Add a test asserting `atomic_write('workspace/memory/longterm/dev-mode.md', 'true', _actor='loop-receipt')` is DENIED.

**C-3 (PR-T2-2) — Bring the `-required` flag directory and the full engine into `is_protected_path`, explicitly.** Expand the scope (and the test claim) from "`tools/rules/*.py` + `.claude/settings.json`" to the **complete guard surface**: `tools/` (all, incl. top-level `enforce.py`/`shell.py`/`_axon_io.py`/`_axon_paths.py` and `tools/hooks/`), `.claude/settings*.json` (incl. `settings.local.json`), and **`workspace/memory/longterm/*-required.md` + `dev-mode.md`**. Reuse `_axon_paths.is_axon_path`'s realpath/anchor logic; do not hand-roll a prefix match (R2-d). Per-path tests for each new protected root, dev-mode OFF → BLOCK, dev-mode ON → ALLOW.

**C-4 (ordering) — Re-sequence: protect-before-arm, or co-land.** Move PR-T2-1 and PR-T2-2 **ahead of PR-T0-2** in the first sprint, OR make PR-T0-2 depend on PR-T2-2 in `03-prs/DAG.json`. Arming flags that live in a world-writable directory is a net-negative security state (R3). The first-sprint set should read `T0-1, T0-3, T1-1, T1-2, T2-2, T2-1, T0-2a, T0-2` — instrument and protect first, *then* arm. At minimum, add an explicit note that the arm-window is a known exposure and bound it to one PR.

**C-5 (PR-T2-clone) — Add the adversarial "deleted-to-mimic-empty" test.** The fail-closed discriminator must key on the **tracked** `.axon-governed` sentinel (present even when `working/` is deleted), not on the presence of gitignored state. Required test: *active project, then `working/` removed → still fail-closed (does NOT downgrade to legit-empty allow).* Document the rule: "state absence in a sentinel-present repo is *suppression*, not *no-project*."

**C-6 (PR-T2-3) — Verify the barrier is in force, gate its toggle, handle silent-no-op.** Test must attempt an actual interpreter computed-path write to `axon/` with the barrier applied and assert OS-level denial (EPERM), not just that `chattr` exited 0. The apply/lift operation must be gated by the dev-mode authorization (C-1), and must **loudly fail (not silently skip)** on filesystems where immutability is unavailable — surfacing "G1c UNAVAILABLE on this FS" rather than reporting closed. If it cannot be made reliable in CI, *delete the claim from `shell.py`* per the PR's own "or" branch; do not ship a comment-only control.

**C-7 (cross-cutting) — Add one meta-test: "the guard is at least as protected as the kernel."** A regression test that enumerates the guard surface (every R9 engine file, the hook installer, the flag dir, dev-mode) and asserts each returns `is_protected_path == True` and each is BLOCKED dev-mode-OFF. This is the single assertion that *proves the charge is closed* and prevents silent re-opening when someone later adds a new rule file or moves a flag. Ties directly to PR-T3-1's prose-vs-wiring meta-rule spirit — co-locate them.

**C-8 (record, out of scope) — Log the interpreter/`.venv` trust assumption as an accepted risk with an owner.** Per the seat's tacit rule "*who owns the risk after this advice becomes action?*" — the enforcement engine trusts the Python interpreter that runs it, which lives in an external, writable `.venv`. Tier 2 need not fix it, but the owner should explicitly accept it (or schedule it), not leave it unnamed.

---

## 5. Answer to the charge question: *"what can still write the kernel with dev-mode off, post-plan?"*

If the four PRs land **exactly as written today** (no §4 changes), these vectors survive — i.e. the boundary is NOT yet closed:

1. **The undefined OOB token (R1/C-1)** — if implemented as a model-writable on-disk file, dev-mode self-grant remains, and from there every `axon/` write is authorized. *Highest residual.*
2. **The `loop-receipt` actor whitelist (R1/C-2)** — `atomic_write(_actor="loop-receipt")` skips R9 regardless of dev-mode; if it can reach `dev-mode.md` or `axon/`, it's an open door.
3. **The activation flags (R2-a/R3/C-3)** — not under `tools/` or `.claude/`, so unless C-3 adds `longterm/*-required.md`, an attacker re-disarms enforcement by flipping flags, never needing to write the kernel at all.
4. **The arm-before-protect window (R3/C-4)** — between PR-T0-2 and PR-T2-2, the flags are writable and dev-mode itself is still writable; the kernel is one flag-flip away from un-gated.
5. **`settings.local.json` / hooks dir (R2-c)** — if T2-2 protects only `settings.json`, the local override and the hook scripts remain a disarm path.
6. **The undecidable interpreter computed-path write (R5)** — `shell.py` admits its static parser can't catch this; only a *working* G1c (C-6) closes it. If G1c is comment-only, this stays open with dev-mode off.

**With the §4 changes applied,** vectors 1–5 are closed by path-based deny-by-default protection of the *complete* guard surface plus a non-file authorization channel, and vector 6 is closed by a verified OS barrier (or honestly struck from the claim). At that point the charge — *"the guard is less protected than what it guards"* — is genuinely closed, and the meta-test (C-7) keeps it closed.

> Bottom line, stated as the seat must: **the unacceptable residual surface after the plan-as-written is the authorization channel for `dev-mode` and the `-required` flags themselves.** Close those (C-1, C-2, C-3) and re-order to protect-before-arm (C-4), and Tier 2 is sufficient. As written, it is directionally right but not yet provably closed.

---

*Reviewed read-only against the live tree 2026-06-19. No code, programs, or workspace state modified. Findings grounded in OWASP ASVS V1/V4/V12, STRIDE (EoP/Tampering), and NIST SP 800-53 AC-3/AC-6/CM-5. Advisory only — ownership of the residual interpreter-trust risk (R7/C-8) must be assigned by the owner before execution.*
