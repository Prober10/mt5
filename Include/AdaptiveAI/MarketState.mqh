#ifndef ADAPTIVE_AI_MARKET_STATE_MQH
#define ADAPTIVE_AI_MARKET_STATE_MQH

#include "Types.mqh"

class CAdaptiveMarketStateBuilder
  {
private:
   int Bucket3(const double value, const double low_threshold, const double high_threshold) const
     {
      if(value < low_threshold)
         return 0;
      if(value > high_threshold)
         return 2;
      return 1;
     }

public:
   bool Build(const string symbol,
              const MarketFeatures &features,
              MarketState &state) const
     {
      state.valid = false;
      if(!features.valid)
         return false;

      const double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      if(point <= 0.0)
         return false;

      const double atr_points = features.atr / point;
      state.volatility_bucket = Bucket3(atr_points, 500.0, 2000.0);
      state.spread_bucket = Bucket3(features.spread_points, 50.0, 200.0);
      state.momentum_bucket = Bucket3(features.slope_points, -500.0, 500.0);

      if(features.distance_high_points < features.distance_low_points * 0.50)
         state.location_bucket = 2;
      else if(features.distance_low_points < features.distance_high_points * 0.50)
         state.location_bucket = 0;
      else
         state.location_bucket = 1;

      state.session_bucket = features.session_hour / 6;
      if(state.session_bucket < 0)
         state.session_bucket = 0;
      if(state.session_bucket > 3)
         state.session_bucket = 3;

      state.key = StringFormat("v%d_s%d_m%d_l%d_h%d",
                               state.volatility_bucket,
                               state.spread_bucket,
                               state.momentum_bucket,
                               state.location_bucket,
                               state.session_bucket);
      state.valid = true;
      return true;
     }
  };

#endif
