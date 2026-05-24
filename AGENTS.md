# Etheric World Agent Notes

## Phase 1 Scope

Work only inside the Survival Layer and Chimp Layer unless a later phase explicitly expands scope.

Do not add Oracle behavior, Ghost Trading, Redis, Python services, or AI behavior during Phase 1.

## DivineOS Runtime Rules

- Illegal state transitions must force `STATE_LOCKED`.
- Illegal state transitions must emit `LOCK_STATE_INVALID_TRANSITION`.
- Runtime state changes must use `CDivineState::Transition`.
- Relay execution must pass through state, risk, governance, and logging.
- Emergency stop must transition to `STATE_EMERGENCY_STOP`, call `EXEC_FlattenAll`, log relay shutdown, and then lock.

## Important Paths

- DivineOS modules: `DivineOS/`
- Architecture docs: `docs/`
- Integrity report: `docs/ARCHITECTURE_INTEGRITY_REPORT.md`

