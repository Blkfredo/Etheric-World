# Phase 1C Runtime Validation

Phase 1C validates that DivineOS behaves safely in MT5 Strategy Tester while `MICRO_SURVIVAL_MODE` is active.

This phase does not add strategy logic. It validates deterministic runtime safety, logging, state control, and relay guard behavior.

## Validation Checklist

### EA Initialization

- Attach `DivineOS.mq5` in MT5 Strategy Tester.
- Confirm the EA initializes without errors.
- Confirm terminal output prints the current DivineOS state and mode.
- Confirm expected initial state is `STATE_READY`.
- Confirm expected micro mode is `MICRO_SURVIVAL_MODE` when balance is below `$100`.

### State Transitions

- Confirm `STATE_BOOT -> STATE_READY` on initialization.
- Confirm tick scan path uses `STATE_READY -> STATE_SCANNING -> STATE_READY` when no signal exists.
- Confirm all state changes are written to `state_log.csv`.
- Confirm sequence IDs increase monotonically.

### MICRO_SURVIVAL_MODE Activation Under $100

- Run Strategy Tester with initial deposit below `$100`.
- Confirm output prints `MICRO_SURVIVAL_MODE active`.
- Confirm `Divine_Risk.mqh` uses the broker minimum lot.
- Confirm micro spread limit applies before execution approval.
- Confirm micro margin-buffer checks apply before execution or relay approval.

### Risk Lock Behavior

- Raise spread or use a symbol/session where spread exceeds `DivineMicroMaxSpreadPoints`.
- Confirm trade approval is blocked with `SPREAD_TOO_HIGH`.
- Confirm margin failures are blocked with `MARGIN_CALC_FAILED`, `MARGIN_TOO_LOW`, or `MICRO_MARGIN_BUFFER_REQUIRED`.
- Confirm risk blocks are logged through `Divine_Logger.mqh`.

### Relay Start/Stop Behavior

- Trigger relay review only through `CDivineExecution::ReviewRelay`.
- Confirm relay logs `INIT` before approval.
- Confirm relay cannot enter `RUNNING` without passing `STATE`, `RISK`, `GOV`, and `LOG`.
- Confirm `StopRelay` logs `SHUTTING_DOWN` and `STOPPED`.
- Confirm relay status changes are printed only when relay state changes.

### Emergency Stop Behavior

- Trigger `CDivineExecution::EmergencyStop` from a controlled test harness or manual validation hook.
- Confirm it logs `EMERGENCY_STOP`.
- Confirm it transitions to `STATE_EMERGENCY_STOP`.
- Confirm it calls `EXEC_FlattenAll`.
- Confirm forced relay shutdown logs `SHUTTING_DOWN` and `STOPPED`.
- Confirm final state becomes `STATE_LOCKED`.

### state_log.csv Generation

- Confirm `state_log.csv` is created in the tester files location.
- Confirm header is present.
- Confirm each row contains `sequence_id,timestamp,system,from_state,to_state,reason_code,result`.
- Confirm illegal transitions write `LOCK_STATE_INVALID_TRANSITION`.

### trade_log.csv Generation

- Confirm `trade_log.csv` is created when execution, dry-run order readiness, risk block, or flatten events occur.
- Confirm header is present.
- Confirm each row contains `sequence_id,timestamp,system,mode,symbol,action,lots,reason_code,result`.
- Confirm ignored build artifacts are not required for validation.

### error_log.csv Generation

- Confirm `error_log.csv` is created when errors occur.
- Confirm illegal transitions write the invalid transition detail.
- Confirm emergency stop writes `EMERGENCY_STOP`.
- Confirm flatten failures write `FLATTEN_CLOSE_FAILED`.

### Illegal Transition Protection

- Force or simulate an unapproved transition in a controlled test copy only.
- Confirm the state machine forces `STATE_LOCKED`.
- Confirm `LOCK_STATE_INVALID_TRANSITION` is emitted.
- Confirm the reason is printed once when the lock occurs.
- Confirm no normal execution or relay approval continues after lock.

### Manual Unlock Flow

- Manual unlock is not automatic in Phase 1C.
- If `STATE_LOCKED` occurs, stop the test.
- Review `state_log.csv` and `error_log.csv`.
- Fix the triggering configuration or code path.
- Restart the Strategy Tester run from a clean initial state.
- Do not bypass the lock inside the running EA.

### Strategy Tester Workflow

1. Open MetaTrader 5.
2. Open Strategy Tester.
3. Select Expert Advisor: `DivineOS`.
4. Select a safe test symbol such as `EURUSD`.
5. Select a recent date range with enough ticks to initialize and process ticks.
6. Set initial deposit below `$100`, preferably `$12`.
7. Use visual mode only if inspecting logs manually.
8. Run the test.
9. Open the Strategy Tester journal and confirm init, micro mode, state, relay, lock, and emergency messages only appear at lifecycle changes.
10. Open tester files and inspect `state_log.csv`, `trade_log.csv`, and `error_log.csv`.
11. Confirm no advanced trading behavior is introduced.
12. Save the validation result in project notes before moving to the next phase.

## Pass Criteria

- MetaEditor compile returns `0 errors, 0 warnings`.
- Strategy Tester initializes DivineOS cleanly.
- `MICRO_SURVIVAL_MODE` activates under `$100`.
- No relay path bypasses state, risk, governance, or logging.
- Illegal transitions lock the system.
- Logs are generated with deterministic sequence IDs.
- No Oracle, Ghost Trading, AI, Redis, Python, external services, or advanced strategy logic are present.

