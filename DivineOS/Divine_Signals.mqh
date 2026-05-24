#ifndef __ETHERIC_DIVINE_SIGNALS_MQH__
#define __ETHERIC_DIVINE_SIGNALS_MQH__

#include "Divine_Types.mqh"

class CDivineSignals
  {
public:
   DivineDecision Scan(const string symbol)
     {
      DivineDecision d;
      d.sequence_id = 0;
      d.symbol = symbol;
      d.direction = DIR_NONE;
      d.score = 0;
      d.reason_code = "NO_SIGNAL";
      d.allowed = false;
      return d;
     }
  };

#endif
