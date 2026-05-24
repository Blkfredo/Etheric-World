# Micro Survival Mode

`MICRO_SURVIVAL_MODE` is mandatory for accounts under `$100`.

The current account balance is about `$12`, so DivineOS defaults to this mode.

## Intent

Micro Survival Mode prioritizes survival over growth. It should reduce exposure, avoid unnecessary trades, and block any setup that cannot be sized safely.

## Rules

- Balance under `$100` activates micro mode.
- Use the smallest broker-valid lot size.
- Apply the micro spread limit before any execution or relay approval.
- Require a free-margin buffer after minimum-lot margin is reserved.
- Block trades when required margin is unsafe.
- Block trades when spread is excessive.
- Block trades when risk cannot be expressed safely at minimum lot.
- Keep relay execution subject to the same micro checks.

## Phase 1B Runtime Behavior

Phase 1B makes micro mode active in the runtime path:

- `CDivineRisk::AccountMode` detects balances below `$100`.
- `CDivineRisk::RecommendedLots` returns the broker minimum lot.
- `CDivineRisk::AllowsTrade` applies micro spread and margin-buffer gates.
- `CDivineExecution::Execute` uses the risk-approved minimum lot.
- `CDivineExecution::ReviewRelay` uses the same risk path as normal execution.

No advanced strategy logic is included.
