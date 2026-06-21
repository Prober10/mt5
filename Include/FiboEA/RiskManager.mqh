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

   double NormalizeVolumeDown(const string symbol, const double volume) const
     {
      const double minimum = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      const double maximum = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      const double step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      if(minimum <= 0.0 || maximum <= 0.0 || step <= 0.0 || volume < minimum)
         return 0.0;

      const double capped = MathMin(volume, maximum);
      const double normalized = MathFloor((capped + 1e-12) / step) * step;
      if(normalized < minimum)
         return 0.0;

      return NormalizeDouble(normalized, 8);
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
                                           double &volume) const
     {
      volume = 0.0;
      if(entry <= 0.0 || stop_loss <= 0.0 || entry == stop_loss ||
         risk_percent <= 0.0)
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
      volume = NormalizeVolumeDown(symbol, raw_volume);
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
