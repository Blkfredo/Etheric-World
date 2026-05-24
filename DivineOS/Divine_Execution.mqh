#ifndef __ETHERIC_DIVINE_EXECUTION_MQH__
#define __ETHERIC_DIVINE_EXECUTION_MQH__

#include <Trade/Trade.mqh>
#include "Divine_Types.mqh"
#include "Divine_Config.mqh"
#include "Divine_Risk.mqh"
#include "Divine_Governance.mqh"
#include "Divine_State.mqh"
#include "Divine_Logger.mqh"

class CDivineExecution
  {
private:
   CTrade         m_trade;
   CDivineRisk   *m_risk;
   CDivineGovernance *m_gov;
   CDivineState  *m_state;
   CDivineLogger *m_log;
   DivineRelayLifecycle m_relay;

   bool Ready(void)
     {
      return m_risk != NULL && m_gov != NULL && m_state != NULL && m_log != NULL;
     }

public:
   CDivineExecution(void)
     {
      m_risk = NULL;
      m_gov = NULL;
      m_state = NULL;
      m_log = NULL;
      m_relay = RELAY_STOPPED;
      m_trade.SetExpertMagicNumber(DIVINE_MAGIC);
     }

   void Bind(CDivineRisk &risk,CDivineGovernance &gov,CDivineState &state,CDivineLogger &logger)
     {
      m_risk = &risk;
      m_gov = &gov;
      m_state = &state;
      m_log = &logger;
     }

   void SetLogger(CDivineLogger &logger)
     {
      m_log = &logger;
     }

   bool Execute(const DivineDecision &decision)
     {
      if(!Ready())
         return false;

      string reason = "";
      if(!m_state.Transition(STATE_EXECUTING,"EXEC_REQUEST"))
         return false;

      double lots = m_risk.RecommendedLots(decision.symbol);
      if(!m_risk.AllowsTrade(decision.symbol,decision.direction,lots,reason))
        {
         m_log.Reason("EXEC",decision.symbol,reason,false);
         m_log.TradeLog(decision.sequence_id,m_state.ModeText(),decision.symbol,"BLOCK",0.0,reason,"RISK_BLOCKED");
         m_state.Transition(STATE_READY,"EXEC_RISK_BLOCKED");
         return false;
        }

      if(!m_gov.AllowsDecision(decision,m_state.Current(),reason))
        {
         m_log.Reason("EXEC",decision.symbol,reason,false);
         m_log.TradeLog(decision.sequence_id,m_state.ModeText(),decision.symbol,"BLOCK",0.0,reason,"GOV_BLOCKED");
         m_state.Transition(STATE_READY,"EXEC_GOV_BLOCKED");
         return false;
        }

      if(decision.direction == DIR_NONE)
        {
         m_log.Reason("EXEC",decision.symbol,"NO_SIGNAL",false);
         m_log.TradeLog(decision.sequence_id,m_state.ModeText(),decision.symbol,"BLOCK",0.0,"NO_SIGNAL","STATE_RETURN");
         m_state.Transition(STATE_READY,"EXEC_NO_SIGNAL");
         return false;
        }

      m_log.Reason("EXEC",decision.symbol,"ORDER_READY",true);
      m_log.TradeLog(decision.sequence_id,m_state.ModeText(),decision.symbol,"ORDER_READY",lots,"EXECUTION_ALLOWED","DRY_RUN_PHASE1");
      m_state.Transition(STATE_READY,"EXEC_COMPLETE_PHASE1");
      return true;
     }

   bool ReviewRelay(const DivineDecision &decision,string &reason_code)
     {
      if(!Ready())
         return false;

      if(!DivineRelayEnabled)
        {
         reason_code = "RELAY_BLOCKED";
         m_log.RelayLog(decision.sequence_id,"STOPPED",decision.symbol,reason_code,false,"DISABLED");
         return false;
        }

      if(!m_state.Transition(STATE_RELAY_INIT,"RELAY_INIT"))
        {
         return false;
        }
      m_relay = RELAY_INIT;
      m_log.RelayLog(decision.sequence_id,"INIT",decision.symbol,"RELAY_INIT",true,"OK");

      double lots = m_risk.RecommendedLots(decision.symbol);
      if(!m_risk.AllowsTrade(decision.symbol,decision.direction,lots,reason_code))
        {
         m_relay = RELAY_STOPPED;
         m_log.RelayLog(decision.sequence_id,"STOPPED",decision.symbol,reason_code,false,"RISK_BLOCKED");
         m_state.Transition(STATE_RELAY_STOPPED,"RELAY_RISK_BLOCKED");
         return false;
        }

      if(!m_gov.AllowsDecision(decision,m_state.Current(),reason_code))
        {
         m_relay = RELAY_STOPPED;
         m_log.RelayLog(decision.sequence_id,"STOPPED",decision.symbol,reason_code,false,"GOV_BLOCKED");
         m_state.Transition(STATE_RELAY_STOPPED,"RELAY_GOV_BLOCKED");
         return false;
        }

      if(!m_state.Transition(STATE_RELAY_RUNNING,"RELAY_RUNNING"))
         return false;
      m_relay = RELAY_RUNNING;
      reason_code = "RELAY_ALLOWED";
      m_log.RelayLog(decision.sequence_id,"RUNNING",decision.symbol,reason_code,true,"READY");
      return true;
     }

   bool StopRelay(const string symbol,const string reason_code)
     {
      if(!Ready())
         return false;

      long seq = m_state.NextSequence();
      if(!m_state.Transition(STATE_RELAY_SHUTTING_DOWN,"RELAY_SHUTTING_DOWN"))
         return false;
      m_relay = RELAY_SHUTTING_DOWN;
      m_log.RelayLog(seq,"SHUTTING_DOWN",symbol,reason_code,true,"OK");

      if(!m_state.Transition(STATE_RELAY_STOPPED,"RELAY_STOPPED"))
         return false;
      m_relay = RELAY_STOPPED;
      m_log.RelayLog(seq,"STOPPED",symbol,reason_code,true,"OK");
      return true;
     }

   bool EXEC_FlattenAll(const string reason_code)
     {
      if(!Ready())
         return false;

      long seq = m_state.NextSequence();
      int total = PositionsTotal();
      m_log.TradeLog(seq,m_state.ModeText(),"ALL","FLATTEN_ALL",0.0,reason_code,"START");
      for(int i=total-1;i>=0;i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(ticket > 0 && PositionSelectByTicket(ticket))
           {
            string symbol = PositionGetString(POSITION_SYMBOL);
            bool closed = m_trade.PositionClose(ticket);
            m_log.TradeLog(seq,m_state.ModeText(),symbol,"POSITION_CLOSE",0.0,reason_code,closed ? "CLOSED" : "FAILED");
            if(!closed)
               m_log.ErrorLog(seq,"EXEC","FLATTEN_CLOSE_FAILED",symbol + " code=" + IntegerToString(GetLastError()));
           }
        }
      m_log.TradeLog(seq,m_state.ModeText(),"ALL","FLATTEN_ALL",0.0,reason_code,"END");
      return true;
     }

   bool EmergencyStop(const string reason_code)
     {
      if(!Ready())
         return false;

      m_log.ErrorLog(m_state.NextSequence(),"EXEC","EMERGENCY_STOP",reason_code);
      if(!m_state.Transition(STATE_EMERGENCY_STOP,reason_code))
         return false;

      EXEC_FlattenAll(reason_code);
      long seq = m_state.NextSequence();
      m_relay = RELAY_SHUTTING_DOWN;
      m_log.RelayLog(seq,"SHUTTING_DOWN",_Symbol,"EMERGENCY_STOP",true,"FORCED");
      m_relay = RELAY_STOPPED;
      m_log.RelayLog(seq,"STOPPED",_Symbol,"EMERGENCY_STOP",true,"FORCED");
      return m_state.Transition(STATE_LOCKED,"EMERGENCY_STOP_LOCKED");
     }
  };

#endif
