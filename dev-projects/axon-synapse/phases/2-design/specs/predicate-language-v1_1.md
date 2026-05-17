# Predicate Language v1.1

> glossary: AXON-GLOSSARY v2
> closes: FL-01 (precedence), FL-02 (null), FL-03 (types)
> supersedes: goal-schema-v1 § Predicate language (which is removed)

## Purpose

Define a formal grammar with explicit precedence, null semantics, and a
strict-but-pragmatic type system. The predicate language is the shared
substrate for: `precondition`, `post-state`, `acceptance-criterion`,
`rejection-criterion`, synapse `condition`, workflow `triggers.when`.

## Formal grammar (precedence-explicit)

```
predicate   := implication
implication := disjunction ( '->' disjunction )*                    # right-assoc
disjunction := conjunction ( 'OR' conjunction )*                    # left-assoc
conjunction := negation ( 'AND' negation )*                         # left-assoc
negation    := 'NOT' negation
             | comparison
comparison  := value ( cmpop value )?
cmpop       := '==' | '!=' | '<' | '<=' | '>' | '>=' | 'matches' | 'in'
value       := call | ref | literal | '(' predicate ')'

call        := IDENT ( '.' IDENT )* '(' args? ')'
args        := value ( ',' value )*

ref         := scope '.' DOTTED
scope       := 'W' | 'L' | 'E' | 'state' | 'project' | 'phase'
             | 'workflow' | 'pr' | 'neuron'
DOTTED      := IDENT ( '.' IDENT )*

literal     := STRING | INTEGER | FLOAT | BOOL | NULL | LIST
STRING      := '"' ('\\"' | [^"])* '"' | "'" ('\\\'' | [^'])* "'"
INTEGER     := -? [0-9]+
FLOAT       := -? [0-9]+ '.' [0-9]+
BOOL        := 'true' | 'false'
NULL        := 'null'
LIST        := '[' (value (',' value)*)? ']'

IDENT       := [a-zA-Z_][a-zA-Z0-9_-]*
```

### Precedence (lowest to highest binding)

```
1. -> (implication)              right-associative
2. OR                            left-associative
3. AND                           left-associative
4. NOT                           prefix, right-associative
5. comparison (==, !=, <, etc.)  non-associative (chain forbidden)
6. function calls + refs + literals + parens
```

Explicit: `A AND B OR C` parses as `(A AND B) OR C` — AND binds tighter
than OR. Parens override.

Comparison chains (`A < B < C`) are **forbidden** — must be written
`A < B AND B < C`. Parser raises `chain_comparison` error.

## Type system

Six base types: `int`, `float`, `string`, `bool`, `null`, `list`.
Compound: `dict` (read-only via dotted refs).

### Coercion rules (strict)

| Source       | Target  | Allowed | Rule |
|--------------|---------|---------|------|
| int          | float   | implicit | widening |
| float        | int     | explicit only | `int(x)` |
| int/float    | string  | explicit only | `str(x)` |
| string       | int/float | explicit only | `int(x)` / `float(x)` (fails if invalid) |
| bool         | int     | implicit | `true=1`, `false=0` |
| anything     | bool    | implicit (truthy) | `null=false`, `0=false`, `0.0=false`, `""=false`, `[]=false`, else `true` |
| string       | regex   | implicit in `matches` | RHS of `matches` is regex literal |

Comparisons across non-coercible types raise `type_mismatch`. Example:
`file.size("x") > "100"` → mismatch (int vs string; user must write
`file.size("x") > int("100")` or fix the literal).

### Null semantics (three-valued logic OFF by default)

`null == null` → `true`.
`null == <anything-non-null>` → `false`.
`null != <anything>` → `true` if other side non-null, `false` otherwise.

Arithmetic / ordering on null → `null_in_comparison` error.

`null AND x` → `null` (propagating).
`null OR x` → `x` if `x` truthy, else `null`.
`NOT null` → `null`.

**In predicate evaluation contexts (acceptance, precondition, etc.) null
is treated as FALSE** — so `file.exists(W.maybe-key)` evaluates safely
even when `W.maybe-key` is null. This is the "safe-eval" mode (default).

`strict-null` mode (opt-in via `# evaluation-mode: strict`) raises on
any null appearing outside `== null` / `!= null` comparisons.

## Built-in functions (typed)

### Filesystem
- `file.exists(path: string) -> bool`
- `dir.exists(path: string) -> bool`
- `file.readable(path: string) -> bool`
- `file.writable(path: string) -> bool`
- `file.size(path: string) -> int` (bytes; `null` if absent)
- `file.mtime(path: string) -> int` (epoch sec; `null` if absent)
- `file.contains(path: string, needle: string) -> bool`

### Counts / queries
- `count(glob: string) -> int`
- `glob_first(glob: string) -> string | null`
- `glob_all(glob: string) -> list[string]`

### Scope refs (return any type; null if absent)
- `W.<key>` / `L.<key>` / `E.<key>` / `state.<dotted>` / etc.
  Each returns the stored value or `null`.

### Shadow / DAG
- `shadow.contains(file: string) -> bool`
- `shadow.coverage(scope: string) -> int` (percent 0–100; `null` if no
  source files in scope)
- `dag.consistent(level: string) -> bool`

### Test / audit (mutates lookup state)
- `tests.pass() -> bool` (last `run-tests` invocation; `null` if never run)
- `tests.fail() -> bool` (mirror; `null` if never run)
- `audit.open_findings() -> int`
- `audit.critical_issues() -> int`

### Pattern / string
- `<string> matches <regex-literal>` — RHS parsed as regex.
- `<string>.contains(<string>) -> bool`
- `<value> in <list> -> bool`

### Domain-specific (declared per domain manifest)
Each domain manifest may declare predicates that namespace by domain:
`code-dev.pr.has_spec(<n>)`, `library-dev.library.shadow_pct()`, etc.
The predicate evaluator dispatches to domain-registered Python callables.

### Type ops
- `int(x)` / `float(x)` / `str(x)` / `bool(x)` — explicit coercion.
- `len(list_or_string) -> int`

## Template interpolation

Inside `STRING` literals, `{scope.path}` is interpolated **at evaluation
time** against the current STATE snapshot.

```
file.exists('phases/{phase.name}/01-study.md')
```

Interpolation failures (missing key) → produce literal `null` in the
template position (safe-eval) OR raise (`strict-null`).

## Snapshot semantics (closes GAP-06)

Each predicate evaluation occurs against a **single state snapshot** taken
at the start of evaluation. State changes during evaluation do NOT affect
the same evaluation. A predicate that needs *fresh* state must be
re-evaluated.

Long-running neurons have two evaluation modes:
- **Entry-time post-state** (default): post-state predicate evaluates
  once, immediately after neuron returns.
- **Continuous post-state** (opt-in via `post-state-mode: continuous` on
  the neuron): post-state predicate re-evaluates every 5s during fire;
  fail → abort with `post_state_violated`.

## Implementation reference (Phase 3 PR-102)

Parser: PEG or recursive descent (Python). Reference grammar above.
Evaluator: AST walker with `safe-eval` default.
Snapshot: `tools/state_snapshot.py` returns frozen-dict view.
Errors: `parse_error`, `type_mismatch`, `null_in_comparison`,
`chain_comparison`, `undefined_function`, `domain_predicate_unregistered`.

## Test corpus (Phase 3 PR-102 ships ≥ 50 fixtures)

```
# Precedence
"A AND B OR C"           parse = (A AND B) OR C
"A OR B AND C"           parse = A OR (B AND C)
"NOT A AND B"            parse = (NOT A) AND B
"A -> B OR C"            parse = A -> (B OR C)

# Null
"W.missing == 'foo'"     safe-eval → false
"W.missing == null"      safe-eval → true
"NOT W.missing"          safe-eval → true   (null is falsy)

# Types
"file.size('x') > 100"   ok (int comparison)
"file.size('x') > '100'" type_mismatch
"len(W.items) >= 3"      ok if W.items is list

# Templates
"file.exists('p/{phase.name}/01.md')"
                         interpolates phase.name at eval time

# Domain
"code-dev.pr.has_spec(7)"
                         dispatched to code-dev domain predicate
```

## Migration from v1

v1 predicates auto-parse under v1.1 grammar (v1 was implicitly
left-to-right; v1.1 enforces AND > OR precedence). Where v1 prose was
ambiguous, v1.1 wins. No bumped goals fields needed.

## Version + change rule

**Version: v1.1 (2026-05-17).** Bumps require ADR + test corpus update.
