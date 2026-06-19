# Plan Review — Security Engineer

**Reviewer:** Security Engineer (named specialist)
**Scope:** Tier 2 security floor of `axon-rearm` — PR-T2-1, PR-T2-2, PR-T2-clone, PR-T2-3.
**Mode:** READ-ONLY. Live tree verified at `/home/arturcastiel/projects/new-axon/axon` on 2026-06-19. No code modified.
**Charge:** Is the Tier 2 floor sufficient to close "the guard is less protected than what it guards"? Does the out-of-band dev-mode token (T2-1) work against an agent with shell access? New attack surface from arming? What can still write the kernel with dev-mode off?

---

## 1. Verdict

**SOUND-WITH-RISKS — confidence HIGH.**

The Tier 2 PRs name the right four targets and the threat model behind them is correct: the OS today protects `axon/` with a real, identity-independent, multi-vector R9 gate (`enforce_pretooluse.py`, `shell.py:gate_check`, `_axon_io.atomic_write`, `r9_axon_write.py`, all delegating to one classifier `_axon_paths.is_axon_path`) — and then leaves the *key to that gate* (the dev-mode flag) and the *gate machinery itself* (`tools/`, `.claude/settings.json`) completely ungated. The plan correctly identifies all four gaps. But as written, the four PRs are under-specified at exactly the points where security correctness lives, and **two of them depend on a primitive (the "out-of-band token", an OS write-barrier) that does not exist in the tree and is not itself a PR**. Without tightening the acceptance criteria below, Tier 2 can ship "green" while leaving the kernel writable. The floor is necessary, correctly scoped, and not yet sufficient.

---

## 2. What the plan gets right

- **It targets the actual asymmetry.** I verified the finding is real and severe. `tools/rules/r9_axon_write.py` and `.claude/settings.json` are **git-tracked but gated by nothing** (`grep is_protected_path tools/ → no hits`; the PreToolUse hook only runs `enforce.py check-write`, which no-ops for any path outside `axon/`). A plain `Write` to `r9_axon_write.py` or `settings.json` neutralizes R9 globally with **no rule firing**. PR-T2-2's framing ("a plain Write to r9_axon_write.py must not neutralize R9") is exactly correct.

- **The dev-mode diagnosis is precise.** I confirmed live: `enforce.py check-write --target workspace/memory/longterm/dev-mode.md` → `{"allowed": true, ... "outside axon/ — no restriction"}`. The god-flag (`workspace/memory/longterm/dev-mode.md`) sits outside `axon/`, so **every** R9 enforcer ignores writes to it. It is writable by the `Write` tool, by `Bash echo > …`, by `memory.py set --scope L --key dev-mode --value true`, and by the model simply executing `STORE(L:dev-mode, true)` (see `axon/programs/dev-mode.md:24`). PR-T2-1's framing ("the capability that authorizes kernel writes must not be writable without authorization") is the correct security property. The lock and key are in the same unlocked drawer.

- **The G1c honesty call is right.** `shell.py:95-96` and `:335` assert the undecidable computed-path interpreter residual "is closed by the OS write-barrier (G1c)" — but `grep -rn 'chattr|0o444|immutable|write-barrier'` finds **only those comments, no implementation**. PR-T2-3's "build it or strike the claim" is the correct disposition; a control asserted in comments but absent in code is worse than a disclosed gap because a reader (or a later gate) trusts it.

- **The clone fail-closed instinct (OD-6/T2-clone) is right and the "distinguish no-active-project from state-suppressed" requirement is the correct nuance.** Fresh-clone gates that fail open are a classic CI-bypass; demanding a *loud N/A* rather than a silent pass is the right shape.

- **Method discipline is appropriate for security.** "reproduce-then-block, no fingerprint-only closure, no monkeypatching the defect away" (02-prs.md:4-5, HANDOFF.md:31-32) is exactly the standard a security floor needs. The plan already learned this lesson from the CR-13 `test_crucible_failopen.py` mock-the-defect-away failure.

---

## 3. Weaknesses / risks / gaps, ranked by severity

### S1 — CRITICAL — The "out-of-band token" (PR-T2-1) is undefined and, for an agent with shell access, likely unenforceable as stated.
PR-T2-1 says "deny any Write/Edit/Bash setting dev-mode=true without a human-controlled out-of-band token." The threat model question is: **what can the agent NOT forge?** An agent with `Bash` can write any file, set any env var in its own shell, and read anything readable. So the token must be anchored in something the *harness* controls and the *agent's tool calls* cannot reach:
- A file token (`workspace/…/dev-token`) is **defeated** — agent writes it.
- An env var the agent sets in `Bash` is **defeated** — but note the hooks run as fresh harness-spawned subprocesses; an agent's `Bash` cannot persist env into the *next* PreToolUse subprocess. An env var injected by the harness/owner *outside* the agent's tool sandbox (e.g. exported in the owner's profile before launching the session, never echoed into agent-readable state) is the **only** anchor with a chance of working. The plan must say this explicitly, or T2-1 is security theater.
- A real out-of-band path (owner types a confirmation in a side channel; a host hook the agent has no tool to invoke) is the robust answer but is **not specified** and may not be expressible in this harness at all.

**The plan currently states the requirement without a feasible mechanism.** As written, the most likely implementation — a sentinel file or a `L:` key — is forgeable by the very agent it must stop. Touches: **PR-T2-1**. This is the single highest-leverage gap in Tier 2: if the token is forgeable, the entire armed posture is one `echo` away from disarmed.

### S2 — CRITICAL — Arming the flags (PR-T0-2) is itself defeated by the clone fail-open, and Tier 2 does not protect the armed state.
This is a cross-wave interaction the plan misses. The `-required` flags are written to `workspace/memory/longterm/`, which is **gitignored** (`.gitignore:41: workspace/memory/longterm/`). I verified `_is_required()` in `r_memory_respected.py:38-54` **defaults to `False`** when the flag file is absent (line 54), and the sibling readers follow the same pattern. Therefore:
- On any **fresh clone or CI checkout**, the armed flags are *absent*, so every rule PR-T0-2 "armed" silently degrades **BLOCK → WARN**. The arming does not survive a clone. The CI gate that is supposed to enforce the armed posture runs *disarmed*.
- The armed flags also live in the same ungated, writable `workspace/memory/longterm/` as dev-mode — so an agent can **disarm any single rule** with `memory.py set --scope L --key phase-tracking-required false` (or `echo false > …`), with no rule firing. **Tier 2 protects neither the flags nor the directory they live in.**

PR-T2-clone addresses the *merge/`-required` checks failing open on absent state*, which is adjacent, but the plan never connects it to the fact that **A2's own product is gitignored**. And the "governed profile" referenced in PR-T0-2 / 01-study OD-1 **does not exist in the tree** — there is no profile mechanism; arming is just `memory.py set --scope L`. Touches: **PR-T0-2, PR-T2-clone, PR-T2-2**. The fix: the activation flags must be tracked (or derived from a tracked, R9-protected source) so the armed state is the *default on clone*, and the directory holding them must be brought under protection — otherwise "armed" is a property of one developer's untracked working tree only.

### S3 — HIGH — PR-T2-2 (`is_protected_path`) introduces a self-protection bootstrap problem and a self-referential trust gap.
Extending protection to `tools/` is correct, but it creates two new issues the PR must address:
1. **The protector protects itself.** Once `tools/rules/*.py` and `tools/hooks/enforce_pretooluse.py` are gated by dev-mode, *fixing a bug in the gate* requires dev-mode — fine — but the classifier that decides "is this path protected" (`_axon_paths.is_protected_path`) is *itself* in `tools/`. If an attacker can write `_axon_paths.py` they unprotect everything; if they can't, neither can a legitimate maintainer without dev-mode. The trust now rests entirely on dev-mode (see S1). The PR must state that `tools/` protection is **only as strong as the dev-mode gate**, which makes T2-1 a hard dependency of T2-2 — the plan lists them both as `depends —` (independent). **They are not independent: T2-2 is worthless if T2-1's token is forgeable.**
2. **Bash coverage parity.** R9's `axon/` protection took *four* enforcers and an explicit Bash-hole patch (`bash_axon_write_block` in `enforce_pretooluse.py`, plus the interpreter-literal vector in `shell.py`) to close. PR-T2-2's test ("Write/Bash into tools/… BLOCKED") must replicate **all** of those vectors for `tools/` + `settings.json`: Write/Edit/MultiEdit/NotebookEdit, `cp`/`mv`/`tee`/`sed -i`/redirects, `python3 -c "open('tools/...','w')"`, and nested `sh -c`. The plan's one-line test does not enumerate them; given how many vectors R9 needed, a single Write test will leave the Bash and interpreter vectors open. Touches: **PR-T2-2, PR-T2-1**.

### S4 — HIGH — PR-T2-3 (G1c) under `chattr +i` is mostly inoperable in this environment and the allowlist creates a recovery footgun.
The plan offers `chattr +i / 0o444 / read-only` "gated by dev-mode with the axon/state/ allowlist."
- `chattr +i` requires the filesystem to support immutable attrs and, to *set/clear* them, typically `CAP_LINUX_IMMUTABLE` (root). This is a **WSL2/ext4** tree; `chattr +i` may silently fail or require privilege the agent/owner session lacks. If it fails silently, G1c is *again* a claim-without-enforcement — the exact anti-pattern T2-3 exists to kill. The PR must **verify the barrier actually took** (re-stat, attempt a write, assert it fails) or fall back to `0o444` + the in-process gate, and **must not** report "closed" on a no-op `chattr`.
- `0o444` is trivially reversible by the same agent (`chmod u+w`), so it stops *accidental* writes only, not an adversary. The plan should be honest that `0o444`-only ≈ the in-process gate's strength, not the OS-barrier strength the comments promise.
- The `axon/state/` write-allowlist is a **new attack surface**: anything the OS legitimately writes (state, logs, rollback sidecars) is now a carve-out in an otherwise-immutable tree. If any kernel-trusted file can be *relocated* under or *symlinked* from `axon/state/`, the allowlist becomes a write channel into the kernel. The PR test must include a symlink/relocation probe of the allowlist boundary. Touches: **PR-T2-3**.

### S5 — MEDIUM — PR-T2-clone must not become a new fail-open via the sentinel.
The "distinguish no-active-project from state-suppressed" logic keys off "the sentinel present" (02-prs.md:73). `.axon-governed` is tracked, good. But the *decision rule* "sentinel present + working/ absent → fail-closed" means: an attacker who wants the gate to fail *open* deletes or empties the sentinel to masquerade as "no active project → allow." The sentinel says "DO NOT delete," but nothing enforces it (it's a tracked file, not gated). So the clone fail-closed logic inherits the sentinel's integrity, and the sentinel is ungated. The PR should treat **sentinel-absent in a context where it was expected** as itself suspicious (the git-tracked manifest expects it), not as a clean "no project." Touches: **PR-T2-clone, PR-T2-2** (the sentinel should arguably be a protected path).

### S6 — MEDIUM — `dont-do` and the `-required` readers are best-effort fail-open by design, which is correct for liveness but must be audited under the new posture.
`enforce_pretooluse.py` wraps `dont_do_violation` and `_active_project_dont_dos` in bare `except: return None/[]` ("a hook fault must never block a legitimate write"). That is a deliberate availability choice, and reasonable — but once Tier 2 makes these hooks load-bearing for *security*, a thrown exception is now a **silent security bypass**, not just a missed lint. The plan should add a meta-test (akin to D1's spirit) that the *security-critical* branches of the hook (R9 / dev-mode / protected-path) **fail closed**, while the advisory branches (dont-do) may fail open — and that the two are not conflated. Today `bash_axon_write_block` already swallows `except Exception: return None` (fail-open) on the R9 Bash path — that is a latent fail-open in the *security* branch and should be tightened to fail-closed-when-dev-mode-off, mirroring `shell.py`'s own `r9-fail-closed` pattern. Touches: **PR-T2-1, PR-T2-2** (and arguably a new hardening note).

### S7 — LOW — Ordering/dependency declarations understate coupling.
02-prs.md lists T2-1, T2-2, T2-clone, T2-3 as `depends —` (all independent). Per S1-S3 the true dependency is **T2-1 ⊳ {T2-2, T2-3}** (token integrity underpins both path-protection and the G1c gate) and **T0-2 ⊳ T2-clone/T2-2** (arming's product must be protected and clone-survivable). Executing them in the listed independent order risks landing T2-2 "green" while T2-1's token is still forgeable. Touches: **PR-T2-1, PR-T2-2, PR-T2-3, PR-T2-clone, PR-T0-2**.

---

## 4. Threat model: what can still write the kernel with dev-mode OFF (post-plan, as written)?

With Tier 2 as specified, dev-mode OFF, fresh-clone defaults:

1. **Forge the dev-mode flag (S1).** If T2-1's token is a file/`L:` key, the agent writes `true` to it (or the token alongside it) and dev-mode is ON → R9 opens. *Open unless the token is anchored outside the agent's tool sandbox.*
2. **Disarm a rule, then write (S2).** `memory.py set --scope L --key <rule>-required false` (ungated) flips any armed rule BLOCK→WARN, then a previously-blocked change passes. *Open — Tier 2 doesn't protect the flag dir.*
3. **CI runs disarmed (S2).** Any merge gate on a fresh checkout sees absent flags → WARN → passes. *Open unless flags are tracked/clone-survivable.*
4. **Patch the guard via an uncovered Bash/interpreter vector (S3).** If T2-2's test doesn't enumerate `tee`/`sed -i`/`python3 -c`/`sh -c` into `tools/`, those write `r9_axon_write.py` and neutralize R9. *Open unless full vector parity is tested.*
5. **Computed-path interpreter write into `axon/` (S4).** `shell.py` explicitly defers this to the non-existent G1c. Until T2-3 lands a *verified* barrier, `python3 -c "p=base64...; open(p,'w')"` into `axon/` is undecidable to the static gate → passes. *Open until G1c is real and verified-to-have-taken.*
6. **Allowlist channel via `axon/state/` (S4).** A symlink/relocation from the immutable tree into the writable allowlist. *Open unless boundary-probed.*
7. **Sentinel-masquerade to force clone fail-open (S5).** Empty `.axon-governed` → gate thinks "no project" → allows. *Open unless sentinel integrity is enforced.*
8. **Hook-exception bypass (S6).** Feed input that throws in a security branch that fails open. *Open on the `bash_axon_write_block` fail-open path.*

Vectors 1, 2, 3 are the ones that make "armed" reversible by a single ungated `echo`. **They must be closed for the plan to deliver its stated objective**; the rest are hardening.

---

## 5. Specific changes I would make to the plan before execution

1. **PR-T2-1 — define the token's trust anchor explicitly, and prove it survives an agent with Bash.** Acceptance must include: (a) the token lives somewhere the agent's Write/Edit/Bash/`memory.py` cannot reach — realistically a harness-injected env var exported by the owner *before* session start and never echoed into agent-readable state, or a true OOB owner confirmation; (b) a red-team test that *attempts* every forge path (Write the flag, Write a token file, `Bash echo`, `memory.py set`, env-set-in-Bash) and asserts each is **DENIED**, then asserts the legitimate OOB path is ALLOWED. If no in-harness anchor exists, say so and downgrade T2-1's claim to "owner-confirm gate" honestly rather than implying agent-proof.

2. **PR-T2-2 — make protection cover the flag directory and the sentinel, and test full vector parity.** Extend `is_protected_path` to include `workspace/memory/longterm/dev-mode.md`, the `*-required.md` activation flags, `.axon-governed`, `.claude/settings.json`, and `tools/`. Test matrix must replicate R9's full vector set: all four write tools + `cp/mv/tee/ln/install/sed -i/truncate` + redirect + `python3/node/perl -c/-e` literal + nested `sh -c`, each BLOCKED dev-mode OFF and ALLOWED ON. Declare the real dependency **T2-2 depends T2-1**.

3. **NEW sub-PR (or fold into T0-2/T2-clone) — make the armed posture clone-survivable.** The `-required` flags must be the *tracked default* (a tracked, R9-protected activation manifest the readers consult) so a fresh clone/CI boots *armed*, not disarmed. Until that exists, A2 is a property of one untracked working tree and CI enforces nothing. This is the most important missing item and the plan does not currently name it.

4. **PR-T2-3 — verify-the-barrier-took, and probe the allowlist boundary.** Acceptance: after applying the barrier, *attempt a write and assert the OS rejected it* (don't trust `chattr`'s exit code on WSL2/ext4); if the immutable attr can't be set, fall back to `0o444` + in-process gate and **report the degraded strength honestly** (no "closed by G1c" while it's `0o444`-only). Add a symlink/relocation probe of the `axon/state/` allowlist. If none of this is feasible in-environment, **strike the G1c claim from `shell.py:95-96,335`** — which the plan already offers as the alternative; make that the default unless the barrier is *proven* to take.

5. **PR-T2-clone — guard against sentinel-masquerade and assert security branches fail closed.** Treat an unexpectedly-absent/empty `.axon-governed` as suspicious, not "no project." Add the S6 meta-test: security-critical hook branches (R9, dev-mode, protected-path) fail **closed** on internal exception; tighten `bash_axon_write_block`'s `except Exception: return None` to fail-closed-when-dev-mode-off, mirroring `shell.py`'s `r9-fail-closed`.

6. **Re-declare Tier 2 dependencies** to reflect S7: `T2-1 ⊳ {T2-2, T2-3}`, `T0-2 ⊳ {T2-clone, T2-2}`. Land T2-1 (or at least its token decision) **first** within the wave; a green T2-2 over a forgeable token is a false sense of security.

---

## 6. Bottom line

The Tier 2 floor identifies every real gap and the threat model is correct, so the *plan's diagnosis* is sound. But three security-load-bearing primitives are either undefined (T2-1's token anchor), defeated by a cross-wave interaction the plan misses (the armed flags are gitignored → clone-disarmed → S2), or asserted-without-implementation in a hostile environment (T2-3's OS barrier on WSL2). As written, Tier 2 can pass its own tests while leaving the kernel one ungated `echo` from writable. Close S1, S2, and the vector-parity half of S3 before declaring the security floor done; the rest is hardening that the plan's own "reproduce-then-block, no-mock" discipline will catch if the acceptance criteria above are added.
