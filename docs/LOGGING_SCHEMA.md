# Logging Schema

Phase 1 logs use CSV-friendly fields.

## Decision Log

```text
timestamp,system,mode,symbol,state,reason_code,score,balance,equity,risk_percent,allowed
```

## Execution Log

```text
timestamp,system,mode,symbol,action,lots,price,stop_loss,take_profit,reason_code,result
```

## Relay Log

```text
timestamp,system,mode,relay_type,symbol,reason_code,allowed,result
```

