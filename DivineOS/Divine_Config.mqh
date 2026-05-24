#ifndef __ETHERIC_DIVINE_CONFIG_MQH__
#define __ETHERIC_DIVINE_CONFIG_MQH__

#define DIVINE_SYSTEM_NAME "EthericWorld.DivineOS"
#define DIVINE_PHASE_NAME "Phase1_Survival_Chimp"
#define DIVINE_MICRO_BALANCE_LIMIT 100.0
#define DIVINE_DEFAULT_BALANCE_ASSUMPTION 12.0
#define DIVINE_MAGIC 24052026
#define DIVINE_RETRY_COUNT 2
#define DIVINE_STATE_LOG "state_log.csv"
#define DIVINE_TRADE_LOG "trade_log.csv"
#define DIVINE_ERROR_LOG "error_log.csv"
#define DIVINE_RELAY_LOG "relay_log.csv"

input double DivineMaxRiskPercent = 0.25;
input int    DivineMaxSpreadPoints = 35;
input double DivineMicroMaxRiskPercent = 0.10;
input int    DivineMicroMaxSpreadPoints = 20;
input double DivineMicroMinFreeMarginPercent = 70.0;
input bool   DivineRelayEnabled = true;

#endif
