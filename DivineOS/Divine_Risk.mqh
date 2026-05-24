#ifndef __ETHERIC_DIVINE_RISK_MQH__
#define __ETHERIC_DIVINE_RISK_MQH__

#include "Divine_Config.mqh"
#include "Divine_Types.mqh"

class CDivineRisk
  {
private:
   double NormalizeVolume(const string symbol,const double lots)
     {
      double minLot = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
      double step = SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);

      if(minLot <= 0.0)
         minLot = 0.01;
      if(maxLot <= 0.0)
         maxLot = minLot;
      if(step <= 0.0)
         step = minLot;

      double bounded = MathMax(minLot,MathMin(lots,maxLot));
      double steps = MathFloor((bounded - minLot) / step);
      return NormalizeDouble(minLot + steps * step,2);
     }

public:
   DivineAccountMode AccountMode(void)
     {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      if(balance <= 0.0)
         balance = DIVINE_DEFAULT_BALANCE_ASSUMPTION;
      return (balance < DIVINE_MICRO_BALANCE_LIMIT) ? MICRO_SURVIVAL_MODE : SURVIVAL_MODE;
     }

   bool IsMicroMode(void)
     {
      return AccountMode() == MICRO_SURVIVAL_MODE;
     }

   double Balance(void)
     {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      if(balance <= 0.0)
         balance = DIVINE_DEFAULT_BALANCE_ASSUMPTION;
      return balance;
     }

   double MinimumLot(const string symbol)
     {
      double minLot = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
      return (minLot > 0.0) ? minLot : 0.01;
     }

   double RecommendedLots(const string symbol)
     {
      if(IsMicroMode())
         return NormalizeVolume(symbol,MinimumLot(symbol));
      return NormalizeVolume(symbol,MinimumLot(symbol));
     }

   double ActiveMaxRiskPercent(void)
     {
      return IsMicroMode() ? DivineMicroMaxRiskPercent : DivineMaxRiskPercent;
     }

   int ActiveMaxSpreadPoints(void)
     {
      return IsMicroMode() ? DivineMicroMaxSpreadPoints : DivineMaxSpreadPoints;
     }

   bool AllowsTrade(const string symbol,const DivineDirection direction,const double lots,string &reason_code)
     {
      DivineAccountMode mode = AccountMode();
      if(mode == MICRO_SURVIVAL_MODE)
         reason_code = "MICRO_BALANCE_ACTIVE";

      int spread = (int)SymbolInfoInteger(symbol,SYMBOL_SPREAD);
      if(spread > ActiveMaxSpreadPoints())
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

      double normalizedLots = NormalizeVolume(symbol,lots);
      if(mode == MICRO_SURVIVAL_MODE && normalizedLots > minLot)
        {
         reason_code = "MICRO_MIN_LOT_REQUIRED";
         return false;
        }

      if(direction != DIR_NONE)
        {
         ENUM_ORDER_TYPE orderType = (direction == DIR_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
         double price = (direction == DIR_BUY) ? SymbolInfoDouble(symbol,SYMBOL_ASK) : SymbolInfoDouble(symbol,SYMBOL_BID);
         double margin = 0.0;
         if(!OrderCalcMargin(orderType,symbol,normalizedLots,price,margin))
           {
            reason_code = "MARGIN_CALC_FAILED";
            return false;
           }

         double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
         if(freeMargin < margin)
           {
            reason_code = "MARGIN_TOO_LOW";
            return false;
           }

         if(mode == MICRO_SURVIVAL_MODE && freeMargin > 0.0)
           {
            double remainingPercent = (freeMargin - margin) / freeMargin * 100.0;
            if(remainingPercent < DivineMicroMinFreeMarginPercent)
              {
               reason_code = "MICRO_MARGIN_BUFFER_REQUIRED";
               return false;
              }
           }
        }

      reason_code = (mode == MICRO_SURVIVAL_MODE) ? "MICRO_BALANCE_ACTIVE" : "EXECUTION_ALLOWED";
      return true;
     }
  };

#endif
