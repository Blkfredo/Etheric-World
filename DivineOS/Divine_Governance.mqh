#ifndef __ETHERIC_DIVINE_GOVERNANCE_MQH__
#define __ETHERIC_DIVINE_GOVERNANCE_MQH__

#include "Divine_Types.mqh"

class CDivineGovernance
  {
public:
   bool AllowsDecision(const DivineDecision &decision,const DivineRuntimeState state,string &reason_code)
     {
      if(state == STATE_LOCKED || state == STATE_EMERGENCY_STOP)
        {
         reason_code = "GOV_STATE_BLOCKED";
         return false;
        }

      if(!decision.allowed)
        {
         reason_code = decision.reason_code;
         return false;
        }

      reason_code = "EXECUTION_ALLOWED";
      return true;
     }
  };

#endif
