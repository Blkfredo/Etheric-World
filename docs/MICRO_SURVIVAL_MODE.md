# Micro Survival Mode

`MICRO_SURVIVAL_MODE` is mandatory for accounts under `$100`.

The current account balance is about `$12`, so DivineOS defaults to this mode.

## Intent

Micro Survival Mode prioritizes survival over growth. It should reduce exposure, avoid unnecessary trades, and block any setup that cannot be sized safely.

## Rules

- Balance under `$100` activates micro mode.
- Use the smallest broker-valid lot size.
- Block trades when required margin is unsafe.
- Block trades when spread is excessive.
- Block trades when risk cannot be expressed safely at minimum lot.
- Keep relay execution subject to the same micro checks.

