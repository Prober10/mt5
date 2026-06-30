#ifndef ADAPTIVE_AI_DIAGNOSTICS_MQH
#define ADAPTIVE_AI_DIAGNOSTICS_MQH

#include "Types.mqh"

class CAdaptiveDiagnostics
  {
private:
   bool   m_enabled;
   int    m_handle;
   string m_file_name;

   void WriteHeader(void)
     {
      FileWrite(m_handle, "time", "event", "state", "action", "reason",
                "score", "confidence", "atr", "spread_points", "slope_points",
                "session_hour", "volume", "entry", "sl", "tp", "result_r");
     }

public:
   CAdaptiveDiagnostics(void)
     {
      m_enabled = false;
      m_handle = INVALID_HANDLE;
      m_file_name = "";
     }

   bool Initialize(const bool enabled, const string file_name)
     {
      m_enabled = enabled;
      m_file_name = file_name;
      if(!m_enabled)
         return true;

      FolderCreate("AdaptiveAI", FILE_COMMON);
      m_handle = FileOpen(m_file_name, FILE_WRITE | FILE_CSV | FILE_COMMON | FILE_ANSI);
      if(m_handle == INVALID_HANDLE)
         return false;

      WriteHeader();
      return true;
     }

   void Deinitialize(void)
     {
      if(m_handle != INVALID_HANDLE)
        {
         FileClose(m_handle);
         m_handle = INVALID_HANDLE;
        }
     }

   void LogDecision(const MarketFeatures &features,
                    const MarketState &state,
                    const ModelDecision &decision) const
     {
      if(!m_enabled || m_handle == INVALID_HANDLE)
         return;

      FileWrite(m_handle, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
                "decision", state.key, AdaptiveActionName(decision.action),
                decision.reason, decision.score, decision.confidence,
                features.atr, features.spread_points, features.slope_points,
                features.session_hour, 0.0, 0.0, 0.0, 0.0, 0.0);
      FileFlush(m_handle);
     }

   void LogPlan(const string event_name,
                const TradePlan &plan,
                const string reason) const
     {
      if(!m_enabled || m_handle == INVALID_HANDLE)
         return;

      FileWrite(m_handle, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
                event_name, plan.state_key, AdaptiveActionName(plan.action),
                reason, 0.0, 0.0, 0.0, 0.0, 0.0, 0,
                plan.volume, plan.entry, plan.stop_loss, plan.take_profit, 0.0);
      FileFlush(m_handle);
     }

   void LogLearning(const string state_key,
                    const AdaptiveAction action,
                    const double result_r,
                    const string reason) const
     {
      if(!m_enabled || m_handle == INVALID_HANDLE)
         return;

      FileWrite(m_handle, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
                "learning", state_key, AdaptiveActionName(action), reason,
                0.0, 0.0, 0.0, 0.0, 0.0, 0,
                0.0, 0.0, 0.0, 0.0, result_r);
      FileFlush(m_handle);
     }
  };

#endif
