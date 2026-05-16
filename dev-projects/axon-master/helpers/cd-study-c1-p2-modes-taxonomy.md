# CD·STUDY·C1·P2 — study modes taxonomy

> Catalog of *kinds* of codebase study a developer might need. Each becomes a candidate `--mode` on `code-dev knowledge study`.

## The 14 study modes (proposed)

| Mode               | One-line                                                | Output                          | Typical user                |
|--------------------|---------------------------------------------------------|---------------------------------|-----------------------------|
| `overview`         | Broad map of subsystems and files (today's default)     | `study/overview.md`             | New to repo                 |
| `subsystem`        | Deep dive into ONE folder                                | `study/<subsystem>.md`          | Working on one area         |
| `security`         | Auth, secrets, input handling, OWASP-top-10 surfaces    | `study/security.md`             | Pre-prod audit              |
| `performance`      | Hot paths, hot loops, big-O smell, IO patterns          | `study/performance.md`          | Perf regression chase       |
| `dependencies`     | Direct deps, transitive risk, version skew, licenses    | `study/dependencies.md`         | Supply-chain review         |
| `tests`            | Test coverage map, untested modules, slow tests          | `study/tests.md`                | Coverage push               |
| `api-surface`      | Public symbols, exported types, semver risk             | `study/api.md`                  | Library author              |
| `data-model`       | Schemas, migrations, invariants                         | `study/data-model.md`           | Backend work                |
| `dead-code`        | Unreached symbols, dead branches, stale features        | `study/dead-code.md`            | Cleanup                     |
| `naming`           | Identifier consistency, collisions, jargon              | `study/naming.md`               | Refactor                    |
| `observability`    | Logging, tracing, metrics coverage                      | `study/observability.md`        | SRE / ops                   |
| `error-handling`   | Exception/result patterns, retry, circuit-breakers      | `study/error-handling.md`       | Reliability work            |
| `dataflow`         | Source→sink trace for a value or input                  | `study/dataflow-<query>.md`     | Bug hunt                    |
| `history`          | Recent churn, hot files by commit count                 | `study/history.md`              | Owner mapping               |

## Mode interactions

- `overview` is a **prerequisite** for the rest (produces the subsystem map they refine).
- `subsystem` is **per-folder**; runs after overview to drill.
- `security`, `performance`, `dependencies`, `tests`, `dead-code` are **cross-cutting**; read overview + selected source.
- `api-surface`, `data-model`, `observability`, `error-handling` are **cross-cutting but narrower**.
- `dataflow` is **query-driven**: needs a starting symbol/file.
- `history` is **time-driven**: needs `git log` data (HUMAN provides).

## Output discipline (proposed for ALL modes)

```
my-axon/dev-projects/<slug>/study/
├── overview.md
├── subsystems/
│   ├── auth.md
│   ├── api.md
│   └── ...
├── security.md
├── performance.md
├── ...
├── _index.md      # auto-generated; links every study artifact + timestamps
└── _trace/        # debug traces, optional
    └── overview-2026-05-16T10:00.jsonl
```

vs. today's monolithic `01-study.md`. **Same idea applied as `helpers/` already does for *meta* studies on AXON itself.**

## Cardinal rules (proposed)

1. Each mode writes its OWN file. No mode silently appends to another's file.
2. Each mode writes its own `_index.md` entry.
3. Each mode declares a **token budget** in its header (default 4k input, 4k output) and HALTS if exceeded.
4. Each mode is **idempotent**: same input + same mode = same output (modulo timestamps).
5. Each mode supports `--checkpoint` (resume after interruption) and `--diff` (compare to prior run).

## Token-budget per mode (initial estimates)

| Mode             | Input budget | Output budget |
|------------------|-------------:|--------------:|
| overview         | 8k           | 4k            |
| subsystem        | 4k per file (cap 20k) | 4k    |
| security         | 12k          | 4k            |
| performance      | 12k          | 4k            |
| dependencies     | 4k (manifest only) | 2k       |
| tests            | 8k           | 4k            |
| api-surface      | 8k           | 3k            |
| data-model       | 6k           | 3k            |
| dead-code        | 16k          | 4k            |
| naming           | 16k          | 4k            |
| observability    | 8k           | 3k            |
| error-handling   | 8k           | 3k            |
| dataflow         | variable     | 4k            |
| history          | 4k (git log) | 3k            |

Total full-codebase audit ≈ 100k input / 50k output. Each mode independently runnable so this never has to happen in one shot.

## Mode invocation (verb-centric, post-Round-3)

```
code-dev knowledge study                      # default = overview
code-dev knowledge study --mode=overview
code-dev knowledge study --mode=subsystem --target=src/auth
code-dev knowledge study --mode=security
code-dev knowledge study --mode=performance --target=src/hotpath
code-dev knowledge study --mode=dataflow --from "user.email" --to "stdout"
code-dev knowledge study --mode=dependencies
code-dev knowledge study --diff --since 30d   # what changed
code-dev knowledge study --suggest-next        # propose next mode based on state
```

## What modes do NOT do

- They do NOT run code (HUMAN runs tests, builds, profilers; code-dev reads outputs).
- They do NOT install dependencies.
- They do NOT call external networks.
- They do NOT modify source code.

→ next: industrial parallels in `cd-study-c1-p3-prior-art.md`.
