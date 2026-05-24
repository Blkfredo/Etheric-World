# State Machine

DivineOS Phase 1 uses simple deterministic states.

## States

- `MICRO_SURVIVAL_MODE` - default for balances under `$100`.
- `SURVIVAL_MODE` - defensive operation for small or stressed accounts.
- `CHIMP_SCAN` - basic market scan.
- `CHIMP_READY` - signal passed basic checks.
- `BLOCKED` - trade rejected by safety logic.
- `EXECUTING` - order request in progress.
- `RELAY_REVIEW` - relay trade check after a valid exit or continuation event.

## Default

At about `$12` balance, the default state is `MICRO_SURVIVAL_MODE`.

