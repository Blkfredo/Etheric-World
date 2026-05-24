#ifndef __ETHERIC_DIVINE_MARKET_MQH__
#define __ETHERIC_DIVINE_MARKET_MQH__

class CDivineMarket
  {
public:
   int SpreadPoints(const string symbol)
     {
      return (int)SymbolInfoInteger(symbol,SYMBOL_SPREAD);
     }

   bool SpreadAllowed(const string symbol,const int max_spread_points)
     {
      return SpreadPoints(symbol) <= max_spread_points;
     }
  };

#endif

