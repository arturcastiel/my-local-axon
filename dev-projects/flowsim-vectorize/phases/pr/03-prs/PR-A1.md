# PR-A1 — flowsim_init.m + flowsim_deinit.m at repo root

## Intent
Path initializer + symmetric cleanup so `flowsim_init` at MATLAB startup adds
every module folder (existing OOP layer + legacy code + future `+fs/` tree)
with correct precedence.

## Files added (in FlowSim tree)
- `flowsim_init.m`     (path setup — verbose/legacy/reset flags)
- `flowsim_deinit.m`   (symmetric rmpath)

## Files unchanged
Existing `base/startup.m` (auto-invoked by MATLAB) still runs — will be
retrofitted to call `flowsim_init` in PR-F4.

## Tests
- `tests/smoke/smoke_env.m` (already exists, still 8/8 green)

## Correctness gate
- smoke_env passes (verified via mrun)

## Legacy disposition
- None affected — additive only.
