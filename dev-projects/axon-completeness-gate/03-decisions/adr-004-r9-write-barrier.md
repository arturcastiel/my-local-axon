# ADR-004 — R9 kernel-immutability: argv-recursion gate + OS-level write barrier

**Schema**: adr-v1 · **Status**: accepted · **Date**: 2026-06-19
**Owner**: arturcastiel · **Supersedes**: the implicit PR-07 "Bash-matcher denylist" decision
**Related**: ADR-003 (teeth reality), arch-audit finding #1 (CRIT), #4, #11

## 1. Title
How R9 ("programs/sessions may not write `axon/` without dev-mode") is *actually* enforced against the Bash tool — after an adversarial council + two plan-auditors proved the PR-07 denylist insufficient.

## 2. Status
**accepted** — supersedes the unrecorded PR-07 decision to enforce R9 over Bash via a command-shape denylist.

## 3. Context
PR-07 (`f055cae`) added a `Bash` PreToolUse matcher routing to `shell.gate_check`, an allow-by-default denylist over command *heads* (`cp`/`mv`/`tee`/`sed -i`/`dd`…) + a redirect regex. An hr-team council (2026-06-19) and two plan-auditors proved, by execution, that this leaves the **CRIT boundary open**:
- Interpreters are not heads: `python3 -c "open('axon/KERNEL-SLIM.md','w')..."`, `node -e`, `perl -e`, heredocs → **ALLOWED with dev-mode OFF** (verified live). `python3` is this repo's primary write primitive.
- The redirect regex `(?:>>?|2>|&>)` omits `1>`/`1>>`/`3>` → `echo x 1> axon/K` **ALLOWED**.
- A static argv parser **cannot decide** whether a `python3 -c` *script string* writes `axon/` — the path can be computed (`'ax'+'on/…'`), env-indirected, base64'd, `$()`-substituted, reached via a pre-opened fd or a symlink. Closure at the *command* layer is undecidable.
- The proposed in-process `sitecustomize.py open()` shim is **inert** for the attack: a bare `python3 -c` loads the system `/usr/lib/.../sitecustomize.py`, not the repo's; `python3 tools/X.py` from a non-root cwd doesn't load it either.
- Forcing fail-closed on *all* interpreter invocations causes an FP storm — **38 tracked files** legitimately use `python3 -c`/heredoc/`sh -c` for read-only work.

## 4. Decision
We will enforce R9 over Bash with a **layered control whose fail-closed floor is the filesystem, not the command parser**:

1. **Primary (cheap, precise) — argv-recursion gate.** Extend `shell.gate_check` to (a) recurse into interpreter `-c`/`-e`/heredoc payloads and re-apply the gate to the inner command, and (b) widen the redirect regex to all `\d*>>?`/`>|` forms. This kills every *literal* council PoC. It is exception-safe (a parser crash must fail **closed**, reversing today's fail-open at `enforce_pretooluse.py:218`).
2. **Floor (decidable, complete) — OS-level write barrier.** When dev-mode is OFF, `axon/` is made write-protected at the filesystem layer (read-only mode bits / immutable attr where available, re-asserted at boot and on dev-mode toggle), with a documented allowlist for legitimate runtime-state subpaths (`axon/state/` — 8 tools write it). This is the only control that holds regardless of how the write is attempted (interpreter, computed path, symlink, fd). dev-mode ON lifts it.
3. **We will NOT** rely on a `sitecustomize` open()-shim as a security boundary (proven non-loading for the attack vector). It MAY ship only as best-effort defense-in-depth for the pytest/`-m` topology, with a reentrancy guard + captured-original-`open` + an `_is_axon_path` pre-filter, and MUST be documented as non-load-bearing.

**Honesty clause (ADR-003 lineage):** the argv gate is "harder," not "provably complete." The FS barrier is what makes R9 fail-closed. Any claim of "closed" for finding #1 is scoped to "literal+heuristic command-layer vectors blocked AND FS barrier active"; the residual undecidability of interpreter scripts is documented, not hidden.

## 5. Alternatives
| option | summary | why-rejected |
|--------|---------|--------------|
| Extend the command-shape denylist (status quo + interpreters) | enumerate more heads/redirects | undecidable for computed-path interpreter scripts; perpetual cat-and-mouse |
| Deny the raw Bash tool entirely; force all shell via `shell.py exec` | one chokepoint | breaks the agent's primary tool + 38 legit call sites; high friction |
| `sitecustomize.py` open()-shim as the boundary | wrap `builtins.open` | **inert** — system sitecustomize wins for bare `python3 -c`; doesn't load for `python3 tools/X.py` from non-root cwd |
| **argv-recursion gate + OS FS barrier** (chosen) | precise layer + decidable floor | more moving parts, but the FS barrier is the only complete fail-closed control |

## 6. Consequences
**Positive**: every council PoC blocked; the fail-closed floor (FS barrier) is complete and decidable; honest scope ends the "fingerprint = closed" overclaim.
**Negative / costs**: FS barrier needs careful boot/dev-mode-toggle wiring + an `axon/state/` allowlist or runtime tools silently fail; argv recursion adds parser surface (must fail-closed on error). Cross-platform immutable-attr support varies (mode bits as the portable floor).
**Follow-up actions** (Wave G):
- G1a — argv-recursion gate + redirect regex + fail-closed-on-parse-error; negative suite incl. computed-path/env/base64/`$()`/symlink/fd cases (block-or-document each).
- G1c — FS write-barrier on `axon/` gated by dev-mode, with `axon/state/` allowlisted; boot + toggle re-assert; test: interpreter write to `axon/` denied by the OS with dev-mode OFF.
- G1b — (optional) honest defense-in-depth shim, non-load-bearing.

## 7. Related
- ADR-001 (`# emits:` SSOT), ADR-003 (teeth reality — to be revised by G3)
- arch-audit findings #1/#4/#11; council verdict 2026-06-19; plan-auditors GO-WITH-CHANGES

---
## Update 2026-06-19 — G1c deferred (owner decision)
G1a (argv-recursion gate + redirect fix + fail-closed-on-parse-error) SHIPPED and blocks every literal
interpreter/redirect/nested-shell vector. G1c (the OS write-barrier — the fail-closed FLOOR for the
computed-path residual) is DEFERRED to its own reviewed iteration per owner, given its blast radius
(physically read-only kernel). ACCEPTED RESIDUAL until G1c lands: a runtime-computed axon/ path written
by an interpreter with dev-mode OFF is not statically catchable by the argv gate. Mitigations active now:
the PreToolUse hook + G1a literal-vector blocking + dev-mode being OFF-by-default-safe. Status of this ADR
remains `accepted`; G1c is the open follow-up action.
