# PR Spec Template (I-04)

> Every PR-NNN.md file in `03-prs/` MUST include the sections below.
> Validation: `code-dev-pr-create` and `axon-audit` enforce.
> Glossary: AXON-GLOSSARY v2

```markdown
# PR-NNN — <one-line title>

**Depends-on**: PR-XXX, PR-YYY  ·  **Blocks**: PR-ZZZ
**Wave**: W<n>  ·  **Reversibility**: one-way | reversible | partial
**Domain**: code-dev | library-dev | meta | ...
**dev-mode required**: yes | no  (if yes — gated per kernel rule 9)
**Status**: pending | active | review | merged | reverted

## Goal

Statement:       <one-sentence goal per goal-schema v1.1>
Acceptance:      <predicate that evaluates true when PR is done>
Rejection:       <predicate that signals abort>
Linked-finding:  F-NNN (the Phase-1 finding this PR addresses)
Linked-demand:   D-NN  (the demand this PR advances)

## Blast radius (I-05)

Affected paths:
  - <glob 1>
  - <glob 2>
Max-rows-changed:  <int estimate>
Touches kernel:    yes | no  (if yes — must be dev-mode-gated)
Touches shared:    yes | no  (if yes — coordinate with downstream domains)
Touches existing tests:  yes | no  (if yes — D-019 compliance section required)

## Files changed

| Path | Kind | Note |
|------|------|------|
| <path> | new / mod / del | <reason> |

## Implementation outline

1. <step>
2. <step>
3. <step>

## Tests

- Existing test suite: must remain green (D-019)
- New tests: <listed>
- Test command:  <how to run; HUMAN-only invocation, not AXON>

## Rollback (I-04 — MANDATORY section)

Revert command:    <git revert SHA  OR  code-dev-undo --pr NNN>
Check command:     <how to verify revert succeeded>
Partial-failure decision tree:
  - If mid-PR file write fails → <action>
  - If post-merge test breaks → <action>
  - If downstream PR depended on this PR → <action>

## Audit-trail

- Created by:    <author / wave>
- Reviewer(s):   <handles>
- Synapse-contract updated: yes | no
- DAG mutation:  add-node | add-edge | merge | split | fold-in | (none)
- Shadow obligation: yes | no  (if yes, shadow file expected on finalize)

## Notes
<free-form discussion>
```

---

## Field semantics

### Reversibility (I-06)

- `one-way` — cannot be auto-undone (kernel write, DB schema migration,
  external API call). Requires dev-mode + user-confirm + audit row.
- `reversible` — `undo` tool can roll back the L: changes + `git revert`
  the file changes.
- `partial` — some effects reversible, some not. Document the
  non-reversible subset under `Rollback`.

### Blast radius (I-05)

Audit surfaces PRs with high blast radius (touches > 50 files OR touches
kernel OR touches > 3 domains). High-blast-radius PRs require extra
review pass.

## Validation

`code-dev-pr-create` (post-PR-117 implementation) validates every PR
spec against this template before allowing finalize:
- All required sections present
- `Reversibility` is one of the three allowed values
- `Rollback` is non-empty
- If `Touches kernel == yes` then `dev-mode required` must be `yes`

`axon-audit` reports template-incomplete PRs as findings.
