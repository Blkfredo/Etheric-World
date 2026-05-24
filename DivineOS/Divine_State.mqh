#ifndef __ETHERIC_DIVINE_STATE_MQH__
#define __ETHERIC_DIVINE_STATE_MQH__

#include "Divine_Types.mqh"
#include "Divine_Config.mqh"
#include "Divine_Logger.mqh"

class CDivineState
  {
private:
   DivineAccountMode m_mode;
   DivineRuntimeState m_state;
   long m_sequence_id;
   CDivineLogger *m_log;

   bool IsApprovedTransition(const DivineRuntimeState from_state,const DivineRuntimeState to_state)
     {
      if(from_state == STATE_LOCKED)
         return false;
      if(to_state == STATE_LOCKED)
         return true;
      if(to_state == STATE_EMERGENCY_STOP)
         return true;

      if(from_state == STATE_BOOT && to_state == STATE_READY)
         return true;
      if(from_state == STATE_READY && (to_state == STATE_SCANNING || to_state == STATE_RELAY_INIT || to_state == STATE_RELAY_STOPPED || to_state == STATE_EMERGENCY_STOP))
         return true;
      if(from_state == STATE_SCANNING && (to_state == STATE_READY || to_state == STATE_SIGNAL_READY || to_state == STATE_EMERGENCY_STOP))
         return true;
      if(from_state == STATE_SIGNAL_READY && (to_state == STATE_EXECUTING || to_state == STATE_READY || to_state == STATE_EMERGENCY_STOP))
         return true;
      if(from_state == STATE_EXECUTING && (to_state == STATE_READY || to_state == STATE_RELAY_INIT || to_state == STATE_EMERGENCY_STOP))
         return true;
      if(from_state == STATE_RELAY_INIT && (to_state == STATE_RELAY_RUNNING || to_state == STATE_RELAY_STOPPED || to_state == STATE_EMERGENCY_STOP))
         return true;
      if(from_state == STATE_RELAY_RUNNING && (to_state == STATE_RELAY_SHUTTING_DOWN || to_state == STATE_RELAY_STOPPED || to_state == STATE_EMERGENCY_STOP))
         return true;
      if(from_state == STATE_RELAY_SHUTTING_DOWN && (to_state == STATE_RELAY_STOPPED || to_state == STATE_EMERGENCY_STOP))
         return true;
      if(from_state == STATE_RELAY_STOPPED && (to_state == STATE_READY || to_state == STATE_RELAY_INIT || to_state == STATE_EMERGENCY_STOP))
         return true;
      if(from_state == STATE_EMERGENCY_STOP && to_state == STATE_LOCKED)
         return true;

      return false;
     }

public:
   CDivineState(void)
     {
      m_mode = MICRO_SURVIVAL_MODE;
      m_state = STATE_BOOT;
      m_sequence_id = 0;
      m_log = NULL;
     }

   void SetLogger(CDivineLogger &logger)
     {
      m_log = &logger;
     }

   DivineAccountMode DetectMode(void)
     {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      if(balance <= 0.0)
         balance = DIVINE_DEFAULT_BALANCE_ASSUMPTION;

      m_mode = (balance < DIVINE_MICRO_BALANCE_LIMIT) ? MICRO_SURVIVAL_MODE : SURVIVAL_MODE;
      return m_mode;
     }

   long NextSequence(void)
     {
      m_sequence_id++;
      return m_sequence_id;
     }

   bool Transition(const DivineRuntimeState to_state,const string reason_code)
     {
      long seq = NextSequence();
      DivineRuntimeState from_state = m_state;
      if(IsApprovedTransition(from_state,to_state))
        {
         m_state = to_state;
         if(m_log != NULL)
            m_log.StateLog(seq,StateText(from_state),StateText(to_state),reason_code,"OK");
         return true;
        }

      m_state = STATE_LOCKED;
      if(m_log != NULL)
        {
         m_log.StateLog(seq,StateText(from_state),StateText(STATE_LOCKED),"LOCK_STATE_INVALID_TRANSITION","LOCKED");
         m_log.ErrorLog(seq,"STATE","LOCK_STATE_INVALID_TRANSITION",StateText(from_state) + "->" + StateText(to_state));
         m_log.Info("STATE","LOCK_STATE_INVALID_TRANSITION " + StateText(from_state) + "->" + StateText(to_state));
        }
      return false;
     }

   bool EmergencyStop(const string reason_code)
     {
      if(!Transition(STATE_EMERGENCY_STOP,reason_code))
         return false;
      return Transition(STATE_LOCKED,"EMERGENCY_STOP_LOCKED");
     }

   DivineRuntimeState Current(void) const
     {
      return m_state;
     }

   DivineAccountMode Mode(void) const
     {
      return m_mode;
     }

   string ModeText(void) const
     {
      if(m_mode == MICRO_SURVIVAL_MODE)
         return "MICRO_SURVIVAL_MODE";
      if(m_mode == SURVIVAL_MODE)
         return "SURVIVAL_MODE";
      return "CHIMP_MODE";
     }

   string StateText(const DivineRuntimeState state) const
     {
      if(state == STATE_BOOT) return "STATE_BOOT";
      if(state == STATE_READY) return "STATE_READY";
      if(state == STATE_SCANNING) return "STATE_SCANNING";
      if(state == STATE_SIGNAL_READY) return "STATE_SIGNAL_READY";
      if(state == STATE_EXECUTING) return "STATE_EXECUTING";
      if(state == STATE_RELAY_INIT) return "STATE_RELAY_INIT";
      if(state == STATE_RELAY_RUNNING) return "STATE_RELAY_RUNNING";
      if(state == STATE_RELAY_STOPPED) return "STATE_RELAY_STOPPED";
      if(state == STATE_RELAY_SHUTTING_DOWN) return "STATE_RELAY_SHUTTING_DOWN";
      if(state == STATE_EMERGENCY_STOP) return "STATE_EMERGENCY_STOP";
      if(state == STATE_LOCKED) return "STATE_LOCKED";
      return "STATE_UNKNOWN";
     }
  };

#endif
