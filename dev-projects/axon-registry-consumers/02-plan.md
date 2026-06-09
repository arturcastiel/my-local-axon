# Phase 2 — PR plan · axon-registry-consumers

> Each PR ships tests-or-equivalent + must pass the crucible gate; branch-first; merge by MR number.

- **PR-1** · migrate the genuine REGISTRY consumers to `_axon_registry`
  - per-file: swap raw load → accessor; preserve public names + path-params; leave validators/boot raw
  - one batch, gate once; smoke-verify each migrated module imports
- **PR-2** · close the lock's scope hole + tighten the allowlist
  - extend tests/test_registry_single_accessor.py to also scan tools/rules/
  - shrink ALLOWLIST to only the intentional-raw set (validators + boot); migrated files drop off
