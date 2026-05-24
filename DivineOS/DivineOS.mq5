#property strict
#property description "Etheric World / DivineOS Phase 1"

#include "Divine_Types.mqh"
#include "Divine_Utils.mqh"
#include "Divine_Config.mqh"
#include "Divine_State.mqh"
#include "Divine_Logger.mqh"
#include "Divine_Market.mqh"
#include "Divine_Sessions.mqh"
#include "Divine_Signals.mqh"
#include "Divine_Ranking.mqh"
#include "Divine_Risk.mqh"
#include "Divine_Governance.mqh"
#include "Divine_Execution.mqh"

CDivineState      g_state;
CDivineLogger     g_log;
CDivineSessions   g_sessions;
CDivineSignals    g_signals;
CDivineRisk       g_risk;
CDivineGovernance g_gov;
CDivineExecution  g_execution;

int OnInit()
  {
   g_state.SetLogger(g_log);
   g_state.DetectMode();
   g_execution.Bind(g_risk,g_gov,g_state,g_log);
   g_state.Transition(STATE_READY,"INIT_READY");
   g_log.Info("INIT","state=" + g_state.StateText(g_state.Current()) + " mode=" + g_state.ModeText());
   if(g_state.Mode() == MICRO_SURVIVAL_MODE)
      g_log.Info("RISK","MICRO_SURVIVAL_MODE active balance=" + DoubleToString(g_risk.Balance(),2));
   return INIT_SUCCEEDED;
  }

void OnTick()
  {
   g_state.DetectMode();

   if(!g_sessions.IsAllowedNow())
     {
      g_log.Reason("SESSION",_Symbol,"SESSION_BLOCKED",false);
      return;
     }

   if(!g_state.Transition(STATE_SCANNING,"TICK_SCAN"))
      return;

   DivineDecision decision = g_signals.Scan(_Symbol);
   decision.sequence_id = g_state.NextSequence();
   g_log.Reason("CHIMP",_Symbol,decision.reason_code,decision.allowed);

   if(decision.allowed)
     {
      if(g_state.Transition(STATE_SIGNAL_READY,"SIGNAL_READY"))
         g_execution.Execute(decision);
     }
   else
     {
      g_state.Transition(STATE_READY,decision.reason_code);
     }
  }
