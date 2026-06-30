#ifndef ADAPTIVE_AI_DECISION_ENGINE_MQH
#define ADAPTIVE_AI_DECISION_ENGINE_MQH

#include "Types.mqh"
#include "LearningModel.mqh"

class CAdaptiveDecisionEngine
  {
private:
   bool RandomChance(const double percent) const
     {
      if(percent <= 0.0)
         return false;
      const double roll = (double)(MathRand() % 10000) / 100.0;
      return (roll < percent);
     }

public:
   void Decide(const MarketState &state,
               const CAdaptiveLearningModel &model,
               const bool allow_buy,
               const bool allow_sell,
               const bool tester_exploration,
               const double exploration_percent,
               const int minimum_samples,
               const double minimum_average_r,
               ModelDecision &decision) const
     {
      ResetDecision(decision);
      decision.state_key = state.key;

      if(!state.valid)
        {
         decision.reason = "invalid_state";
         return;
        }

      if(tester_exploration && MQLInfoInteger(MQL_TESTER) && RandomChance(exploration_percent))
        {
         if(allow_buy && allow_sell)
            decision.action = (MathRand() % 2 == 0) ? ADAPTIVE_ACTION_BUY_ATR_1R : ADAPTIVE_ACTION_SELL_ATR_1R;
         else if(allow_buy)
            decision.action = ADAPTIVE_ACTION_BUY_ATR_1R;
         else if(allow_sell)
            decision.action = ADAPTIVE_ACTION_SELL_ATR_1R;
         else
            decision.action = ADAPTIVE_ACTION_NO_TRADE;

         decision.exploratory = (decision.action != ADAPTIVE_ACTION_NO_TRADE);
         decision.reason = decision.exploratory ? "tester_exploration" : "no_direction_allowed";
         return;
        }

      double best_score = -DBL_MAX;
      AdaptiveAction best_action = ADAPTIVE_ACTION_NO_TRADE;
      double best_confidence = 0.0;

      AdaptiveAction actions[2] = {ADAPTIVE_ACTION_BUY_ATR_1R, ADAPTIVE_ACTION_SELL_ATR_1R};
      for(int index = 0; index < 2; ++index)
        {
         const AdaptiveAction action = actions[index];
         if((action == ADAPTIVE_ACTION_BUY_ATR_1R && !allow_buy) ||
            (action == ADAPTIVE_ACTION_SELL_ATR_1R && !allow_sell))
            continue;

         ActionStats stats;
         if(!model.GetStats(state.key, action, stats))
            continue;

         const double confidence = model.Confidence(state.key, action, minimum_samples);
         const double average_r = (stats.samples > 0.0) ? stats.total_r / stats.samples : 0.0;
         const double score = average_r * confidence;

         if(stats.samples >= minimum_samples && average_r >= minimum_average_r && score > best_score)
           {
            best_score = score;
            best_action = action;
            best_confidence = confidence;
           }
        }

      decision.action = best_action;
      decision.score = (best_action == ADAPTIVE_ACTION_NO_TRADE) ? 0.0 : best_score;
      decision.confidence = best_confidence;
      decision.reason = (best_action == ADAPTIVE_ACTION_NO_TRADE) ? "no_positive_trusted_action" : "model_selected";
   }
  };

#endif
