#ifndef FIBO_EA_RISK_MANAGER_MQH
#define FIBO_EA_RISK_MANAGER_MQH

#include "Types.mqh"

class CRiskManager
  {
private:
   datetime BrokerDayStart(void) const
     {
      datetime now = TimeTradeServer();
      if(now == 0)
         now = TimeCurrent();

      MqlDateTime parts;
      TimeToStruct(now, parts);
      parts.hour = 0;
      parts.min = 0;
      parts.sec = 0;
      return StructToTime(parts);
     }

   double DealNetResult(const ulong ticket) const
     {
      return HistoryDealGetDouble(ticket, DEAL_PROFIT)
             + HistoryDealGetDouble(ticket, DEAL_COMMISSION)
             + HistoryDealGetDouble(ticket, DEAL_SWAP)
             + HistoryDealGetDouble(ticket, DEAL_FEE);
     }

   double EffectiveVolumeStep(const string symbol, const double configured_step) const
     {
      const double symbol_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      if(symbol_step <= 0.0 || configured_step <= 0.0)
         return 0.0;

      return MathMax(symbol_step, configured_step);
     }

   double NormalizeVolumeDown(const string symbol,
                              const double volume,
                              const double configured_minimum,
                              const double configured_maximum,
                              const double configured_step) const
     {
      const double symbol_minimum = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      const double symbol_maximum = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      const double step = EffectiveVolumeStep(symbol, configured_step);
      if(symbol_minimum <= 0.0 || symbol_maximum <= 0.0 || step <= 0.0)
         return 0.0;

      const double minimum = MathMax(symbol_minimum, configured_minimum);
      const double maximum = MathMin(symbol_maximum, configured_maximum);
      if(minimum <= 0.0 || maximum <= 0.0 || maximum < minimum || volume < minimum)
         return 0.0;

      const double capped = MathMin(volume, maximum);
      const double normalized = MathFloor((capped + 1e-12) / step) * step;
      const double rounded = NormalizeDouble(normalized, 2);
      if(rounded < minimum)
         return 0.0;

      return rounded;
     }

   bool MarginLevelAllowsTrade(const string symbol,
                               const SwingDirection direction,
                               const double volume,
                               const double price,
                               const double minimum_margin_level_percent) const
     {
      if(minimum_margin_level_percent <= 0.0)
         return true;

      const ENUM_ORDER_TYPE order_type = (direction == SWING_DIRECTION_BULLISH)
                                         ? ORDER_TYPE_BUY
                                         : ORDER_TYPE_SELL;
      double required_margin = 0.0;
      if(!OrderCalcMargin(order_type, symbol, volume, price, required_margin))
        {
         PrintFormat("Unable to calculate required margin for %s. Error: %d", symbol, GetLastError());
         return false;
        }

      const double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      const double margin_after_trade = AccountInfoDouble(ACCOUNT_MARGIN) + required_margin;
      if(equity <= 0.0 || margin_after_trade <= 0.0)
         return false;

      const double margin_level_after_trade = equity / margin_after_trade * 100.0;
      return (margin_level_after_trade >= minimum_margin_level_percent);
     }

public:
   datetime CurrentBrokerDayStart(void) const
     {
      return BrokerDayStart();
     }

   bool GetDailyClosedLoss(const ulong magic,
                           double &closed_loss,
                           double &start_balance) const
     {
      closed_loss = 0.0;
      start_balance = AccountInfoDouble(ACCOUNT_BALANCE);
      const datetime day_start = BrokerDayStart();
      datetime now = TimeTradeServer();
      if(now == 0)
         now = TimeCurrent();

      if(!HistorySelect(day_start, now))
        {
         PrintFormat("Unable to select today's deal history. Error: %d", GetLastError());
         return false;
        }

      double account_change = 0.0;
      const int total = HistoryDealsTotal();
      for(int index = 0; index < total; ++index)
        {
         const ulong ticket = HistoryDealGetTicket(index);
         if(ticket == 0)
            continue;

         const double result = DealNetResult(ticket);
         account_change += result;

         if((ulong)HistoryDealGetInteger(ticket, DEAL_MAGIC) != magic)
            continue;

         const ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
         if(entry != DEAL_ENTRY_OUT && entry != DEAL_ENTRY_OUT_BY && entry != DEAL_ENTRY_INOUT)
            continue;

         if(result < 0.0)
            closed_loss += -result;
        }

      start_balance -= account_change;
      if(start_balance <= 0.0)
         start_balance = AccountInfoDouble(ACCOUNT_BALANCE);
      return true;
     }

   bool IsDailyLossLimitReached(const ulong magic,
                                const double max_loss_percent,
                                double &closed_loss,
                                double &loss_limit) const
     {
      double start_balance = 0.0;
      if(!GetDailyClosedLoss(magic, closed_loss, start_balance))
        {
         loss_limit = 0.0;
         return true;
        }

      loss_limit = start_balance * max_loss_percent / 100.0;
      return (loss_limit > 0.0 && closed_loss >= loss_limit);
     }

   VolumeCalculationResult CalculateVolume(const string symbol,
                                           const SwingDirection direction,
                                           const double entry,
                                           const double stop_loss,
                                           const double risk_percent,
                                           const double minimum_lot,
                                           const double maximum_lot,
                                           const double lot_step,
                                           const double minimum_margin_level_percent,
                                           double &volume) const
     {
      volume = 0.0;
      if(entry <= 0.0 || stop_loss <= 0.0 || entry == stop_loss ||
         risk_percent <= 0.0 || minimum_lot <= 0.0 || maximum_lot < minimum_lot ||
         lot_step <= 0.0 || minimum_margin_level_percent < 0.0)
         return VOLUME_PERMANENTLY_UNAVAILABLE;

      const ENUM_ORDER_TYPE order_type = (direction == SWING_DIRECTION_BULLISH)
                                         ? ORDER_TYPE_BUY
                                         : ORDER_TYPE_SELL;
      double one_lot_result = 0.0;
      if(!OrderCalcProfit(order_type, symbol, 1.0, entry, stop_loss, one_lot_result))
        {
         PrintFormat("Unable to calculate trade risk for %s. Error: %d", symbol, GetLastError());
         return VOLUME_RETRYABLE;
        }

      const double one_lot_loss = MathAbs(one_lot_result);
      if(one_lot_loss <= 0.0)
         return VOLUME_RETRYABLE;

      const double risk_money = AccountInfoDouble(ACCOUNT_EQUITY) * risk_percent / 100.0;
      const double raw_volume = risk_money / one_lot_loss;
      volume = NormalizeVolumeDown(symbol, raw_volume, minimum_lot, maximum_lot, lot_step);
      const double volume_step = EffectiveVolumeStep(symbol, lot_step);
      while(volume > 0.0 &&
            !MarginLevelAllowsTrade(symbol, direction, volume, entry, minimum_margin_level_percent))
        {
         volume = NormalizeVolumeDown(symbol, volume - volume_step, minimum_lot, maximum_lot, lot_step);
        }

      if(volume <= 0.0)
         return VOLUME_PERMANENTLY_UNAVAILABLE;

      double normalized_loss = 0.0;
      if(!OrderCalcProfit(order_type, symbol, volume, entry, stop_loss, normalized_loss))
        {
         volume = 0.0;
         return VOLUME_RETRYABLE;
        }

      if(MathAbs(normalized_loss) > risk_money + 0.01)
        {
         volume = 0.0;
         return VOLUME_PERMANENTLY_UNAVAILABLE;
        }

      return VOLUME_CALCULATED;
     }
  };

#endif
