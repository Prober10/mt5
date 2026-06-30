#ifndef ADAPTIVE_AI_FEATURE_EXTRACTOR_MQH
#define ADAPTIVE_AI_FEATURE_EXTRACTOR_MQH

#include "Types.mqh"

class CAdaptiveFeatureExtractor
  {
private:
   int             m_atr_handle;
   string          m_symbol;
   ENUM_TIMEFRAMES m_timeframe;
   int             m_atr_period;
   int             m_slope_lookback;
   int             m_range_lookback;

public:
   CAdaptiveFeatureExtractor(void)
     {
      m_atr_handle = INVALID_HANDLE;
      m_symbol = "";
      m_timeframe = PERIOD_CURRENT;
      m_atr_period = 14;
      m_slope_lookback = 20;
      m_range_lookback = 48;
     }

   bool Initialize(const string symbol,
                   const ENUM_TIMEFRAMES timeframe,
                   const int atr_period,
                   const int slope_lookback,
                   const int range_lookback)
     {
      m_symbol = symbol;
      m_timeframe = timeframe;
      m_atr_period = atr_period;
      m_slope_lookback = slope_lookback;
      m_range_lookback = range_lookback;

      m_atr_handle = iATR(m_symbol, m_timeframe, m_atr_period);
      return (m_atr_handle != INVALID_HANDLE);
     }

   void Release(void)
     {
      if(m_atr_handle != INVALID_HANDLE)
        {
         IndicatorRelease(m_atr_handle);
         m_atr_handle = INVALID_HANDLE;
        }
     }

   bool Extract(MarketFeatures &features) const
     {
      features.valid = false;

      const int needed = MathMax(m_slope_lookback + 2, m_range_lookback + 2);
      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      if(CopyRates(m_symbol, m_timeframe, 0, needed, rates) < needed)
         return false;

      double atr_buffer[];
      ArraySetAsSeries(atr_buffer, true);
      if(CopyBuffer(m_atr_handle, 0, 1, 1, atr_buffer) != 1)
         return false;

      MqlTick tick;
      if(!SymbolInfoTick(m_symbol, tick))
         return false;

      const double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      if(point <= 0.0)
         return false;

      const MqlRates last_closed = rates[1];
      double highest = rates[1].high;
      double lowest = rates[1].low;
      for(int index = 2; index <= m_range_lookback && index < ArraySize(rates); ++index)
        {
         highest = MathMax(highest, rates[index].high);
         lowest = MathMin(lowest, rates[index].low);
        }

      datetime now = TimeTradeServer();
      if(now == 0)
         now = TimeCurrent();

      MqlDateTime parts;
      TimeToStruct(now, parts);

      features.bar_time = last_closed.time;
      features.atr = atr_buffer[0];
      features.spread_points = (tick.ask - tick.bid) / point;
      features.body_points = (last_closed.close - last_closed.open) / point;
      features.range_points = (last_closed.high - last_closed.low) / point;
      features.slope_points = (rates[1].close - rates[m_slope_lookback].close) / point;
      features.distance_high_points = (highest - last_closed.close) / point;
      features.distance_low_points = (last_closed.close - lowest) / point;
      features.tick_volume = last_closed.tick_volume;
      features.session_hour = parts.hour;
      features.valid = (features.atr > 0.0);
      return features.valid;
     }
  };

#endif
