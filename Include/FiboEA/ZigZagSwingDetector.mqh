#ifndef FIBO_EA_ZIGZAG_SWING_DETECTOR_MQH
#define FIBO_EA_ZIGZAG_SWING_DETECTOR_MQH

#include "Types.mqh"

class CZigZagSwingDetector
  {
private:
   int               m_handle;
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   int               m_lookback_bars;

public:
                     CZigZagSwingDetector(void) : m_handle(INVALID_HANDLE),
                                                   m_symbol(""),
                                                   m_timeframe(PERIOD_M15),
                                                   m_lookback_bars(1000) {}

                    ~CZigZagSwingDetector(void)
     {
      Release();
     }

   bool Initialize(const string symbol,
                   const ENUM_TIMEFRAMES timeframe,
                   const int depth,
                   const int deviation,
                   const int backstep,
                   const int lookback_bars)
     {
      Release();
      m_symbol = symbol;
      m_timeframe = timeframe;
      m_lookback_bars = MathMax(lookback_bars, 100);
      m_handle = iCustom(m_symbol, m_timeframe, "Examples\\ZigZag",
                         depth, deviation, backstep);

      if(m_handle == INVALID_HANDLE)
        {
         PrintFormat("Unable to create ZigZag handle. Error: %d", GetLastError());
         return false;
        }

      return true;
     }

   void Release(void)
     {
      if(m_handle != INVALID_HANDLE)
        {
         IndicatorRelease(m_handle);
         m_handle = INVALID_HANDLE;
        }
     }

   bool GetLatestConfirmedSwing(SwingData &swing)
     {
      ResetSwing(swing);
      if(m_handle == INVALID_HANDLE || BarsCalculated(m_handle) < 3)
         return false;

      double values[];
      datetime times[];
      const int copied_values = CopyBuffer(m_handle, 0, 0, m_lookback_bars, values);
      const int copied_times = CopyTime(m_symbol, m_timeframe, 0, m_lookback_bars, times);
      const int count = MathMin(copied_values, copied_times);
      if(count < 3)
         return false;

      int vertex_indexes[3];
      int found = 0;
      for(int index = count - 1; index >= 0 && found < 3; --index)
        {
         if(values[index] == 0.0 || values[index] == EMPTY_VALUE)
            continue;
         vertex_indexes[found++] = index;
        }

      // The newest ZigZag vertex is the still-forming leg. The next two
      // vertices form the latest confirmed impulse.
      if(found < 3)
         return false;

      const int end_index = vertex_indexes[1];
      const int start_index = vertex_indexes[2];
      if(times[end_index] <= times[start_index] || values[end_index] == values[start_index])
         return false;

      swing.start_time = times[start_index];
      swing.end_time = times[end_index];
      swing.start_price = values[start_index];
      swing.end_price = values[end_index];
      swing.direction = (swing.end_price > swing.start_price)
                        ? SWING_DIRECTION_BULLISH
                        : SWING_DIRECTION_BEARISH;
      swing.valid = true;
      return true;
     }
  };

#endif
