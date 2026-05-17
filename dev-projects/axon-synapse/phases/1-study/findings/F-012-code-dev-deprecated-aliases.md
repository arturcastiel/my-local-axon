# F-012: Three code-dev entry-point verbs are deprecated aliases or orphan stubs

**Severity:** high
**Track:** T-A
**Date:** 2026-05-17
**Linked demands:** D-25 (preserve code-dev), D-1 (audit)
**Linked decisions:** D-014

## Evidence

Walking the canonical code-dev hierarchy from F-006 reveals that three of its
headline verbs are either deprecated aliases or unimplemented stubs:

| User-typed verb | Real program | Status |
|-----------------|--------------|--------|
| `code-dev audit` | `code-dev-safety-audit.md` | **DEPRECATED ALIAS.** `code-dev-audit.md` is a stub that LOG(WARN) + EXEC(code-dev-safety-audit). Marker: "removed next release." |
| `code-dev pr` | `code-dev-pr-create.md` | **DEPRECATED ALIAS.** Same pattern. |
| `code-dev finalize` | (no real implementation) | **ORPHAN STUB.** Logs warning + returns. PR-119 follow-up flagged in `axon-cleanup` project. |

Verbatim from `code-dev-audit.md`:
```
# PROGRAM: code-dev-safety-audit-ALIAS
# desc:    alias stub — superseded by code-dev-safety-audit; removed next release.
LOG(WARN, "alias-deprecated: use code-dev-safety-audit")
EXEC(code-dev-safety-audit $@)
DONE
```

Verbatim from `code-dev-finalize.md`:
```
# PROGRAM: code-dev-finalize
# desc:    orphan-stub — referenced by other code-dev programs but never implemented (logged for PR-119 follow-up).
LOG(WARN, "code-dev-finalize called — stub only. See axon-cleanup PR-119.")
```

## Why this matters

1. **User documentation references the alias names.** Menu and tips reference
   `code-dev audit`, `code-dev pr`, `code-dev finalize` as the canonical
   chain (per F-006).
2. **F-006's chain assumption is partially fictional.** The chain `study →
   plan → pr → log → audit → finalize → shadow` resolves through aliases for
   3 of 7 steps. The "audit → finalize" step in particular: audit is an alias
   (still works), finalize is a stub (does nothing).
3. **The synapse contract cannot encode behavior that isn't implemented.**
   `code-dev-finalize`'s post-state can't be defined because the program
   doesn't act.
4. **Backwards compatibility (D-014/D-025) requires preserving alias names.**
   They cannot be removed without breaking documented usage. But the
   `removed next release` marker implies a removal plan that never executed.

## Risk

If this finding is not addressed before synapse contract migration:

- The orchestrator's `next-conditional` for `code-dev-safety-audit` would
  point to `code-dev-finalize` (per the documented chain), but firing the
  stub does nothing — user sits at a dead end.
- `code-dev-audit` and `code-dev-pr` aliases would have synapse contracts
  that duplicate (with subtle drift) those of the real programs.
- The "removed next release" marker is a latent breaking change waiting to
  bite the workflow OS rollout.

## Implication for Phase 2 / Phase 3

- **Phase 2 design Q.** Per D-025, alias names stay invocable. Decide:
  (a) Keep aliases permanently with `status: alias-canonical: <real-name>`,
  (b) deprecate-but-warn with sunset date.
- **Phase 2 design Q.** Resolve `code-dev-finalize` — either implement it
  (define what "finalize a project" means: archive, mark status=done, write
  retro) or remove it from documented chains.
- **Phase 3 PR seed.** `code-dev-finalize-impl` — implement the orphan based
  on PR-119 spec in `axon-cleanup`.
- **Phase 3 PR seed.** `code-dev-aliases-formalize` — alias programs get
  `# alias-of:` header; synapse contract resolves through to canonical.

## Audit-trail link

- D-1 (full audit) — this finding belongs in the audit deliverable.
- D-25 (preserve hierarchy) — directly affected; the deprecation removal
  noted in the alias stubs is a violation of D-25 if executed.
- PR-119 in `axon-cleanup` project — the unfinished follow-up.
