#ifndef __ETHERIC_DIVINE_RISK_MQH__
#define __ETHERIC_DIVINE_RISK_MQH__

#include "Divine_Config.mqh"
#include "Divine_Types.mqh"

class CDivineRisk
  {
public:
   DivineAccountMode AccountMode(void)
     {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      if(balance <= 0.0)
         balance = DIVINE_DEFAULT_BALANCE_ASSUMPTION;
      return (balance < DIVINE_MICRO_BALANCE_LIMIT) ? MICRO_SURVIVAL_MODE : SURVIVAL_MODE;
     }

   double MinimumLot(const string symbol)
     {
      double minLot = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
      return (minLot > 0.0) ? minLot : 0.01;
     }

   bool AllowsTrade(const string symbol,string &reason_code)
     {
      DivineAccountMode mode = AccountMode();
      if(mode == MICRO_SURVIVAL_MODE)
         reason_code = "MICRO_BALANCE_ACTIVE";

      int spread = (int)SymbolInfoInteger(symbol,SYMBOL_SPREAD);
      if(spread > DivineMaxSpreadPoints)
        {
         reason_code = "SPREAD_TOO_HIGH";
         return false;
        }

      double minLot = MinimumLot(symbol);
      if(minLot <= 0.0)
        {
         reason_code = "LOT_TOO_SMALL";
         return false;
        }

      reason_code = (mode == MICRO_SURVIVAL_MODE) ? "MICRO_BALANCE_ACTIVE" : "EXECUTION_ALLOWED";
      return true;
     }
  };

#endif
