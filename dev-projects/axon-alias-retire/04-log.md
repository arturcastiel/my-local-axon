# Implementation Log — axon-alias-retire (F30)

> The riskiest project (conf-6). The study's order: harness FIRST, then repoint, then deprecate-warn,
> then delete NEXT release. Execution found the deprecation is already done and built the harness; the
> two breaking steps (repoint the LLM-interpreted core harness, delete) are HELD with reasons.

## Grounding (measured the live state before touching anything)
- **18 status:ALIAS programs**, all forwarding (EXEC) to an existing canonical program. None broken.
- **code-dev.md routes through 17 of them** (the three-hop). 1 dynamic target (`code-dev-phase-{var}`).
- **All 18 already emit a deprecation LOG(WARN)** — the study assumed they might not; they do (formats
  are inconsistent, but every alias warns). So "loud-deprecate" (planned PR-3) is effectively DONE.
- **1 metadata bug:** `code-dev-self-review` declared `canonical: code-dev-review-self` but EXECs
  `code-dev-review` (its desc + next-suggests agree on code-dev-review). It also has the only pre-EXEC
  side effect (`STORE(W:code-dev-review-sub,"self")`) — so it is NOT a pure forwarder.

## Merged — 2026-05-30
| PR | MR | What |
|----|----|------|
| PR-1 (harness) | !95 | `tests/test_code_dev_dispatch.py` — the gating safety net: (1) every static EXEC target in code-dev.md resolves; (2) every alias forwards to a real program; (3) every alias warns on use; (4) every alias's `canonical:` header matches its actual EXEC target; (5) the 18-alias inventory is locked. Fixed code-dev-self-review's stale canonical header. Gate 22/0. |

**main 4756df4.**

## HELD — repoint + delete (deliberate, documented)
- **PR-2 (repoint code-dev.md alias→canonical):** HELD. code-dev.md is THE dogfood harness and is
  LLM-interpreted; **no test executes it through an LLM**, so a routing regression is invisible to the
  gate (the new harness verifies *resolution*, not *interpretation*). 17/18 are pure forwarders (would
  be safe), but `code-dev-self-review` has a pre-EXEC STORE that a naive repoint would drop. The
  three-hop works today; repointing is an optimization, not a fix → not worth breaking "nothing breaks"
  without an execution-test or human validation.
- **PR-4 (delete the 18 aliases):** HELD — explicitly next-release per the study's deprecation cycle,
  and only after the repoint lands + a deprecation window passes.

## Net
The harness is the durable win: alias retirement is now *verifiable for resolution*, and the inventory
+ warn + canonical-consistency invariants are locked. The actual retirement (repoint → window → delete)
is a human-validated next-release cycle, as F30 designed.

## UPDATE 2026-06-01 — full retirement completed (owner dropped retrocompat)
| PR | MR | What |
|----|----|------|
| step A | !99 | repoint code-dev.md's 17 routes alias→canonical (self-review/rewind keep their STORE) |
| steps B+C | !100 | swept alias→canonical across 40 programs (EXEC + next-suggests), removed 18 programs-registry entries, **deleted all 18 alias files**; repointed 3 test expectations + made tour-lint resolve verbs via the router (it had been linting the alias stub). Harness now asserts 0 aliases remain. |

**0 ALIAS programs remain.** F30 is fully closed (not just the harness). The held risk was the
LLM-interpreted harness with no exec test — mitigated by letting the gate's validators (dag-consistency
+ program EXEC resolution) define the required sweep, and a code-dev smoke. main 31994cd.
