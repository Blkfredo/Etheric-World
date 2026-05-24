#ifndef __ETHERIC_DIVINE_RANKING_MQH__
#define __ETHERIC_DIVINE_RANKING_MQH__

#include "Divine_Types.mqh"

class CDivineRanking
  {
public:
   bool PassesChimpThreshold(const DivineDecision &decision)
     {
      return decision.score >= 70 && decision.direction != DIR_NONE;
     }
  };

#endif

