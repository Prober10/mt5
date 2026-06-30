#ifndef ADAPTIVE_AI_PERFORMANCE_TRACKER_MQH
#define ADAPTIVE_AI_PERFORMANCE_TRACKER_MQH

#include "Types.mqh"

class CAdaptivePerformanceTracker
  {
private:
   ActiveDecision m_active;

public:
   void Initialize(void)
     {
      m_active.valid = false;
   }

   void RecordOpened(const ulong position_id,
                     const TradePlan &plan)
     {
      m_active.position_id = position_id;
      m_active.state_key = plan.state_key;
      m_active.action = plan.action;
      m_active.entry = plan.entry;
      m_active.stop_loss = plan.stop_loss;
      m_active.risk_distance = plan.risk_distance;
      m_active.open_time = TimeCurrent();
      m_active.valid = (position_id != 0 && plan.risk_distance > 0.0);
     }

   bool ConsumeClosedDeal(const ulong deal_ticket,
                          const ulong magic,
                          string &state_key,
                          AdaptiveAction &action,
                          double &result_r)
     {
      state_key = "";
      action = ADAPTIVE_ACTION_NO_TRADE;
      result_r = 0.0;

      if(!m_active.valid || deal_ticket == 0 || !HistoryDealSelect(deal_ticket))
         return false;

      if((ulong)HistoryDealGetInteger(deal_ticket, DEAL_MAGIC) != magic)
         return false;

      const long entry_type = HistoryDealGetInteger(deal_ticket, DEAL_ENTRY);
      if(entry_type != DEAL_ENTRY_OUT && entry_type != DEAL_ENTRY_INOUT)
         return false;

      const ulong position_id = (ulong)HistoryDealGetInteger(deal_ticket, DEAL_POSITION_ID);
      if(position_id != m_active.position_id)
         return false;

      const double profit = HistoryDealGetDouble(deal_ticket, DEAL_PROFIT) +
                            HistoryDealGetDouble(deal_ticket, DEAL_COMMISSION) +
                            HistoryDealGetDouble(deal_ticket, DEAL_SWAP) +
                            HistoryDealGetDouble(deal_ticket, DEAL_FEE);

      double initial_risk_money = 0.0;
      ENUM_ORDER_TYPE order_type = (m_active.action == ADAPTIVE_ACTION_BUY_ATR_1R)
                                   ? ORDER_TYPE_BUY
                                   : ORDER_TYPE_SELL;
      const string symbol = HistoryDealGetString(deal_ticket, DEAL_SYMBOL);
      if(!OrderCalcProfit(order_type, symbol, 1.0, m_active.entry,
                          m_active.stop_loss, initial_risk_money))
         return false;

      initial_risk_money = MathAbs(initial_risk_money);
      const double volume = HistoryDealGetDouble(deal_ticket, DEAL_VOLUME);
      const double risk_money = initial_risk_money * volume;
      if(risk_money <= 0.0)
         return false;

      state_key = m_active.state_key;
      action = m_active.action;
      result_r = profit / risk_money;
      m_active.valid = false;
      return true;
     }
  };

#endif
