# Relay Execution

Relay trading remains inside `Divine_Execution.mqh`.

Phase 1 does not make relay execution autonomous or AI-driven. Relay checks are deterministic and must pass Survival Layer controls before any order is sent.

## Relay Flow

1. A valid event requests a relay review.
2. Survival checks confirm account mode, margin, spread, and risk.
3. Chimp-level signal quality is checked.
4. `Divine_Execution.mqh` either blocks or sends the relay order.
5. The relay decision is logged with a reason code.

