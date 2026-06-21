#ifndef FIBO_EA_FIBO_CALCULATOR_MQH
#define FIBO_EA_FIBO_CALCULATOR_MQH

#include "Types.mqh"

class CFiboCalculator
  {
private:
   double NormalizePrice(const string symbol, const double price) const
     {
      const double tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      const int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      if(tick_size <= 0.0)
         return NormalizeDouble(price, digits);

      return NormalizeDouble(MathRound(price / tick_size) * tick_size, digits);
     }

public:
   bool Calculate(const string symbol,
                  const SwingData &swing,
                  const double retracement,
                  const double stop_buffer,
                  TradeSetup &setup) const
     {
      ResetSetup(setup);
      if(!swing.valid || retracement <= 0.0 || retracement >= 1.0 || stop_buffer < 0.0)
         return false;

      setup.swing = swing;
      if(swing.direction == SWING_DIRECTION_BULLISH)
        {
         const double range = swing.end_price - swing.start_price;
         if(range <= 0.0)
            return false;

         setup.entry = NormalizePrice(symbol, swing.end_price - retracement * range);
         setup.stop_loss = NormalizePrice(symbol, swing.start_price - stop_buffer);
         setup.take_profit = NormalizePrice(symbol,
                                             setup.entry + (setup.entry - setup.stop_loss));
        }
      else if(swing.direction == SWING_DIRECTION_BEARISH)
        {
         const double range = swing.start_price - swing.end_price;
         if(range <= 0.0)
            return false;

         setup.entry = NormalizePrice(symbol, swing.end_price + retracement * range);
         setup.stop_loss = NormalizePrice(symbol, swing.start_price + stop_buffer);
         setup.take_profit = NormalizePrice(symbol,
                                             setup.entry - (setup.stop_loss - setup.entry));
        }
      else
         return false;

      setup.valid = (setup.stop_loss != setup.entry && setup.take_profit != setup.entry);
      return setup.valid;
     }
  };

#endif
