---
tags: [code, file]
path: tests/test_dual_agent_eval.py
---

# tests/test_dual_agent_eval.py

> 65 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `A mock backend that returns queued replies in order, then a default.`
- `Correct per-operator solver when AXON-scaffolded; flails otherwise. Picks heat v`
- `Dual-agent eval harness (axon-million benchmark pillar). The model backend is in`
- `Mock model: behaves coherently when the AXON system prompt is present,     drift`
- `Mock: emits a CORRECT seed-0 solver only when AXON-scaffolded; the bare arm flai`
- `_deltas()`
- `_mms_axon_aware_backend()`
- `_mms_mixed_axon_backend()`
- `axon_aware_backend()`
- `scripted()`
- `test_aggregate_exposes_ci_field()`
- `test_aggregate_flat_does_not_support_h1()`
- `test_aggregate_small_majority_is_inconclusive_not_overclaimed()`
- `test_aggregate_supports_h1_only_when_ci_lower_clears_half()`
- `test_anthropic_backend_pins_temperature()`
- `test_axon_mcp_config_launches_the_server()`
- `test_claude_cli_backend_builds_subscription_command()`
- `test_claude_cli_backend_raises_on_cli_failure()`
- `test_claude_cli_render_is_a_transcript_without_system()`
- `test_cli_axon_arm_wires_mcp_tools()`
- `test_cmd_preflight_runs_without_backend()`
- `test_cmd_prereg_writes_locked_record()`
- `test_cmd_run_mms_accepts_goals_across_operators()`
- `test_cmd_run_mms_demo_backend_runs_end_to_end()`
- `test_cmd_run_mms_status_without_backend()`
- `test_conversation_respects_max_turns()`
- `test_conversation_stops_on_goal_met()`
- `test_delta_axon_wins_when_only_axon_meets_goal()`
- `test_dual_agent_eval.py`
- `test_end_to_end_two_arms_with_mock()`
- `test_extract_solver_code_none_when_absent()`
- `test_extract_solver_code_prefers_most_recent_solver()`
- `test_extract_solver_code_pulls_python_block()`
- `test_extract_solver_code_unfenced_fallback()`
- `test_grade_mms_arm_fails_with_zero_solver()`
- `test_grade_mms_arm_no_code_is_clean_fail()`
- `test_grade_mms_arm_passes_with_reference_solver()`
- `test_make_backend_claude_cli_returns_subscription_backend()`
- `test_make_backend_unknown_raises()`
- `test_make_operator_prepends_axon_system()`
- `test_mms_delta_tie_counts_as_non_win()`
- `test_preflight_assumed_winrate_needs_more_goals_than_best_case()`
- `test_preflight_best_case_threshold_is_four()`
- `test_preflight_cost_scales_and_axon_arm_costs_more()`
- `test_preflight_small_n_cannot_be_conclusive()`
- `test_prereg_embeds_honest_power_projection()`
- `test_prereg_fingerprint_deterministic_and_code_sensitive()`
- `test_prereg_fingerprints_the_bl_grader()`
- `test_prereg_record_locks_bar_and_pins_code()`
- `test_render_goal_handles_bl_spec_shape()`
- `test_render_mms_goal_built_from_spec_and_leakage_safe()`
- `test_render_mms_goal_includes_coeffs_for_advdiff()`
- `test_run_fixtures_shows_axon_advantage()`
- `test_run_mms_fixtures_accepts_axon_backend()`
- `test_run_mms_fixtures_axon_arm_wins_objectively()`
- `test_run_mms_fixtures_mixed_operators_axon_wins_on_both()`
- `test_run_mms_fixtures_routes_bl_analytical_goals()`
- `test_run_resolved_arm_routes_axon_backend_to_axon_arm_only()`
- `test_run_status_path_without_backend()`
- `test_run_unconfigured_backend_clean_error()`
- `test_score_detects_goal_and_coverage()`
- `test_score_partial_coverage_no_goal()`
- `test_seed_fixtures_load_and_are_long_horizon()`
- `test_wilson_interval_tightens_with_n()`
- `test_write_report()`

## Depends on
- (none)
