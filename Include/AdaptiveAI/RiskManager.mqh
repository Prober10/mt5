#ifndef ADAPTIVE_AI_RISK_MANAGER_MQH
#define ADAPTIVE_AI_RISK_MANAGER_MQH

#include "Types.mqh"

class CAdaptiveRiskManager
  {
private:
   double NormalizeVolumeDown(const string symbol,
                              const double volume,
                              const double configured_step) const
     {
      const double broker_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      const double step = MathMax(broker_step, configured_step);
      if(step <= 0.0)
         return 0.0;
      return MathFloor(volume / step) * step;
     }

public:
   datetime CurrentBrokerDayStart(void) const
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

   bool IsDailyLossLimitReached(const ulong magic,
                                const double max_daily_loss_percent,
                                double &closed_loss,
                                double &loss_limit) const
     {
      closed_loss = 0.0;
      loss_limit = 0.0;

      const datetime day_start = CurrentBrokerDayStart();
      const datetime now = TimeCurrent();
      if(!HistorySelect(day_start, now))
         return true;

      double today_net = 0.0;
      for(int index = 0; index < HistoryDealsTotal(); ++index)
        {
         const ulong deal = HistoryDealGetTicket(index);
         if(deal == 0)
            continue;

         const long entry = HistoryDealGetInteger(deal, DEAL_ENTRY);
         const double result = HistoryDealGetDouble(deal, DEAL_PROFIT) +
                               HistoryDealGetDouble(deal, DEAL_COMMISSION) +
                               HistoryDealGetDouble(deal, DEAL_SWAP) +
                               HistoryDealGetDouble(deal, DEAL_FEE);

         today_net += result;
         if((ulong)HistoryDealGetInteger(deal, DEAL_MAGIC) == magic &&
            (entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_INOUT) &&
            result < 0.0)
            closed_loss += MathAbs(result);
        }

      const double day_start_balance = AccountInfoDouble(ACCOUNT_BALANCE) - today_net;
      loss_limit = day_start_balance * max_daily_loss_percent / 100.0;
      return (closed_loss >= loss_limit);
     }

   VolumeCheckResult CalculateVolume(const string symbol,
                                     const AdaptiveAction action,
                                     const double entry,
                                     const double stop_loss,
                                     const double risk_percent,
                                     const double min_lot,
                                     const double max_lot,
                                     const double lot_step,
                                     const double min_margin_level_percent,
                                     double &volume) const
     {
      volume = 0.0;
      if(entry <= 0.0 || stop_loss <= 0.0 || risk_percent <= 0.0)
         return ADAPTIVE_VOLUME_UNAVAILABLE;

      ENUM_ORDER_TYPE order_type = ORDER_TYPE_BUY;
      if(action == ADAPTIVE_ACTION_SELL_ATR_1R)
         order_type = ORDER_TYPE_SELL;
      else if(action != ADAPTIVE_ACTION_BUY_ATR_1R)
         return ADAPTIVE_VOLUME_UNAVAILABLE;

      double one_lot_loss = 0.0;
      if(!OrderCalcProfit(order_type, symbol, 1.0, entry, stop_loss, one_lot_loss))
         return ADAPTIVE_VOLUME_RETRYABLE;

      one_lot_loss = MathAbs(one_lot_loss);
      if(one_lot_loss <= 0.0)
         return ADAPTIVE_VOLUME_UNAVAILABLE;

      const double risk_amount = AccountInfoDouble(ACCOUNT_EQUITY) * risk_percent / 100.0;
      double raw_volume = risk_amount / one_lot_loss;

      const double broker_min = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      const double broker_max = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      const double effective_min = MathMax(broker_min, min_lot);
      const double effective_max = MathMin(broker_max, max_lot);
      if(effective_min <= 0.0 || effective_max < effective_min)
         return ADAPTIVE_VOLUME_UNAVAILABLE;

      raw_volume = MathMin(raw_volume, effective_max);
      volume = NormalizeVolumeDown(symbol, raw_volume, lot_step);
      if(volume < effective_min)
         return ADAPTIVE_VOLUME_UNAVAILABLE;

      while(volume >= effective_min && min_margin_level_percent > 0.0)
        {
         double margin = 0.0;
         if(!OrderCalcMargin(order_type, symbol, volume, entry, margin))
            return ADAPTIVE_VOLUME_RETRYABLE;

         const double equity = AccountInfoDouble(ACCOUNT_EQUITY);
         const double used_margin = AccountInfoDouble(ACCOUNT_MARGIN);
         const double projected_margin = used_margin + margin;
         const double projected_margin_level = (projected_margin > 0.0)
                                               ? equity / projected_margin * 100.0
                                               : 999999.0;
         if(projected_margin_level >= min_margin_level_percent)
            return ADAPTIVE_VOLUME_OK;

         volume = NormalizeVolumeDown(symbol, volume - lot_step, lot_step);
        }

      return (volume >= effective_min) ? ADAPTIVE_VOLUME_OK : ADAPTIVE_VOLUME_UNAVAILABLE;
     }
  };

#endif
