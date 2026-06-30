#ifndef ADAPTIVE_AI_LEARNING_MODEL_MQH
#define ADAPTIVE_AI_LEARNING_MODEL_MQH

#include "Types.mqh"

class CAdaptiveLearningModel
  {
private:
   ActionStats m_stats[];
   double      m_decay;

   int FindIndex(const string state_key, const AdaptiveAction action) const
     {
      for(int index = 0; index < ArraySize(m_stats); ++index)
        {
         if(m_stats[index].state_key == state_key && m_stats[index].action == action)
            return index;
        }
      return -1;
     }

   int EnsureIndex(const string state_key, const AdaptiveAction action)
     {
      int index = FindIndex(state_key, action);
      if(index >= 0)
         return index;

      index = ArraySize(m_stats);
      ArrayResize(m_stats, index + 1);
      m_stats[index].state_key = state_key;
      m_stats[index].action = action;
      m_stats[index].samples = 0.0;
      m_stats[index].wins = 0.0;
      m_stats[index].losses = 0.0;
      m_stats[index].total_r = 0.0;
      m_stats[index].recent_r = 0.0;
      m_stats[index].last_update = 0;
      return index;
     }

public:
   void Initialize(const double decay)
     {
      m_decay = MathMax(0.0, MathMin(decay, 1.0));
     }

   void Clear(void)
     {
      ArrayResize(m_stats, 0);
     }

   int Count(void) const
     {
      return ArraySize(m_stats);
     }

   bool GetByIndex(const int index, ActionStats &stats) const
     {
      if(index < 0 || index >= ArraySize(m_stats))
         return false;
      stats = m_stats[index];
      return true;
     }

   void Upsert(const ActionStats &stats)
     {
      const int index = EnsureIndex(stats.state_key, stats.action);
      m_stats[index] = stats;
     }

   bool GetStats(const string state_key,
                 const AdaptiveAction action,
                 ActionStats &stats) const
     {
      const int index = FindIndex(state_key, action);
      if(index < 0)
         return false;
      stats = m_stats[index];
      return true;
     }

   double AverageR(const string state_key, const AdaptiveAction action) const
     {
      ActionStats stats;
      if(!GetStats(state_key, action, stats) || stats.samples <= 0.0)
         return 0.0;
      return stats.total_r / stats.samples;
     }

   double Confidence(const string state_key,
                     const AdaptiveAction action,
                     const int minimum_samples) const
     {
      ActionStats stats;
      if(!GetStats(state_key, action, stats) || minimum_samples <= 0)
         return 0.0;
      return MathMin(1.0, stats.samples / (double)minimum_samples);
     }

   void Update(const string state_key,
               const AdaptiveAction action,
               const double result_r)
     {
      if(action == ADAPTIVE_ACTION_NO_TRADE || state_key == "")
         return;

      const int index = EnsureIndex(state_key, action);
      m_stats[index].samples = m_stats[index].samples * m_decay + 1.0;
      m_stats[index].wins = m_stats[index].wins * m_decay + (result_r > 0.0 ? 1.0 : 0.0);
      m_stats[index].losses = m_stats[index].losses * m_decay + (result_r <= 0.0 ? 1.0 : 0.0);
      m_stats[index].total_r = m_stats[index].total_r * m_decay + result_r;
      m_stats[index].recent_r = m_stats[index].recent_r * m_decay + result_r * (1.0 - m_decay);
      m_stats[index].last_update = TimeCurrent();
   }
  };

#endif
