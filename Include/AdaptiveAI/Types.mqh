#ifndef ADAPTIVE_AI_TYPES_MQH
#define ADAPTIVE_AI_TYPES_MQH

enum AdaptiveAction
  {
   ADAPTIVE_ACTION_NO_TRADE = 0,
   ADAPTIVE_ACTION_BUY_ATR_1R = 1,
   ADAPTIVE_ACTION_SELL_ATR_1R = 2
  };

enum VolumeCheckResult
  {
   ADAPTIVE_VOLUME_OK = 0,
   ADAPTIVE_VOLUME_RETRYABLE = 1,
   ADAPTIVE_VOLUME_UNAVAILABLE = 2
  };

struct MarketFeatures
  {
   datetime bar_time;
   double   atr;
   double   spread_points;
   double   body_points;
   double   range_points;
   double   slope_points;
   double   distance_high_points;
   double   distance_low_points;
   long     tick_volume;
   int      session_hour;
   bool     valid;
  };

struct MarketState
  {
   string key;
   int    volatility_bucket;
   int    spread_bucket;
   int    momentum_bucket;
   int    location_bucket;
   int    session_bucket;
   bool   valid;
  };

struct ActionStats
  {
   string         state_key;
   AdaptiveAction action;
   double         samples;
   double         wins;
   double         losses;
   double         total_r;
   double         recent_r;
   datetime       last_update;
  };

struct ModelDecision
  {
   AdaptiveAction action;
   string         state_key;
   double         score;
   double         confidence;
   bool           exploratory;
   string         reason;
  };

struct TradePlan
  {
   AdaptiveAction action;
   string         state_key;
   double         entry;
   double         stop_loss;
   double         take_profit;
   double         risk_distance;
   double         volume;
   bool           valid;
  };

struct ActiveDecision
  {
   ulong          position_id;
   string         state_key;
   AdaptiveAction action;
   double         entry;
   double         stop_loss;
   double         risk_distance;
   datetime       open_time;
   bool           valid;
  };

void ResetDecision(ModelDecision &decision)
  {
   decision.action = ADAPTIVE_ACTION_NO_TRADE;
   decision.state_key = "";
   decision.score = 0.0;
   decision.confidence = 0.0;
   decision.exploratory = false;
   decision.reason = "";
  }

void ResetTradePlan(TradePlan &plan)
  {
   plan.action = ADAPTIVE_ACTION_NO_TRADE;
   plan.state_key = "";
   plan.entry = 0.0;
   plan.stop_loss = 0.0;
   plan.take_profit = 0.0;
   plan.risk_distance = 0.0;
   plan.volume = 0.0;
   plan.valid = false;
  }

string AdaptiveActionName(const AdaptiveAction action)
  {
   if(action == ADAPTIVE_ACTION_BUY_ATR_1R)
      return "BUY_ATR_1R";
   if(action == ADAPTIVE_ACTION_SELL_ATR_1R)
      return "SELL_ATR_1R";
   return "NO_TRADE";
  }

#endif
