# F-019 — `code-dev-study.md` `# modes:` block lacks budget enforcement note

**personas**: P3 · **workflow**: W-03 · **severity**: S2
**date**: 2026-05-16 · **status**: open · **related**: F-011

## Reproduction

[code-dev-study.md L8-L11](../../../../workspace/programs/code-dev-study.md#L8) shows:

```
# modes:
#   overview:    {input-cap:  8000, output-cap:  4000}
#   subsystem:   {input-cap: 16000, output-cap:  6000}
#   deep:        {input-cap: 32000, output-cap: 12000}
```

But still also declares blanket `# budget: input-cap 8000, output-cap 2000`. The
`deep` mode's `output-cap: 12000` is 6× the blanket.

## Expected

Either drop blanket caps when per-mode block is present (F-011), or document
that per-mode caps override blanket in the block header comment.

## Proposed edit

Add a single comment line above the `# modes:` block:

```
# modes: (when --mode is set, overrides the # budget: caps above)
```

## Rationale

Documents the override behavior without changing runtime.
