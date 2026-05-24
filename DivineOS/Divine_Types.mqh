#ifndef __ETHERIC_DIVINE_TYPES_MQH__
#define __ETHERIC_DIVINE_TYPES_MQH__

enum DivineAccountMode
  {
   MICRO_SURVIVAL_MODE = 0,
   SURVIVAL_MODE = 1,
   CHIMP_MODE = 2
  };

enum DivineRuntimeState
  {
   STATE_BOOT = 0,
   STATE_READY = 1,
   STATE_SCANNING = 2,
   STATE_SIGNAL_READY = 3,
   STATE_EXECUTING = 4,
   STATE_RELAY_INIT = 5,
   STATE_RELAY_RUNNING = 6,
   STATE_RELAY_STOPPED = 7,
   STATE_RELAY_SHUTTING_DOWN = 8,
   STATE_EMERGENCY_STOP = 9,
   STATE_LOCKED = 10
  };

enum DivineRelayLifecycle
  {
   RELAY_INIT = 0,
   RELAY_RUNNING = 1,
   RELAY_STOPPED = 2,
   RELAY_SHUTTING_DOWN = 3
  };

enum DivineDirection
  {
   DIR_NONE = 0,
   DIR_BUY = 1,
   DIR_SELL = -1
  };

struct DivineDecision
  {
   long              sequence_id;
   string            symbol;
   DivineDirection  direction;
   int               score;
   string            reason_code;
   bool              allowed;
  };

#endif
