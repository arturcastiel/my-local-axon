# F-017 — `code-dev new` fires 4 sequential QUERY prompts with no defaults

**personas**: P1, P2 · **workflow**: W-02 · **severity**: S3
**date**: 2026-05-16 · **status**: open

## Reproduction

Read [code-dev-new.md L26-L34](../../../../workspace/programs/code-dev-new.md#L26):

```
slug      ← QUERY(user): "Project slug ..."
name      ← QUERY(user): "Project display name"
codebase  ← QUERY(user): "Absolute path to codebase"
first-phase ← QUERY(user): "Name of first phase (e.g. 1-design, 1-resilience)"
```

P2 abandons here. P1 completes but trips on "slug" terminology.

## Expected

- Default `first-phase` to `1-design` if user presses Enter
- Infer `slug` from codebase dirname when provided first
- Show example next to "slug": `(e.g. my-cool-app)`

## Proposed edit

[code-dev-new.md L26-L34](../../../../workspace/programs/code-dev-new.md#L26):

```diff
- slug ← QUERY(user): "Project slug (a-z 0-9 -, no dots)"
+ slug ← QUERY(user): "Project slug (e.g. my-cool-app; a-z 0-9 -, no dots)"
...
- first-phase ← QUERY(user): "Name of first phase (e.g. 1-design, 1-resilience)"
+ first-phase ← QUERY(user, default="1-design"): "First phase name [1-design]"
```

## Rationale

Two-line edit, removes friction for novice users.
